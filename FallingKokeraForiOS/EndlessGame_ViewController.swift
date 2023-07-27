import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import Firebase
import FirebaseFirestore
import FirebaseDatabase


class EndlessGameController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true

        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        let scene = EndlessGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        // BGMファイルのURLを取得します
        guard let bgmURL = Bundle.main.url(forResource: "playbgm", withExtension: "mp3") else {
            print("BGMファイルが見つかりません")
            return
        }

        // BGMプレーヤーを作成してBGMを再生します
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: bgmURL)
            bgmPlayer?.numberOfLoops = -1  // ループ再生を設定（-1は無限ループ）
            bgmPlayer?.play()
        } catch {
            print("BGMの再生に失敗しました: \(error)")
        }
    }
}

class EndlessGameScene: SKScene, SKPhysicsContactDelegate {
    
    var ref: DatabaseReference! = Database.database().reference()
    var player: AVAudioPlayer?
    var getsePlayer: AVAudioPlayer?
    var playerBar: SKSpriteNode!
    var scoreLabel: UILabel!
    var kakiScoreNode: SKSpriteNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
            }
    }
    
    var kakiList: [SKSpriteNode] = []
    
    var kakiCount: Int = 0 // Added line
    
    var kabukiUpperNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        kabukiUpperNode = SKSpriteNode(imageNamed: "kabuki_upper")
        kabukiUpperNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        kabukiUpperNode.zPosition = 1  // <-- 追加
        
        
        
        
        playerBar = SKSpriteNode(color: .black, size: CGSize(width: 50, height: 10))
        playerBar.position = CGPoint(x: size.width / 2, y: 100)
        addChild(playerBar)
        
        playerBar.physicsBody = SKPhysicsBody(rectangleOf: playerBar.size)
        playerBar.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        playerBar.physicsBody?.collisionBitMask = 0
        playerBar.physicsBody?.contactTestBitMask = PhysicsCategory.kaki.rawValue | PhysicsCategory.kokera.rawValue
        playerBar.physicsBody?.isDynamic = true
        
        scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: size.width - 70, y: 65, width: 200, height: 70)
        scoreLabel.textColor = .black
        scoreLabel.font = UIFont.systemFont(ofSize: 36)
        scoreLabel.text = "\(score)"
        view.addSubview(scoreLabel)
        
        kakiScoreNode = SKSpriteNode(imageNamed: "kakiscore.png")
        kakiScoreNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        kakiScoreNode.position = CGPoint(x: size.width - 140, y: size.height - 100)
        kakiScoreNode.setScale(0.25)
        addChild(kakiScoreNode)
        
        let groundNode = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 1))
        groundNode.position = CGPoint(x: size.width / 2, y: 0)
        addChild(groundNode)
        
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        groundNode.physicsBody?.collisionBitMask = 0
        groundNode.physicsBody?.contactTestBitMask = PhysicsCategory.kaki.rawValue
        groundNode.physicsBody?.isDynamic = false
        
        let generateDuration: TimeInterval = 3.0 // kakiやkokeraの生成にかかる時間

        let generateAction = SKAction.run { [weak self] in
            self?.generateImages()
        }

        let waitAction = SKAction.wait(forDuration: generateDuration)
        let sequenceAction = SKAction.sequence([generateAction, waitAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        run(repeatAction)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)
        let newX = touchLocation.x.clamped(to: playerBar.size.width / 2...size.width - playerBar.size.width / 2)
        playerBar.position.x = newX
    }
    
    func startKabukiCycle() {
        let appearDuration: TimeInterval = Double.random(in: 5...10)
        let disappearDuration: TimeInterval = Double.random(in: 3...5)
        
        let appearAction = SKAction.run { [weak self] in
            self?.kabukiUpperNode.isHidden = false
        }
        let waitAppearAction = SKAction.wait(forDuration: appearDuration)
        let disappearAction = SKAction.run { [weak self] in
            self?.kabukiUpperNode.isHidden = true
        }
        let waitDisappearAction = SKAction.wait(forDuration: disappearDuration)
        let sequenceAction = SKAction.sequence([appearAction, waitAppearAction, disappearAction, waitDisappearAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        run(repeatAction)
    }
    
    
    func generateImages() {
        let isKaki = Bool.random()
        
        // Check the count of kaki and use smaller version if more than or equals to 3
        let spriteName = (isKaki ? "kaki_" : "kokera_") + (kakiCount >= 2 ? "small" : "nomal")
        let sprite = SKSpriteNode(imageNamed: spriteName)
        
        let xRange = sprite.size.width / 2 + 25...size.width - sprite.size.width / 2 - 25
        let yRange = size.height - sprite.size.height / 2 - 100...size.height - sprite.size.height / 2
        
        let startX = CGFloat.random(in: xRange)
        let endX = CGFloat.random(in: xRange)
        let y = CGFloat.random(in: yRange)
        
        sprite.position = CGPoint(x: startX, y: y)
        sprite.name = isKaki ? "kaki" : "kokera"
        
        addChild(sprite)
        kakiList.append(sprite)
        
        let destinationY = -sprite.size.height / 2
        
        // Set different vertical move duration based on the kaki count
        var moveVerticalDuration: Double
        if kakiCount < 6 {
            moveVerticalDuration = 5.0
        } else if kakiCount < 10 {
            moveVerticalDuration = 3.0
        } else if kakiCount < 30 {
            moveVerticalDuration = 7.0
        } else if kakiCount < 40 {
            moveVerticalDuration = 5.0
        } else if kakiCount < 45 {
            moveVerticalDuration = 4.0
        } else if kakiCount < 50 {
            moveVerticalDuration = 3.5
        } else {
            moveVerticalDuration = 3.0
        }
        let moveVerticalAction = SKAction.moveTo(y: destinationY, duration: moveVerticalDuration)
        
        let moveAction = SKAction.moveTo(y: destinationY, duration: 6)
        let removeAction = SKAction.removeFromParent()
        var sequence: SKAction
        
        // Create sway action if kakiCount is more than or equals to 10
        if kakiCount >= 10 {
            let swayAction = createSwayAction(sprite: sprite)
            let combinedAction = SKAction.group([moveVerticalAction, swayAction])
            sequence = SKAction.sequence([combinedAction, removeAction])
        } else {
            sequence = SKAction.sequence([moveVerticalAction, removeAction])
        }
        
        // If 20 or more kakis are obtained, rotate the sprite and add sway action
        if kakiCount >= 20 {
            let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -CGFloat.pi...CGFloat.pi) * 2, duration: 0.5)
            let repeatForeverAction = SKAction.repeatForever(rotateAction)
            let swayAction = createSwayAction(sprite: sprite)
            let groupAction = SKAction.group([moveAction, repeatForeverAction, swayAction])
            sequence = SKAction.sequence([groupAction, removeAction])
        }
        
        sprite.run(sequence)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.categoryBitMask = isKaki ? PhysicsCategory.kaki.rawValue : PhysicsCategory.kokera.rawValue
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        sprite.physicsBody?.isDynamic = true
        
        sprite.physicsBody?.categoryBitMask = isKaki ? PhysicsCategory.kaki.rawValue : PhysicsCategory.kokera.rawValue
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue
    }

    func createSwayAction(sprite: SKSpriteNode) -> SKAction {
        // Define sway range from the center of the screen
        let swayRange: CGFloat = 150
        let leftBoundary = size.width / 2 - swayRange
        let rightBoundary = size.width / 2 + swayRange
        
        // Randomly choose initial sway direction
        let initialDirectionIsLeft = Bool.random()
        

        // Define duration for each side sway based on the kakiCount
        var SameDuration: CGFloat
        if kakiCount < 25 {
            SameDuration = 1.4
        } else if kakiCount < 35 {
            SameDuration = 1.1
        } else if kakiCount < 45 {
            SameDuration = 0.8
        } else {
            SameDuration = 0.5
        }
        
        let moveToLeft = SKAction.moveTo(x: leftBoundary, duration: TimeInterval(SameDuration))
        let moveToRight = SKAction.moveTo(x: rightBoundary, duration: TimeInterval(SameDuration))
        let moveToCenter = SKAction.moveTo(x: sprite.position.x, duration: TimeInterval(SameDuration))
        
        let swayActionPattern = initialDirectionIsLeft ?
            SKAction.sequence([moveToLeft, moveToRight, moveToCenter]) :
            SKAction.sequence([moveToRight, moveToLeft, moveToCenter])
        
        return SKAction.repeatForever(swayActionPattern)
    }




    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if contactMask == (PhysicsCategory.kaki.rawValue | PhysicsCategory.player.rawValue) {
            if contact.bodyA.node?.name == "kaki" {
                contact.bodyA.node?.removeFromParent()
                if let index = kakiList.firstIndex(of: contact.bodyA.node as! SKSpriteNode) {
                    kakiList.remove(at: index)
                }
            } else if contact.bodyB.node?.name == "kaki" {
                contact.bodyB.node?.removeFromParent()
                if let index = kakiList.firstIndex(of: contact.bodyB.node as! SKSpriteNode) {
                    kakiList.remove(at: index)
                }
            }
            // BGMファイルのURLを取得します
            guard let getseURL = Bundle.main.url(forResource: "getSE", withExtension: "mp3") else {
                print("BGMファイルが見つかりません")
                return
            }

            // BGMプレーヤーを作成してBGMを再生します
            do {
                getsePlayer = try AVAudioPlayer(contentsOf: getseURL)
                getsePlayer?.numberOfLoops = 0  // ループ再生を設定（-1は無限ループ）
                getsePlayer?.play()
            } catch {
                print("BGMの再生に失敗しました: \(error)")
            }
            score += 1
            kakiCount += 1 // Increment kaki to: sk.view, error: nil)
            
            // kabuki_upperの設定
            if kakiCount >= 15 {
                addChild(kabukiUpperNode)
                kabukiUpperNode.isHidden = false
                startKabukiCycle()
                
            }
            
        } else if contactMask == (PhysicsCategory.kokera.rawValue | PhysicsCategory.player.rawValue) {
            // kokeraとプレイヤーバーが接触した場合、endlessover_kokeraというStoryboard IDの画面に遷移
            failControlView(withIdentifier: "Endlessover_kokera")
        } else if contactMask == (PhysicsCategory.kaki.rawValue | PhysicsCategory.ground.rawValue) {
            // kakiと地面が接触した場合、endlessover_kakiというStoryboard IDの画面に遷移
            failControlView(withIdentifier: "Endlessover_kaki")
        }else if contactMask == (PhysicsCategory.kokera.rawValue | PhysicsCategory.ground.rawValue) {
            // kokeraと地面が接触した場合、kokeraを画面から消す
            if contact.bodyA.node?.name == "kokera" {
                contact.bodyA.node?.removeFromParent()
            } else if contact.bodyB.node?.name == "kokera" {
                contact.bodyB.node?.removeFromParent()
            }
        }
    }


    func failControlView(withIdentifier identifier: String) {
        let user = Auth.auth().currentUser
        let uid = user?.uid
        self.ref.child("user").child(uid!).child("EndlessScore").setValue(self.kakiCount)
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let failkokeraViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Endlessover_kokera_ViewController {
                failkokeraViewController.kakiCount = self.kakiCount // kakicount の値を渡す
                failkokeraViewController.modalPresentationStyle = .fullScreen
                
                // ナビゲーションスタックをクリアしてPush遷移
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([failkokeraViewController], animated: true)
                }
            }else if let failkakiViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Endlessover_kaki_ViewController {
                failkakiViewController.kakiCount = self.kakiCount // kakicount の値を渡す
                failkakiViewController.modalPresentationStyle = .fullScreen
                
                // ナビゲーションスタックをクリアしてPush遷移
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([failkakiViewController], animated: true)
                }
            }
        }
    }
}

