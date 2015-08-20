//
//  ListViewController.swift
//  Cicero
//
//  Created by Nick Podratz on 15.10.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//  

import Foundation
import UIKit

protocol ListViewDelegate {
    func listView(didSelectListWithTag tag: Int) -> Void
}

class ListViewController: UITableViewController {
    
    @IBOutlet weak var fewDevicesCell: UITableViewCell!
    @IBOutlet weak var someDevicesCell: UITableViewCell!
    @IBOutlet weak var allDevicesCell: UITableViewCell!
    @IBOutlet weak var favouritesCell: UITableViewCell!
    @IBOutlet weak var fewDevicesLabel: UILabel!
    @IBOutlet weak var someDevicesLabel: UILabel!
    @IBOutlet weak var allDevicesLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    
    var delegate: ListViewDelegate?
    

    // ------------------------------------------------------------------------
    // MARK: - Initialisation
    // ------------------------------------------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewWillAppear(animated: Bool) {
        setCheckmarks()
    }
    
    
    // ------------------------------------------------------------------------
    // MARK: - Events
    // ------------------------------------------------------------------------
    
    private func setCheckmarks() {
        [fewDevicesCell, someDevicesCell, allDevicesCell, favouritesCell].map { $0.accessoryType = .None }
        
        switch(DataManager.sharedInstance.selectedList.title) {
        case allDevicesLabel.text!: allDevicesCell.accessoryType = .Checkmark
        case someDevicesLabel.text!: someDevicesCell.accessoryType = .Checkmark
        case fewDevicesLabel.text!: fewDevicesCell.accessoryType = .Checkmark
        case favoritesLabel.text!: favouritesCell.accessoryType = .Checkmark
        default: break
        }
    }

    
    // ------------------------------------------------------------------------
    // MARK: - Table View
    // ------------------------------------------------------------------------

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tagOfSelectedCell = tableView.cellForRowAtIndexPath(indexPath)!.tag
        setCheckmarks()
        delegate?.listView(didSelectListWithTag: tagOfSelectedCell)

        dismissViewControllerAnimated(true){
            
        }
    }
}