import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GoogleSignIn

class Register2ViewController: UIViewController {
    
    //var ref: DatabaseReference! = Database.database().reference()

    @IBOutlet weak var inputName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 既に登録済みの場合、登録画面をスキップしてメイン画面に遷移
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            self.performSegue(withIdentifier: "toTop2", sender: nil)
        }

    }
    
    @IBAction func tapButton(_ sender: Any) {
        let user = Auth.auth().currentUser
        let uid = user?.uid

        let userName = inputName.text
        
        if userName == "" {
            let alert: UIAlertController = UIAlertController(title: "ユーザー名を入力して下さい", message: "", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let checkAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(checkAction)
            present(alert, animated: true, completion: nil)
        } else if userName!.count > 10 {
            let alert: UIAlertController = UIAlertController(title: "ユーザー名は10文字以下で入力して下さい", message: "", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let checkAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(checkAction)
            present(alert, animated: true, completion: nil)
            
        } else {
            let alert: UIAlertController = UIAlertController(title: "ユーザー名: \(userName ?? "")", message: "", preferredStyle:  UIAlertController.Style.alert)
            // 確定ボタンの処理
            let confirmAction: UIAlertAction = UIAlertAction(title: "保存", style: UIAlertAction.Style.default, handler:{
                // 確定ボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                
                // RealtimeDatabaseにユーザー情報を登録
//                self.ref.child("user").child(uid!).setValue(
//                    ["EndlessScore": 0,
//                    "Name": userName!,
//                     "StageScore": 0] as [String : Any])
//                print("登録完了")
            
                let usersRef = Database.database().reference().child("user")
                let newUserId = usersRef.childByAutoId().key
                print(newUserId)
                    
                usersRef.child(newUserId!).setValue(
                    ["EndlessScore": 0,
                    "Name": userName!,
                     "StageScore": 0] as [String : Any]){ error, _ in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                    } else {
                        print("User data saved successfully.")
                        //端末内にユーザーIDを保存
                        UserDefaults.standard.set(newUserId, forKey: "userId")
                        self.performSegue(withIdentifier: "toTop2", sender: nil)
                    }
                }
                

            })
            // キャンセルボタンの処理
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // キャンセルボタンが押された時の処理をクロージャ実装する
                (action: UIAlertAction!) -> Void in
                
            })
            //UIAlertControllerにキャンセルボタンと確定ボタンをActionを追加
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
        
        
    
    }


}
