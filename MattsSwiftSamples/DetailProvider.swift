//
//  DetailProvider.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 25/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

struct Detail {
    let storyboard:String?
    let label:String
    var clazz:AnyObject.Type
    
    init(label:String, clazz:AnyObject.Type, storyboard:String?=nil) {
        self.storyboard = storyboard
        self.label = label
        self.clazz = clazz
    }
    
//    var relatedType: T.Type { return T.self }
}

class DetailProvider {
    
    private static var details:[Detail] = [
        Detail(label:"Spark Button", clazz:SparkButtonViewController.self, storyboard:"SparkButton"),
        Detail(label:"Token Input", clazz:TokenInputViewController.self, storyboard:"TokenInput"),
        Detail(label:"Flappy Bird", clazz:FlappyViewController.self, storyboard:"FlappyBird"),
        Detail(label:"Camera Roll", clazz:CameraRollViewController.self, storyboard:"CameraRoll")
    ]
    
    static var detailCount:Int {
        return details.count
    }

    class func viewControllerForIndex(_ index:Int) -> DetailViewController? {
        guard index >= 0 && index < details.count else { return nil }
        let detail = details[index]
        
        let initialVC:UIViewController?
        if let storyboardName = detail.storyboard, Bundle.main.path(forResource: storyboardName, ofType: "storyboardc") != nil {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            initialVC = storyboard.instantiateInitialViewController()
        } else {
            initialVC = (detail.clazz as? DetailViewController.Type)!.init()
        }

        let detailVC = initialVC as? DetailViewController
        if detailVC == nil {
            fatalError("View Controller is not of class DetailViewController")
        }
        detailVC?.sampleIndex = index
        detailVC?.view.backgroundColor = .white
        return detailVC
    }
    
    class func hasDetailForIndex(_ index:Int) -> Bool {
        return index < details.count
    }
    
    class func titleForIndex(_ index:Int) -> String? {
        guard index >= 0 && index < details.count else { return nil }

        return details[index] .label
    }
}
