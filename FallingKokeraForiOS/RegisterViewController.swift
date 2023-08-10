import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 既に登録済みの場合、登録画面をスキップしてメイン画面に遷移
        if let userId = UserDefaults.standard.string(forKey: "userId") {
            self.performSegue(withIdentifier: "toTop", sender: nil)
        } else {
            self.performSegue(withIdentifier: "toRegi2", sender: nil)
        }
    }

}
