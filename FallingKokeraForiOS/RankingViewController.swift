import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GoogleSignIn
import GoogleMobileAds


class RankingViewController: UIViewController, UITableViewDataSource, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageTitle2: UILabel!
    
    var rankingData: [(userName: String, score: Int)] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        fetchRankingData()
        pageTitle.font = UIFont(name: "Baskerville-Bold", size: 30)
        pageTitle2.font = UIFont(name: "Baskerville-Bold", size: 30)
        
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
    
    // データベースからランキングデータを取得するメソッド
    func fetchRankingData() {
        let ref = Database.database().reference().child("user").queryOrdered(byChild: "EndlessScore").queryLimited(toLast: 20)
        
        ref.observe(.value) { (snapshot) in
                    // Firebaseからデータが取得できた場合の処理
                    if let value = snapshot.value as? [String: Any] {
                        self.rankingData.removeAll()

                        for (_, data) in value {
                            if let userData = data as? [String: Any],
                                let userName = userData["Name"] as? String,
                                let score = userData["EndlessScore"] as? Int {
                                self.rankingData.append((userName: userName, score: score))
                            }
                        }

                        // スコアで降順にソート
                        self.rankingData.sort { $0.score > $1.score }

                        self.tableView.reloadData()
                    }
                }
    }
    
    // UITableViewDataSourceのメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cellUsername = cell.viewWithTag(1) as! UILabel
        let cellScore = cell.viewWithTag(2) as! UILabel

        let data = rankingData[indexPath.row]
        cellUsername.text = "\(indexPath.row + 1). \(data.userName)"
        cellScore.text = "\(data.score) p"

        return cell
    }
    
}
