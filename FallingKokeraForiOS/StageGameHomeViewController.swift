import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GoogleMobileAds

class StageViewController: UIViewController, GADBannerViewDelegate {
    
    var ref: DatabaseReference! = Database.database().reference()
    var bannerView: GADBannerView!
    var stagePoint:Int = 0
    
    @IBOutlet weak var selectStage: UILabel!
    @IBOutlet weak var stageButton1: UIButton!
    @IBOutlet weak var stageButton2: UIButton!
    @IBOutlet weak var stageButton3: UIButton!
    @IBOutlet weak var stageButton4: UIButton!
    @IBOutlet weak var stageButton5: UIButton!
    @IBOutlet weak var stageButton6: UIButton!
    @IBOutlet weak var stageButton7: UIButton!
    @IBOutlet weak var stageButton8: UIButton!
    @IBOutlet weak var stageButton9: UIButton!
    
    @IBOutlet weak var key2: UIImageView!
    @IBOutlet weak var key3: UIImageView!
    @IBOutlet weak var key4: UIImageView!
    @IBOutlet weak var key5: UIImageView!
    @IBOutlet weak var key6: UIImageView!
    @IBOutlet weak var key7: UIImageView!
    @IBOutlet weak var key8: UIImageView!
    @IBOutlet weak var key9: UIImageView!
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        selectStage.font = UIFont(name: "Baskerville-Bold", size: 30)
        
        //StagePintに対応したボタンの非活性設定
        let uid = UserDefaults.standard.string(forKey: "userId")
        self.ref.child("user").child(uid!).getData(completion: { error, snapshot in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            //ユーザーのStagePoint取得
            if let dic = snapshot?.value as? [String:AnyObject]{
                self.stagePoint = dic["StageScore"] as? Int ?? 0
                
                //鍵iconの表示/非表示
                if self.stagePoint >= 1 {
                    self.key2.isHidden = true
                }
                if self.stagePoint >= 2 {
                    self.key3.isHidden = true
                }
                if self.stagePoint >= 3 {
                    self.key4.isHidden = true
                }
                if self.stagePoint >= 4 {
                    self.key5.isHidden = true
                }
                if self.stagePoint >= 5 {
                    self.key6.isHidden = true
                }
                if self.stagePoint >= 6 {
                    self.key7.isHidden = true
                }
                if self.stagePoint >= 7 {
                    self.key8.isHidden = true
                }
                if self.stagePoint >= 8 {
                    self.key9.isHidden = true
                }
                
                //ボタンの活性/非活性
                if self.stagePoint < 1 {
                    self.stageButton2.isEnabled = false
                }
                if self.stagePoint < 2 {
                    self.stageButton3.isEnabled = false
                }
                if self.stagePoint < 3 {
                    self.stageButton4.isEnabled = false
                }
                if self.stagePoint < 4 {
                    self.stageButton5.isEnabled = false
                }
                if self.stagePoint < 5 {
                    self.stageButton6.isEnabled = false
                }
                if self.stagePoint < 6 {
                    self.stageButton7.isEnabled = false
                }
                if self.stagePoint < 7 {
                    self.stageButton8.isEnabled = false
                }
                if self.stagePoint < 8 {
                    self.stageButton9.isEnabled = false
                }
                
            }
        })
        
        
        
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
    
}
