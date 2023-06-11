import UIKit
import SpriteKit

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

class StageScene: SKScene {

    var playerBar: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var kakiList: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .white

        // プレイヤーバーを生成して配置
        playerBar = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 10))
        playerBar.position = CGPoint(x: size.width / 2, y: 100)
        addChild(playerBar)

        // スコアラベルを生成して配置
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(scoreLabel)

        // 画像を生成して配置する処理
        generateImages()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)
        let newX = touchLocation.x.clamped(to: playerBar.size.width / 2...size.width - playerBar.size.width / 2)
        playerBar.position.x = newX
        
        checkCollision()
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
        let moveAction = SKAction.moveTo(y: destinationY, duration: 3)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])

        kaki.run(sequence)
        kokera.run(sequence)
    }

    func checkCollision() {
        for kaki in kakiList {
            if kaki.intersects(playerBar) {
                score += 1
                kaki.removeFromParent()
                if let index = kakiList.firstIndex(of: kaki) {
                    kakiList.remove(at: index)
                }
            }
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

