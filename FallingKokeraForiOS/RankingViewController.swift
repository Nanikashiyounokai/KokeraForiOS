import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GoogleSignIn


class RankingViewController: UIViewController, UITableViewDataSource {
    
    var rankingData: [(userName: String, score: Int)] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        fetchRankingData()
        
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

        let data = rankingData[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1). \(data.userName)"
        cell.detailTextLabel?.text = "\(data.score) points"

        return cell
    }
    
}
