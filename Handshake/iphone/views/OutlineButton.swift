//
//  OutlineButton.swift
//  Handshake
//
//  Created by Sam Ober on 4/2/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

import UIKit

@IBDesignable
class OutlineButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor() {
        didSet {
            if !self.highlighted {
                self.layer.borderColor = self.borderColor.CGColor
            }
        }
    }
    @IBInspectable var borderColorHighlighted: UIColor = UIColor.grayColor() {
        didSet {
            if self.highlighted {
                self.layer.borderColor = self.borderColorHighlighted.CGColor
            }
        }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.clearColor() {
        didSet {
            if !self.highlighted {
                self.backgroundColor = self.bgColor
            }
        }
    }
    @IBInspectable var bgColorHighlighted: UIColor = UIColor.clearColor() {
        didSet {
            if self.highlighted {
                self.backgroundColor = self.bgColorHighlighted
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.5
        self.layer.borderColor = self.borderColor.CGColor
        self.layer.cornerRadius = 5
        self.backgroundColor = self.bgColor
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.5
        self.layer.borderColor = self.borderColor.CGColor
        self.layer.cornerRadius = 5
        self.backgroundColor = self.bgColor
    }
    
    override var highlighted: Bool {
        didSet {
            if self.highlighted {
                self.layer.borderColor = self.borderColorHighlighted.CGColor
                self.backgroundColor = self.bgColorHighlighted
            } else {
                self.layer.borderColor = self.borderColor.CGColor
                self.backgroundColor = self.bgColor
            }
        }
    }
    
}