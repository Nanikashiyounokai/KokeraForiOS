//
//  EndlessGameViewController.swift
//  FallingKokeraForiOS
//
//  Created by 福岡　佑季 on 2023/05/12.
//
import UIKit
import SpriteKit

class EndlessGameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SKViewを作成してビューに追加する
        let skView = SKView(frame: view.frame)
        skView.showsFPS = true // FPSの表示（デバッグ用）
        skView.showsNodeCount = true // ノード数の表示（デバッグ用）
        view.addSubview(skView)
        
        // ゲームシーンを作成してSKViewに設定する
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
      
        // SKViewにGameSceneを追加
        skView.presentScene(scene)
                
        // ViewControllerのviewにSKViewを追加
        view.addSubview(skView)
    }
}
