//
//  Endlessover_kokera_ViewController.swift
//  FallingKokeraForiOS
//
//  Created by kouta yamaguchi on 2023/07/02.
//

import UIKit

class Endlessover_kokera_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var result: UILabel!
    
    @IBAction func retry(_ sender: Any) {
        dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let topViewController = storyboard.instantiateViewController(withIdentifier: "Endless") as? UIViewController {
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
