//
//  ClearViewController.swift
//  FallingKokeraForiOS
//


import UIKit

class ClearViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func home(_ sender: Any) {
    
        dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let topViewController = storyboard.instantiateViewController(withIdentifier: "top") as? UIViewController {
                topViewController.modalPresentationStyle = .fullScreen
                
                // 現在のウィンドウシーンを取得
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let delegate = windowScene.delegate as? SceneDelegate,
                   let window = delegate.window {
                    // ナビゲーションコントローラーを作成し、ルートビューコントローラーに設定
                    let navigationController = UINavigationController(rootViewController: topViewController)
                    window.rootViewController = navigationController
                }
            }
        }
    }
}

