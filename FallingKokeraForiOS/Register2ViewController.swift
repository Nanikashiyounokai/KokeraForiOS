import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn

class Register2ViewController: UIViewController {

    @IBOutlet weak var inputName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                
                //実際の処理
                // FirestoreのUsersコレクションにdocumentID = ログインしたuidでデータを作成する
                Firestore.firestore().collection("users").document(uid!).setData([
                    "name": userName!,
                    "stage_point": "0",
                    "endless_point": "0"
                ], completion: { error in })
                
                let storyboard: UIStoryboard = self.storyboard!
                let next = storyboard.instantiateViewController(withIdentifier: "top") as! ViewController
                next.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(next, animated: true)

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
