//
//  DetailViewController.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 25/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var sampleIndex:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if sampleIndex == nil {
            _ = navigationController?.popViewController(animated: true)
        }
        title = DetailProvider.titleForIndex(sampleIndex)
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func infoButtonTapped(_ sender:UIButton) {
        
    }
}

