//
//  BackspaceDetectingTextField.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 27/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

protocol BackspaceDetectingTextFieldDelegate:UITextFieldDelegate {
    func textFieldDidDeleteBackwards(_ textField:UITextField)
}

class BackspaceDetectingTextField:UITextField {
    
    private weak var backspaceDelegate:BackspaceDetectingTextFieldDelegate?
    
    override var delegate: UITextFieldDelegate? {
        didSet {
            backspaceDelegate = delegate as? BackspaceDetectingTextFieldDelegate
        }
    }
    
    override func deleteBackward() {
        backspaceDelegate?.textFieldDidDeleteBackwards(self)
        super.deleteBackward()
    }
}
