//
//  BlockController.swift
//  LVSExtension
//
//  Created by LaValse on 2016. 11. 3..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import Cocoa

class BlockController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var btnAdd: NSButton!
    @IBOutlet var btnClose: NSButton!
    @IBOutlet var btnDelete: NSButton!
    @IBOutlet var tableView: NSTableView!
    
    @IBOutlet var ipBlocker: NSTextField!
    
    let defaults = UserDefaults.standard
    private var items : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "차단 목록 관리"
        
        items = defaults.array(forKey: Const.USER_BLOCK_ARRAY) as? [String] ?? [String]()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func addBlocker(_ sender: Any) {
        let _nickName = ipBlocker.stringValue
        
        guard !_nickName.isEmpty else {
            print("empty")
            return
        }
        
        if(items.count > 0){
            guard !items.contains(_nickName) else {
                print("duplicate")
                return
            }
        }
        
        items.append(ipBlocker.stringValue)
        
        tableView.reloadData()
    }
    
    @IBAction func windowClose(_ sender: Any) {
        defaults.set(items, forKey: Const.USER_BLOCK_ARRAY)
        defaults.synchronize()
        
        dismissViewController(self)
    }
    
    @IBAction func deleteRow(_ sender: Any) {
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
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return items[row]
    }
}
