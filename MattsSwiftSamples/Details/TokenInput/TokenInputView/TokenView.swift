//
//  TokenView.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 26/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import UIKit

protocol TokenViewDelegate {
    func tokenViewDidRequestDelete(_ tokenView:TokenView, replaceWithText text:String?)
    func tokenViewDidRequestSelection(_ tokenView:TokenView)
}

class TokenView:PaddingLabel {
    
    private var selected:Bool = false

    var delegate:TokenViewDelegate?
    var hideComma:Bool = false
    var displayText:String
    var selectedLabel:PaddingLabel = PaddingLabel(frame: CGRect.zero)
    
    override var tintColor: UIColor! {
        didSet {
            updateLabelAttributedText()
        }
    }
    
    init(token:Token) {
        displayText = token.string
        super.init(frame: CGRect.zero)
        tintColor = UIColor(red: 0.0823, green: 0.4941, blue: 0.9843, alpha: 1.0)
        textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 2)
        isUserInteractionEnabled = true
        
        selectedLabel.tintColor = tintColor
        selectedLabel.textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        selectedLabel.layer.masksToBounds = true
        selectedLabel.layer.cornerRadius = 6.0
        selectedLabel.backgroundColor = tintColor
        selectedLabel.textColor = .white()
        selectedLabel.text = displayText
        addSubview(selectedLabel)
        selectedLabel.sizeToFit()
        selectedLabel.isUserInteractionEnabled = true
        
        setSelected(selected)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapRecognizer)
        
        updateLabelAttributedText()
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTapGestureRecognizer() {
        delegate?.tokenViewDidRequestSelection(self)
    }
    
    func setSelected(_ selected:Bool, animated:Bool = false) {
        self.selected = selected
        
        if selected && !isFirstResponder() {
            becomeFirstResponder()
        } else if !selected && isFirstResponder() {
            resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            if selected {
                self.selectedLabel.alpha = 1
            } else {
                self.selectedLabel.alpha = 0
            }
        })
    }
    
    func updateLabelAttributedText() {
        let text:String
        if hideComma {
            text = displayText
        } else {
            text = displayText+","
        }
        let attr = [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName: UIColor.lightGray()
        ]
        let attrString = NSMutableAttributedString(string: text, attributes: attr)
        let tintRange = (text as NSString).range(of: displayText)
        let attr2 = [NSForegroundColorAttributeName: tintColor ?? UIColor.lightGray()]
        attrString.setAttributes(attr2, range: tintRange)
        attributedText = attrString
    }
    
    // MARK: Responder
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        setSelected(false)
        return didResignFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        setSelected(true)
        return didBecomeFirstResponder
    }
}

extension TokenView:UIKeyInput {
    func hasText() -> Bool {
        return true
    }
    
    func insertText(_ text: String) {
        delegate?.tokenViewDidRequestDelete(self, replaceWithText:text)
    }
    
    func deleteBackward() {
        delegate?.tokenViewDidRequestDelete(self, replaceWithText:nil)
    }
}


extension TokenView:UITextInputTraits {
    var autocorrectionType:UITextAutocorrectionType {
        get { return .no }
        set {}
    }
}
