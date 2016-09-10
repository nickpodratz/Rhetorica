//
//  CollectionViewCell.swift
//  Vertretungsplan
//
//  Created by Nick Podratz on 28.05.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

protocol OtherAppsCellDelegate: class {
    func otherAppsCell(pressedButton button: UIButton, inCell cell: UICollectionViewCell)
}

class OtherAppsCell: UICollectionViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    weak var delegate: OtherAppsCellDelegate?
    
    override func awakeFromNib() {
        button.addTarget(self, action: #selector(pressedButton), forControlEvents: .TouchUpInside)
        button.layer.borderWidth = 0.2
        button.layer.borderColor = UIColor.darkGrayColor().CGColor
        button.layer.cornerRadius = button.bounds.width * 0.225
        button.layer.masksToBounds = true
    }
    
    func pressedButton() {
        delegate?.otherAppsCell(pressedButton: button, inCell: self)
    }
}
