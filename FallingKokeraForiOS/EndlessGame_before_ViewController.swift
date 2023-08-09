//
//  EndlessGame_before_ViewController.swift
//  FallingKokeraForiOS
//
//  Created by kouta yamaguchi on 2023/07/15.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseFirestore
import FirebaseDatabase

class EndlessGame_before_ViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var highScore: UILabel!
    var ref: DatabaseReference! = Database.database().reference()
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitle.font = UIFont(name: "Baskerville-Bold", size: 30)

        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
//        let user = Auth.auth().currentUser
//        let uid = user?.uid
        let uid = UserDefaults.standard.string(forKey: "userId")
        self.ref.child("user").child(uid!).getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            //ユーザー登録済
            let value = snapshot?.value as? [String: Any]
            let score = value?["EndlessScore"] as? Int
            self.highScore.text = "\(String(describing: score!))"
            print(score!)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
