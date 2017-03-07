//
//  PaddingLabel.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 26/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

class PaddingLabel : UILabel {
    
    var textInsets = UIEdgeInsets.zero
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        if text == nil {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }
        var rect = textInsets.apply(bounds)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return textInsets.inverse.apply(rect)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: textInsets.apply(rect))
    }
    
}

extension UIEdgeInsets {
    var inverse: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    
    func apply(_ rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}
