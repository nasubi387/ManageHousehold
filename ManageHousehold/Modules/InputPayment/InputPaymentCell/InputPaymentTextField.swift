//
//  InputPaymentTextField.swift
//  ManageHousehold
//
//  Created by Ishida Naoya on 2019/11/06.
//  Copyright © 2019 Ishida Naoya. All rights reserved.
//

import UIKit

class InputPaymentTextField: UITextField {
    var isDisplayCaret: Bool = true
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        if isDisplayCaret {
            return super.caretRect(for: position)
        } else {
            return CGRect.zero
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    func setup(isDisplayCaret: Bool) {
        self.isDisplayCaret = isDisplayCaret
    }
}
