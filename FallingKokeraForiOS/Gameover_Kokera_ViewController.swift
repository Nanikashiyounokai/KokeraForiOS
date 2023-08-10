import UIKit
import AVFAudio
import GoogleMobileAds

class Gameover_Kokera_ViewController: UIViewController , GADBannerViewDelegate {
    var sourceStage: Int? // ここに遷移元のステージ番号をセットします
    @IBOutlet weak var numberLabel: UIImageView!
    @IBOutlet weak var sorryLabel: UILabel!
    
    var bannerView: GADBannerView!
    
    var failureSoundPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-2529783942153390/4905656710"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // BGM再生を停止します
        bgmPlayer?.stop()
        
        guard let successSoundURL = Bundle.main.url(forResource: "failurese", withExtension: "mp3") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        // 音声プレーヤーを作成して音声を再生します
        do {
            failureSoundPlayer = try AVAudioPlayer(contentsOf: successSoundURL)
            failureSoundPlayer?.numberOfLoops = 0  // ループ再生を設定しない（1回のみ再生）
            failureSoundPlayer?.play()
        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
        
        //画像のセット
        sorryLabel.font = UIFont(name: "Baskerville-Bold", size: 60)
        if sourceStage == 1 {
            numberLabel.image = UIImage(named:"one")!
        }
        if sourceStage == 2 {
            numberLabel.image = UIImage(named:"two")!
        }
        if sourceStage == 3 {
            numberLabel.image = UIImage(named:"three")!
        }
        if sourceStage == 4 {
            numberLabel.image = UIImage(named:"four")!
        }
        if sourceStage == 5 {
            numberLabel.image = UIImage(named:"five")!
        }
        if sourceStage == 6 {
            numberLabel.image = UIImage(named:"six")!
        }
        if sourceStage == 7 {
            numberLabel.image = UIImage(named:"seven")!
        }
        if sourceStage == 8 {
            numberLabel.image = UIImage(named:"eight")!
        }
        if sourceStage == 9 {
            numberLabel.image = UIImage(named:"nine")!
        }
    }

    @IBAction func retry(_ sender: Any) {
        switch sourceStage {
        case 1:
            // Stage2ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let stage1VC = storyboard.instantiateViewController(withIdentifier: "stage1") as? Stage1ViewController {
                navigationController?.pushViewController(stage1VC, animated: true)
            }
        case 2:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage2VC = storyboard.instantiateViewController(withIdentifier: "stage2") as? Stage3ViewController {
                navigationController?.pushViewController(stage2VC, animated: true)
            }
        case 3:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage3VC = storyboard.instantiateViewController(withIdentifier: "stage3") as? Stage3ViewController {
                navigationController?.pushViewController(stage3VC, animated: true)
            }
        case 4:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage4VC = storyboard.instantiateViewController(withIdentifier: "stage4") as? Stage4ViewController {
                navigationController?.pushViewController(stage4VC, animated: true)
            }
        case 5:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage5VC = storyboard.instantiateViewController(withIdentifier: "stage5") as? Stage5ViewController {
                navigationController?.pushViewController(stage5VC, animated: true)
            }
        case 6:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage6VC = storyboard.instantiateViewController(withIdentifier: "stage6") as? Stage6ViewController {
                navigationController?.pushViewController(stage6VC, animated: true)
            }
        case 7:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage7VC = storyboard.instantiateViewController(withIdentifier: "stage7") as? Stage7ViewController {
                navigationController?.pushViewController(stage7VC, animated: true)
            }
        case 8:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage8VC = storyboard.instantiateViewController(withIdentifier: "stage8") as? Stage8ViewController {
                navigationController?.pushViewController(stage8VC, animated: true)
            }
        case 9:
            // Stage3ViewControllerに遷移するコード
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let stage9VC = storyboard.instantiateViewController(withIdentifier: "stage9") as? Stage9ViewController {
                navigationController?.pushViewController(stage9VC, animated: true)
            }
        default:
            break
        }
    }
    

    @IBAction func home(_ sender: Any) {
        dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let topViewController = storyboard.instantiateViewController(withIdentifier: "top") as? UIViewController {
                topViewController.modalPresentationStyle = .fullScreen
                
                // 現在のウィンドウシーンを取得
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let delegate = windowScene.delegate as? SceneDelegate,
                   let window = delegate.window {
                    // ナビゲーションコントローラーを作成し、ルートビューコントローラーに設定
                    let navigationController = UINavigationController(rootViewController: topViewController)
                    window.rootViewController = navigationController
                }
            }
        }
    }
}
   
