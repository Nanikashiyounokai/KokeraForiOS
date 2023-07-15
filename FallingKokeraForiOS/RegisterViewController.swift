//
//  RegisterController.swift
//  Pods
//
//  Created by USER on 2023/07/02.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn


class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ユーザーが以前にサインインしていた場合は、アカウント登録画面をスキップ
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
                    if let error = error {
                        // エラーハンドリング
                        print("エラー: \(error.localizedDescription)")
                        return
                    }
                
                    // ユーザー名が登録されているか判定
                    if let data = snapshot?.data() {
                        let userName = data["name"] as? String
                        print("ユーザー名: \(userName ?? "")")
                        let storyboard: UIStoryboard = self.storyboard!
                        let next = storyboard.instantiateViewController(withIdentifier: "top") as! ViewController
                        next.modalPresentationStyle = .fullScreen
                        self.present(next, animated: true, completion: nil)
                        
                    } else {
                        // データが存在しない場合の処理
                        print("ユーザー名が登録されていません")
                        let storyboard: UIStoryboard = self.storyboard!
                        let next = storyboard.instantiateViewController(withIdentifier: "Register2ViewController") as! Register2ViewController
                        self.present(next, animated: true, completion: nil)
                    }
                }
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
                        let storyboard: UIStoryboard = self.storyboard!
                        let next = storyboard.instantiateViewController(withIdentifier: "Register2ViewController") as! Register2ViewController
                        self.present(next, animated: true, completion: nil)
                    }
                }
    }
    

}
