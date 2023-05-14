import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let fruitCategory: UInt32 = 0x1 << 0
    let barCategory: UInt32 = 0x1 << 1
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let fruitFallSpeed: CGFloat = 200.0 // 果物の落下速度
    let fruitMoveSpeed: CGFloat = 100.0 // 果物の横方向の移動速度
    
    var bar: SKSpriteNode!
    
    override func didMove(to view: SKView) {
            backgroundColor = SKColor.white
            
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            physicsWorld.contactDelegate = self
            
            bar = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 200, height: 20))
            bar.position = CGPoint(x: size.width / 2, y: bar.size.height)
            bar.physicsBody = SKPhysicsBody(rectangleOf: bar.size)
            bar.physicsBody?.isDynamic = false
            bar.physicsBody?.categoryBitMask = barCategory
            bar.name = "bar" // バーに名前を付ける
            addChild(bar)
            
            scoreLabel = SKLabelNode(text: "Score: 0")
            scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
            scoreLabel.fontName = "HelveticaNeue-Bold"
            scoreLabel.fontSize = 24
            scoreLabel.fontColor = SKColor.black
            addChild(scoreLabel)
            
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(spawnFruit),
                    SKAction.wait(forDuration: 1.0)
                ])
            ))
        }
    
    func spawnFruit() {
        let randomIndex = Int(arc4random_uniform(2))
        let fruits = ["柿", "桃"]
        let fruitNode = SKLabelNode(text: fruits[randomIndex])
        fruitNode.position = CGPoint(x: randomXPosition(), y: size.height)
        fruitNode.fontSize = 30
        fruitNode.fontColor = SKColor.black
        fruitNode.physicsBody = SKPhysicsBody(rectangleOf: fruitNode.frame.size)
        fruitNode.physicsBody?.isDynamic = true
        fruitNode.physicsBody?.categoryBitMask = fruitCategory
        fruitNode.physicsBody?.contactTestBitMask = barCategory
        fruitNode.physicsBody?.collisionBitMask = 0
        addChild(fruitNode)
        
        fruitNode.physicsBody?.velocity = CGVector(dx: 0, dy: -fruitFallSpeed)
        fruitNode.physicsBody?.linearDamping = 0 // 落下速度の減衰を無効化
    }
    
    func randomXPosition() -> CGFloat {
        let leftMargin = size.width / 6
        let rightMargin = size.width - leftMargin
        return CGFloat.random(in: leftMargin...rightMargin)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
           for touch in touches {
               let location = touch.location(in: self)
               let action = SKAction.moveTo(x: location.x, duration: 0.1)
               bar.run(action)
           }
       }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask
        if contactMask == fruitCategory {
            // 接触したのが果物の場合
            let fruitNode = contact.bodyA.node as! SKLabelNode
            fruitNode.removeFromParent()
            
            if fruitNode.text == "柿" {
                score += 10
            } else if fruitNode.text == "桃" {
                score -= 10
            }
        } else if contactMask == barCategory {
            // 接触したのがバーの場合
            let fruitNode = contact.bodyB.node as! SKLabelNode
            fruitNode.removeFromParent()
            
            if fruitNode.text == "柿" {
                score += 10
            } else if fruitNode.text == "桃" {
                score -= 10
            }
        }
    }
}

