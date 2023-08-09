//
//  RegisterController.swift
//  Pods
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import GoogleSignIn


class RegisterViewController: UIViewController {

    var ref: DatabaseReference! = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // ユーザーが以前にサインインしていた場合は、アカウント登録画面をスキップ
        if let uid = Auth.auth().currentUser?.uid {
            self.ref.child("user").child(uid).getData(completion: { error, snapshot in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                //ユーザー登録済
                if snapshot?.value is [String:AnyObject]{
                    self.performSegue(withIdentifier: "toTop", sender: nil)
                } else {
                    //ユーザー未登録
                    print("ユーザー名が登録されていません")
                    self.performSegue(withIdentifier: "toRegister2", sender: nil)
                }
            })
        }
        
    }
    
    
    @IBAction func didTappSignInButton(_ sender: Any) {
        auth()
    }
    
    private func auth() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("GIDSignInError: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            self.login(credential: credential)
        }
    }
    
    private func login(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Google SignIn Success!")
                        //成功した場合は画面遷移を行う
                        self.performSegue(withIdentifier: "toRegister2", sender: nil)
                    }
                }
    }
    

}
