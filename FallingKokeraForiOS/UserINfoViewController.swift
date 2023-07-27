//
//  UserINfoViewController.swift
//  FallingKokeraForiOS
//
//  Created by USER on 2023/07/27.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase

class UserINfoViewController: UIViewController {

    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var stageScore: UILabel!
    @IBOutlet weak var endlessScore: UILabel!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var stageScorelabel: UILabel!
    @IBOutlet weak var endlessScorelabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfo.font = UIFont(name: "Baskerville-Bold", size: 30)
        userName.font = UIFont(name: "Baskerville", size: 20)
        stageScore.font = UIFont(name: "Baskerville", size: 20)
        endlessScore.font = UIFont(name: "Baskerville", size: 20)
        
        // Realtime Databaseの参照を取得
        ref = Database.database().reference()
        
        // ユーザー情報を表示
        loadUserData()
    }
    
    // ユーザー情報をRealtime Databaseから読み込む
   func loadUserData() {
       // ユーザーIDを適切に設定する（例えばログインしているユーザーのIDなど）
       let user = Auth.auth().currentUser
       let userId = user?.uid
       
       // "users"ノード内のユーザー情報を取得
       self.ref.child("user").child(userId!).getData(completion: { error, snapshot in
           guard error == nil else {
               print(error!.localizedDescription)
               return
           }
           if let userData = snapshot?.value as? [String: Any], let userName = userData["Name"] as? String, let stageScore = userData["StageScore"] as? Int, let endlessScore = userData["EndlessScore"] as? Int{
               self.userNamelabel.text = userName
               self.stageScorelabel.text = "\(stageScore)"
               self.endlessScorelabel.text = "\(endlessScore)"
               
           } else {
               print("User data not found in the database")
           }
       })
       
   }

    @IBAction func editBUttonTapped(_ sender: Any) {
        // ポップアップを表示してユーザー名を入力
        let alertController = UIAlertController(title: "ユーザー名の変更", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "New User Name"
        }

        let updateAction = UIAlertAction(title: "変更", style: .default) { (_) in
            if let newUserName = alertController.textFields?[0].text {
                // Realtime Databaseにユーザー名を保存
                self.updateUserName(newUserName)
            }
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    // ユーザー名をRealtime Databaseに保存
    func updateUserName(_ newUserName: String) {
        // ユーザーIDを適切に設定する（例えばログインしているユーザーのIDなど）
        let user = Auth.auth().currentUser
        let userId = user?.uid

        // "users"ノード内のユーザー名を更新
        self.ref.child("user").child(userId!).child("Name").setValue(newUserName) { (error, _) in
            if let error = error {
                print("ユーザー名の更新エラー: \(error.localizedDescription)")
            } else {
                print("ユーザー名が正常に更新されました！")
                self.userNamelabel.text = newUserName // UI上でも変更を反映する
            }
        }
    }
    
}
