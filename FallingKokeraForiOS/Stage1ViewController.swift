import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class Stage1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // SpriteKitのSKViewを生成して追加
        let skView = SKView(frame: view.bounds)
        view.addSubview(skView)

        // SKSceneを生成してSKViewに設定
        let scene = StageScene(size: skView.bounds.size)
        skView.presentScene(scene)
    }
}

class StageScene: SKScene, SKPhysicsContactDelegate {

    var playerBar: SKSpriteNode!
    var scoreLabel: UILabel!
    var kakiScoreNode: SKSpriteNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)/1"
            if score >= 1 {
                clearControlView()
            }
        }
    }

    var kakiList: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .white

        // 物理ワールドの設定
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // 重力を無効化

        // プレイヤーバーを生成して配置
        playerBar = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 10))
        playerBar.position = CGPoint(x: size.width / 2, y: 100)
        addChild(playerBar)

        // プレイヤーバーに物理ボディを追加
        playerBar.physicsBody = SKPhysicsBody(rectangleOf: playerBar.size)
        playerBar.physicsBody?.categoryBitMask = PhysicsCategory.player.rawValue
        playerBar.physicsBody?.collisionBitMask = 0
        playerBar.physicsBody?.contactTestBitMask = PhysicsCategory.kaki.rawValue | PhysicsCategory.kokera.rawValue
        playerBar.physicsBody?.isDynamic = false

        // scoreLabelの位置を修正
        // スコアラベルをストーリーボード上に配置
        scoreLabel = UILabel()
        scoreLabel.frame = CGRect(x: size.width - 70, y: 65, width: 200, height: 70) // 修正：X座標の位置を変更
        scoreLabel.textColor = .black
        scoreLabel.font = UIFont.systemFont(ofSize: 36)
        scoreLabel.text = "\(score)/1"
        view.addSubview(scoreLabel)

        // kakiscore.pngを表示するSKSpriteNodeを生成して配置
        kakiScoreNode = SKSpriteNode(imageNamed: "kakiscore.png")
        kakiScoreNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        kakiScoreNode.position = CGPoint(x: size.width - 140, y: size.height - 100) // 修正：Y座標の位置を変更
        kakiScoreNode.setScale(0.25) // サイズを0.25倍に設定
        addChild(kakiScoreNode)

        // 画像を生成して配置する処理
        generateImages()
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

        let startX = kaki.size.width / 2
        let endX = size.width - kaki.size.width / 2
        let y = size.height - kaki.size.height / 2

        kaki.position = CGPoint(x: startX, y: y)
        kokera.position = CGPoint(x: endX, y: y)

        kaki.name = "kaki"
        kokera.name = "kokera"

        addChild(kaki)
        addChild(kokera)

        kakiList.append(kaki)

        let destinationY = -kaki.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 6)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])

        kaki.run(sequence)
        kokera.run(sequence)

        // kakiとkokeraに物理ボディを追加
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
            score += 1

            if score >= 1 {
                clearControlView()
            }
        }
    }

    func clearControlView() {
        let clearControlViewController = ClearControlViewController()
        clearControlViewController.modalPresentationStyle = .fullScreen
        self.view?.window?.rootViewController?.present(clearControlViewController, animated: true, completion: nil)
    }

    func failControlView() {
        let failControlViewController = FailControlViewController()
        failControlViewController.modalPresentationStyle = .fullScreen
        self.view?.window?.rootViewController?.present(failControlViewController, animated: true, completion: nil)
    }
}

enum PhysicsCategory: UInt32 {
    case player = 1
    case kaki = 2
    case kokera = 4
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

class ClearControlViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // ClearControlViewの実装
        view.backgroundColor = .green

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.center = view.center
        label.textAlignment = .center
        label.text = "Clear!"
        label.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(label)
    }
}

class FailControlViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // FailControlViewの実装
        view.backgroundColor = .red

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.center = view.center
        label.textAlignment = .center
        label.text = "Fail!"
        label.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(label)
    }
}

