
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
    func listView(didSelectLanguage language: Language) -> Void
}

class ListViewController: UITableViewController {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var fewDevicesCell: UITableViewCell!
    @IBOutlet weak var someDevicesCell: UITableViewCell!
    @IBOutlet weak var allDevicesCell: UITableViewCell!
    @IBOutlet weak var favouritesCell: UITableViewCell!
    
    @IBOutlet weak var germanLanguageCell: UITableViewCell!
    @IBOutlet weak var englishLanguageCell: UITableViewCell!
    
    
    // MARK: Properties
    
    var delegate: ListViewDelegate?

    var titleOfSelectedList: String!
    var selectedLanguage: Language?

    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        setDeviceListCheckmarks()
        setLanguageCheckmarks()
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagOfSelectedCell = tableView.cellForRow(at: indexPath)!.tag
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0, _):
            delegate?.listView(didSelectListWithTag: tagOfSelectedCell)
            titleOfSelectedList = tableView.cellForRow(at: indexPath)!.textLabel!.text!
            setDeviceListCheckmarks()
        case (1, _):
            if let language = Language(rawValue: tagOfSelectedCell) {
                self.selectedLanguage = language
                delegate?.listView(didSelectLanguage: language)
            }
            setLanguageCheckmarks()
        default: ()
        }
    }
    
    @IBAction func rewindsToListViewController(_ segue:UIStoryboardSegue) {
        
    }
    
    
    
    // MARK: Private Functions
    
    fileprivate func setDeviceListCheckmarks() {
        for cell in [fewDevicesCell, someDevicesCell, allDevicesCell, favouritesCell] {
            let isSelected = (cell?.textLabel!.text == titleOfSelectedList)
            cell?.accessoryType = isSelected ? .checkmark : .none
        }
    }
    
    fileprivate func setLanguageCheckmarks() {
        for cell in [germanLanguageCell, englishLanguageCell] {
            let isSelected = (cell?.textLabel!.text == selectedLanguage?.localizedDescription)
            cell?.accessoryType = isSelected ? .checkmark : .none
        }
    }
}
