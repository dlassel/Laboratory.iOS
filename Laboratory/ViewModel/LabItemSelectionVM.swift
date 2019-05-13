//
//  LabItemSelectionVM.swift
//  Laboratory
//
//  Created by Huy Vo on 5/13/19.
//  Copyright © 2019 2Letters. All rights reserved.
//

import UIKit

struct LabItemSelectionVM {
    var itemName: String
    var selectionStyle: UITableViewCell.SelectionStyle
    
    init(_ item: LabItem) {
        itemName = item.itemName
        selectionStyle = .default
    }
}
