//
//  TitleBlockController.swift
//  LVSExtension
//
//  Created by 머니투데이 on 2016. 12. 2..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import Cocoa

class TitleBlockController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var editTitle: NSTextField!
    @IBOutlet var btnAdd: NSButton!
    @IBOutlet var btnSubmit: NSButton!
    @IBOutlet var btnRemove: NSButton!
    
    @IBOutlet var tableView: NSTableView!
    
    private let defaults = UserDefaults.standard
    private var items : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = defaults.array(forKey: Const.USER_TITLE_BLOCK_ARRAY) as? [String] ?? [String]()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return items[row]
    }
    
    @IBAction func addTitleToBlock(_ sender: Any) {
        let _title = editTitle.stringValue
        
        guard !_title.isEmpty else {
            print("empty")
            return
        }
        
        if items.count > 0 {
            guard !items.contains(_title) else {
                print("duplicate")
                return
            }
        }
        
        var buf = "";
        for char in _title.characters{
            if ["[", "]", "\"", "'", "?", ":", "!", "+", "=", "|", "~", "^"].contains(char.description){
                continue
            }
            
            buf += char.description;
        }
        
        items.append(buf)
        
        tableView.reloadData()
    }
    
    @IBAction func submit(_ sender: Any) {
        defaults.set(items, forKey: Const.USER_TITLE_BLOCK_ARRAY)
        defaults.synchronize()
        
        dismissViewController(self)
    }
    
    @IBAction func remove(_ sender: Any) {
        guard tableView.selectedRow != -1 else {
            items.remove(at: 0)
            
            tableView.reloadData()
            return
        }
        
        if items.count > 0 {
            items.remove(at: tableView.selectedRow)
            
            tableView.reloadData()
        }
    }
}
