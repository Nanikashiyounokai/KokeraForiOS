import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class EndlessGameController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        let scene = EndlessGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}

class EndlessGameScene: SKScene, SKPhysicsContactDelegate {
    
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
        
        let generateDuration: TimeInterval = 5.0 // kakiやkokeraの生成にかかる時間

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
    
    func generateImages() {
        let isKaki = Bool.random()

        // Check the count of kaki and use smaller version if more than or equals to 3
        let spriteName = (isKaki ? "kaki_" : "kokera_") + (kakiCount >= 3 ? "small" : "nomal")
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
        let moveAction = SKAction.moveTo(y: destinationY, duration: 6)
        let removeAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])

        sprite.run(sequence)

        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.categoryBitMask = isKaki ? PhysicsCategory.kaki.rawValue : PhysicsCategory.kokera.rawValue
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.player.rawValue
        sprite.physicsBody?.isDynamic = true
        
        sprite.physicsBody?.categoryBitMask = isKaki ? PhysicsCategory.kaki.rawValue : PhysicsCategory.kokera.rawValue
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.ground.rawValue
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
            score += 1
            kakiCount += 1 // Increment kaki count
            
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
    
    func clearControlView() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let clearViewController = storyboard.instantiateViewController(withIdentifier: "gameclear") as? UIViewController {
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
            if let failViewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
                failViewController.modalPresentationStyle = .fullScreen
                
                // ナビゲーションスタックをクリアしてPush遷移
                if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                    navigationController.setViewControllers([failViewController], animated: true)
                }
            }
        }
    }
}

