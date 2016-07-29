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
        (name:"TokenInput", label:"Token Input")
    ]
    
    private static var viewControllers = [Int:DetailViewController]()

    class func viewControllerForIndex(_ index:Int) -> DetailViewController? {
        guard index >= 0 && index < storyboards.count else { return nil }
        
        if let viewController = viewControllers[index] {
            return viewController
        }
        
        let storyboard = UIStoryboard(name: storyboards[index].name, bundle: nil)
        let detailVC = storyboard.instantiateInitialViewController() as? DetailViewController
        detailVC?.sampleIndex = index
        viewControllers[index] = detailVC
        return detailVC
    }
    
    class func hasDetailForIndex(_ index:Int) -> Bool {
        return index < storyboards.count
    }
    
    class func titleForIndex(_ index:Int) -> String? {
        guard index >= 0 && index < storyboards.count else { return nil }

        return storyboards[index].label
    }
    
    class func clearViewControllersCache() {
        viewControllers.removeAll()
    }
}
