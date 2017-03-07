//
//  FlappyViewController.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 02/08/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import SpriteKit

class FlappyViewController: DetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else { return }
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let flappyScene = FlappyScene(size: skView.bounds.size)
        skView.presentScene(flappyScene)
    }
    
    override var shouldAutorotate:Bool { return true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
