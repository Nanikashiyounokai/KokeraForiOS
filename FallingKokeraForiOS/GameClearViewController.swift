//
//  ClearViewController.swift
//  FallingKokeraForiOS
//


import UIKit
import AVFAudio

class ClearViewController: UIViewController {
    
    var successSoundPlayer: AVAudioPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // BGM再生を停止します
        bgmPlayer?.stop()
        
        // "successse.mp3"ファイルのURLを取得します
        guard let successSoundURL = Bundle.main.url(forResource: "successse", withExtension: "mp3") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        // 音声プレーヤーを作成して音声を再生します
        do {
            successSoundPlayer = try AVAudioPlayer(contentsOf: successSoundURL)
            successSoundPlayer?.numberOfLoops = 0  // ループ再生を設定しない（1回のみ再生）
            successSoundPlayer?.play()
        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
