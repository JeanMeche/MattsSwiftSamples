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
            navigationController?.popViewControllerAnimated(true)
            print("")
        }
        title = DetailProvider.titleForIndex(sampleIndex)
        
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), forControlEvents: .TouchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func infoButtonTapped(sender:UIButton) {
        
    }
}

