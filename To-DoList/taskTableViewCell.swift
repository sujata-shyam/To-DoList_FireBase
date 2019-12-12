//
//  categoryTableViewCell.swift
//  To-DoList
//
//  Created by Sujata on 28/11/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

class taskTableViewCell: UITableViewCell
{
    @IBOutlet weak var lblPriority: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCreationDate: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cardView.addShadowAndRoundedCorners()
        cardView.backgroundColor = Theme.Accent
        lblTitle.font = UIFont(name: Theme.mainFontName, size: 20)
    }
}

