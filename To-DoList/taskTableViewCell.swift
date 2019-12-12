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
    
    @IBOutlet weak var lblDueAlert: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        cardView.addShadowAndRoundedCorners()
        cardView.backgroundColor = Theme.Background
        
        lblTitle.font = UIFont(name: Theme.mainFontName, size: Theme.mainFontSize)
        lblCreationDate.font = UIFont(name: Theme.subtitleFontName, size: Theme.subtitleFontSize)

        lblTitle.textColor = Theme.mainFontColor
        lblCreationDate.textColor = Theme.subtitleFontColor
    }
}

