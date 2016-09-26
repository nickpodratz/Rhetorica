//
//  WrongAnsweredQuestionsCell.swift
//  Rhetorica
//
//  Created by Nick Podratz on 30.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import UIKit


protocol PinnableDeviceCellDelegate {
    /// - returns: If the device is now added to the favorites.
    func pinnableDeviceCellDelegate(didPressPinButtonOfCellWithTag tag: Int) -> Bool
}

class PinnableDeviceCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pinButton: UIButton!
    
    var isFavorite: Bool = false {
        didSet {
            print("is favorite set")
            let image = isFavorite ? UIImage(named: "pin_filled") : UIImage(named: "pin")
            pinButton.setImage(image, for: UIControlState())
        }
    }
    var delegate: PinnableDeviceCellDelegate?
    
    var device: StylisticDevice! {
        didSet {
            label.text = device.title
        }
    }
    
    @IBAction func pinButtonPressed(_ sender: AnyObject) {
        if let addedDevice = delegate?.pinnableDeviceCellDelegate(didPressPinButtonOfCellWithTag: self.tag) {
            isFavorite = addedDevice
        }
    }
    
}
