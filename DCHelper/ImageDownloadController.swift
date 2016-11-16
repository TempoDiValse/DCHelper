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
    
    private var _url = [[String:String]]()
    private var _dest : URL?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "다운로드"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 25.0
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let path = defaults.url(forKey: Const.USER_DOWNLOAD_PATH) {
            editPath.stringValue = path.absoluteString
            _dest = path
        }
        
        tableView.reloadData()
    }
    
    func setURLs(url:[[String: String]]){
        if url.count > 0 {
            self._url = url
        }
    }
 
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (tableColumn?.identifier == "url") ? _url[row]["name"] : ""
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return _url.count
    }
    
    @IBAction func configureFolderPath(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        let response = panel.runModal()
        
        if response == NSFileHandlingPanelOKButton {
            _dest = panel.urls[0]
            
            self.editPath.stringValue = (_dest?.absoluteString)!
        }
    }
    
    @IBAction func downloadAll(_ sender: Any) {
        let path = _dest
        guard path != nil else {
            configureFolderPath("")
            return;
        }
        
        let queueGroup = DispatchGroup()
        
        for _u in _url {
            queueGroup.enter()
            
            let session = URLSession.shared
            session.downloadTask(with: URL(string: _u["url"]!)!, completionHandler: { (url, response, err) in
                let data = NSData(contentsOf: url!)
                
                do{
                    try data?.write(to: path!.appendingPathComponent(_u["name"]!), options: NSData.WritingOptions.atomic)
                }catch{
                    print(error)
                }
                
            }).resume()
            queueGroup.leave()
        }
        
        queueGroup.notify(queue: DispatchQueue.main, execute: {
            self.defaults.set(path, forKey: Const.USER_DOWNLOAD_PATH)
            self.defaults.synchronize()
            
            self.dismissViewController(self)
        })
    }
    
    @IBAction func windowClose(_ sender: Any) {
        dismissViewController(self)
    }
}
