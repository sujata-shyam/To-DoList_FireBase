//
//  UIButton.swift
//  To-DoList
//
//  Created by Sujata on 12/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

extension UIButton
{
    func setButtonUI()
    {
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 10
        self.tintColor = Theme.Tint
        self.backgroundColor = Theme.Background
        layer.borderColor = Theme.Tint.cgColor
        layer.borderWidth = 1
        //layer.backgroundColor = (Theme.Tint as! CGColor)
    }
}
