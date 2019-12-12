//
//  UIViewExtensions.swift
//  To-DoList
//
//  Created by Sujata on 11/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

extension UIView
{
    func addShadowAndRoundedCorners()
    {
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 10
    }
}
