//
//  DetailProvider.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 25/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

class DetailProvider {
    
    static var storyboards = [
        (name:"SparkButton", label:"Spark Button"),
        (name:"TokenInput", label:"Token Input"),
        (name:"FlappyBird", label:"Flappy Bird")
    ]

    class func viewControllerForIndex(index:Int) -> DetailViewController? {
        guard index >= 0 && index < storyboards.count else { return nil }
        
        let storyboard = UIStoryboard(name: storyboards[index].name, bundle: nil)
        let initialVC = storyboard.instantiateInitialViewController()
        if initialVC == nil {
            fatalError("No initial ViewController for Storyboard \(storyboards[index].name)")
        }
        let detailVC = initialVC as? DetailViewController
        if detailVC == nil {
            fatalError("View Controller is not of class DetailViewController")
        }
        detailVC?.sampleIndex = index
        return detailVC
    }
    
    class func hasDetailForIndex(index:Int) -> Bool {
        return index < storyboards.count
    }
    
    class func titleForIndex(index:Int) -> String? {
        guard index >= 0 && index < storyboards.count else { return nil }

        return storyboards[index].label
    }
}
