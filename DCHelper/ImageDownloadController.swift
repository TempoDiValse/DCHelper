//
//  ImageDownloadController.swift
//  LVSExtension
//
//  Created by 머니투데이 on 2016. 11. 10..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import Cocoa

class ImageDownloadController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSOpenSavePanelDelegate {
    @IBOutlet var editPath: NSTextField!
    @IBOutlet var btnPath: NSButton!
    @IBOutlet var tableView: NSTableView!
    
    @IBOutlet var btnDownload: NSButton!
    @IBOutlet var btnClose: NSButton!
    
    private var _url = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "다운로드"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 25.0
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func setURLs(url:[String]){
        if url.count > 0 {
            self._url = url
        }
    }
 
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (tableColumn?.identifier == "url") ? _url[row] : ""
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return _url.count
    }
    
    @IBAction func configureFolderPath(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.beginSheetModal(for: self.view.window!, completionHandler: {
            if $0 == NSFileHandlingPanelOKButton {
                let url = panel.urls[0]
                
                self.editPath.stringValue = url.absoluteString
            }
        })
    }
    
    @IBAction func downloadAll(_ sender: Any) {
        
    }
    
    @IBAction func windowClose(_ sender: Any) {
        self.view.window?.close()
    }
}
