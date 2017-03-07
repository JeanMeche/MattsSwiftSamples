//
//  UIView.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 02/09/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

extension UIView {
    var screenshot: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        if let tableView = self as? UITableView {
            tableView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        } else {
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
