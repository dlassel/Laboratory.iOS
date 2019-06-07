//
//  LabTableViewCell.swift
//  Laboratory
//
//  Created by Administrator on 5/7/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import UIKit

class LabTVCell: UITableViewCell {
    static let reuseId = "LabCell"
    
    @IBOutlet var labNameLbl: UILabel!

    var viewModel: LabVM? {
        didSet {
            labNameLbl.text = viewModel?.labName
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}