//
//  UILabelExtensions.swift
//  To-DoList
//
//  Created by Sujata on 12/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

extension UILabel
{
    func setLabelUI()
    {
        self.textColor = Theme.labelTextColour
        self.font = UIFont(name: Theme.labelFontName, size: Theme.labelFontSize)
    }
}
