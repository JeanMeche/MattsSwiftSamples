//
//  Token.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 26/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import Foundation

class Token:Hashable,Equatable {
    var string:String
    var context:AnyObject?
    
    init(string:String) {
        self.string = string
    }
    
    var hashValue: Int {
        return string.hashValue
    }
}

func == (lhs:Token, rhs:Token) -> Bool {
    return lhs.string == rhs.string && lhs.context === rhs.context
}




