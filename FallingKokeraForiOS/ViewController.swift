import UIKit
import SpriteKit
import AVFoundation
import GoogleMobileAds


var bgmPlayer: AVAudioPlayer?

class ViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addBackgroundView()
        // BGMファイルのURLを取得します
        guard let bgmURL = Bundle.main.url(forResource: "opbgm", withExtension: "mp3") else {
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
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }

          func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            view.addConstraints(
              [NSLayoutConstraint(item: bannerView,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: view.safeAreaLayoutGuide,
                                  attribute: .bottom,
                                  multiplier: 1,
                                  constant: 0),
               NSLayoutConstraint(item: bannerView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
              ])
           }
    
    func addBackgroundView() {
        let skView = SKView(frame: view.bounds)
        skView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(skView, at: 0)
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
          UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
          })
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }

}

class GameScene: SKScene {
    
    private var backgroundNode: SKSpriteNode!
    private var isGeneratingImages = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        // 背景ノードを追加
        backgroundNode = SKSpriteNode(color: .clear, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(backgroundNode)
        
        // 最初の画像を生成
        generateImages()
    }
    
    func generateImages() {
        // 画像生成中であれば処理を終了
        guard !isGeneratingImages else { return }
        isGeneratingImages = true
        
        let isKaki = Bool.random()
        
        let spriteName = isKaki ? "kaki_small" : "kokera_small"
        let sprite = SKSpriteNode(imageNamed: spriteName)
        
        let xRange = sprite.size.width / 2...size.width - sprite.size.width / 2
        let y = size.height + sprite.size.height / 2
        
        sprite.position = CGPoint(x: CGFloat.random(in: xRange), y: y)
        backgroundNode.addChild(sprite)
        
        let destinationY = -size.height / 2 - sprite.size.height / 2
        let moveAction = SKAction.moveTo(y: destinationY, duration: 3)
        let removeAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveAction, removeAction])
        
        sprite.run(sequence) {
            sprite.removeFromParent()
            self.isGeneratingImages = false
            // 一定の時間後に再度画像を生成
            self.run(SKAction.wait(forDuration: 0.5)) {
                self.generateImages()
            }
        }
    }
}

