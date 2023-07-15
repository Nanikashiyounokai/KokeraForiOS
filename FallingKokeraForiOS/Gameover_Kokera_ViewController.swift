//
//  Gameover_Kokera_ViewController.swift
//  FallingKokeraForiOS
//
//  Created by 福岡　佑季 on 2023/06/17.
//

import UIKit
import AVFAudio

class Gameover_Kokera_ViewController: UIViewController {
    
    var failureSoundPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // BGM再生を停止します
        bgmPlayer?.stop()
        
        guard let successSoundURL = Bundle.main.url(forResource: "failurese", withExtension: "mp3") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        // 音声プレーヤーを作成して音声を再生します
        do {
            failureSoundPlayer = try AVAudioPlayer(contentsOf: successSoundURL)
            failureSoundPlayer?.numberOfLoops = 0  // ループ再生を設定しない（1回のみ再生）
            failureSoundPlayer?.play()
        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
    }

    @IBAction func retry(_ sender: Any) {
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
   
