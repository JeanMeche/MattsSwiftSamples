//
//  Comparable.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 02/08/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import Foundation

extension Comparable
{
    func clamp<T: Comparable>(lower: T, _ upper: T) -> T {
        return min(max(self as! T, lower), upper)
    }
}
