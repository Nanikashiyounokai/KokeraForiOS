import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GoogleSignIn

class Stage2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        let scene = StageScene2(size: skView.bounds.size)
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

class StageScene2: SKScene, SKPhysicsContactDelegate {
    var ref: DatabaseReference! = Database.database().reference()
    var player: AVAudioPlayer?
    var getsePlayer: AVAudioPlayer?
    var playerBar: SKSpriteNode!
    var scoreLabel: UILabel!
    var kakiScoreNode: SKSpriteNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)/1"
            }
    }
    
    var kakiList: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
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
        scoreLabel.text = "\(score)/1"
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
        
        let waitAction = SKAction.wait(forDuration: 1.5)
        let generateAction = SKAction.run { [weak self] in
            self?.generateImages()
        }
        let sequence: SKAction = SKAction.sequence([waitAction, generateAction])
        run(sequence)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)
        let newX = touchLocation.x.clamped(to: playerBar.size.width / 2...size.width - playerBar.size.width / 2)
        playerBar.position.x = newX
    }
    
    func generateImages() {
        let kaki = SKSpriteNode(imageNamed: "kaki_nomal")
        let kokera = SKSpriteNode(imageNamed: "kokera_nomal")
        
        let startX: CGFloat
        let endX: CGFloat
        if Bool.random() {
            startX = kaki.size.width / 2 + 25
            endX = size.width - kaki.size.width / 2 - 25
        } else {
            startX = size.width - kaki.size.width / 2 - 25
            endX = kaki.size.width / 2 + 25
        }
        
        let y = size.height - kaki.size.height / 2
        
        kaki.position = CGPoint(x: startX, y: y)
        kokera.position = CGPoint(x: endX, y: y)
        
        kaki.name = "kaki"
        kokera.name = "kokera"
        
        addChild(kaki)
        addChild(kokera)
        
        kakiList.append(kaki)
        
        let destinationY = -kaki.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        
        kaki.run(sequence)
        kokera.run(sequence)
        
        kaki.physicsBody = SKPhysicsBody(rectangleOf: kaki.size)
        kaki.physicsBody?.categoryBitMask = PhysicsCategory.kaki.rawValue
        kaki.physicsBody?.collisionBitMask = 0
        kaki.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kaki.physicsBody?.isDynamic = true
        
        kokera.physicsBody = SKPhysicsBody(rectangleOf: kokera.size)
        kokera.physicsBody?.categoryBitMask = PhysicsCategory.kokera.rawValue
        kokera.physicsBody?.collisionBitMask = 0
        kokera.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        kokera.physicsBody?.isDynamic = true
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
            
            if score >= 1 {
                // スコアが1になったら、gameclearというStoryboard IDの画面に遷移
                clearControlView()
            }
        } else if contactMask == (PhysicsCategory.kokera.rawValue | PhysicsCategory.player.rawValue) {
            // kokeraとプレイヤーバーが接触した場合、gameover_kokeraというStoryboard IDの画面に遷移
            failControlView(withIdentifier: "gameover_kokera")
        } else if contactMask == (PhysicsCategory.kaki.rawValue | PhysicsCategory.ground.rawValue) {
            // kakiと地面が接触した場合、gameover_kakiというStoryboard IDの画面に遷移
            failControlView(withIdentifier: "gameover_kaki")
        }
    }
    
    func clearControlView() {
        let user = Auth.auth().currentUser
        let uid = user?.uid
        self.ref.child("user").child(uid!).child("StageScore").setValue(2)
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let clearViewController = storyboard.instantiateViewController(withIdentifier: "gameclear") as? ClearViewController {
                clearViewController.sourceStage = 2
                clearViewController.modalPresentationStyle = .fullScreen
                
                // ナビゲーションスタックをクリアしてPush遷移
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([clearViewController], animated: true)
                }
            }
        }
    }

    func failControlView(withIdentifier identifier: String) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let failViewControllerKokera = storyboard.instantiateViewController(withIdentifier: identifier) as? Gameover_Kokera_ViewController {
                failViewControllerKokera.sourceStage = 2
                failViewControllerKokera.modalPresentationStyle = .fullScreen
                
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([failViewControllerKokera], animated: true)
                }
            } else if let failViewControllerKaki = storyboard.instantiateViewController(withIdentifier: identifier) as? Gameover_Kaki_ViewController {
                failViewControllerKaki.sourceStage = 2
                failViewControllerKaki.modalPresentationStyle = .fullScreen
                
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([failViewControllerKaki], animated: true)
                }
            } else {
                print("Failed to instantiate ViewControllers from storyboard.")
            }
        }
    }
}
