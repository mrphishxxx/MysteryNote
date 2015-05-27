//
//  TextFieldWithPadding.swift
//  anonTextMachine
//
//  Created by Joshua Gafni on 3/15/15.
//  Copyright (c) 2015 jgafni. All rights reserved.
//

import UIKit

class TextFieldWithPadding: UITextField {

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, CGFloat(10), CGFloat(10))
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, CGFloat(10), CGFloat(10))
    }
    
}
