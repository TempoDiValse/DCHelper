//
//  SafariExtensionViewController.swift
//  DCHelper
//
//  Created by LaValse on 2016. 11. 1..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController, NSComboBoxDelegate, NSComboBoxDataSource{
    
    static let shared = SafariExtensionViewController()
    let defaults = UserDefaults.standard
    
    @IBOutlet var btnList: NSButton!
    @IBOutlet var btnBTitle: NSButton!
    @IBOutlet var btnOpen: NSButton!
    @IBOutlet var checkAuto: NSButton!
    @IBOutlet var btnDownload: NSButton!
    @IBOutlet var selectRecentVisited: NSComboBox!
    
    @IBOutlet var bgLabel1: NSVisualEffectView!
    
    var vList = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _view = self.view as! NSVisualEffectView
        
        _view.blendingMode = .behindWindow
        _view.material = .ultraDark
        
        bgLabel1.layer?.backgroundColor = CGColor(red: 174.0/255.0, green: 118.0/255.0, blue: 232.0/255.0, alpha: 1.0)
        bgLabel1.blendingMode = .withinWindow
        bgLabel1.material = .dark
        
        selectRecentVisited.delegate = self
        selectRecentVisited.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let autoState = defaults.bool(forKey: Const.USER_IMG_ADD_AUTO) ? 1 : 0
        checkAuto.state = autoState
        
        vList = defaults.array(forKey: Const.USER_RECENT_VISITED) as! [[String : String]]
        selectRecentVisited.reloadData()
        selectRecentVisited.selectItem(at: 0)
    }
    
    @IBAction func openBlockTitle(_ sender: Any) {
        self.presentViewController(TitleBlockController(), asPopoverRelativeTo: NSRect(), of: self.view, preferredEdge: NSRectEdge.maxX, behavior: .transient)
    }
    
    @IBAction func openBlocker(_ sender: Any) {
        self.presentViewController(BlockerController(), asPopoverRelativeTo: NSRect(x: 0, y: 100, width: 0, height: 0), of: self.view, preferredEdge: NSRectEdge.maxX, behavior: .transient)
    }
    
    @IBAction func openFileDialog(_ sender: Any) {
        self.presentViewController(OptionController(), asPopoverRelativeTo: NSRect(x: 0, y: 100, width: 0, height: 0), of: self.view, preferredEdge: NSRectEdge.maxX, behavior: .transient)
    }
    
    @IBAction func isAutoMode(_ sender: Any) {
        let btn = sender as! NSButton
        
        print(btn.state == 1)
        
        defaults.set(btn.state == 1, forKey: Const.USER_IMG_ADD_AUTO)
    }
    
    @IBAction func downloadAll(_ sender: Any) {
        
        SFSafariApplication.getActiveWindow(completionHandler: {
            $0?.getActiveTab(completionHandler: {
                $0?.getActivePage(completionHandler: {
                    let page = $0
                    
                    $0?.getPropertiesWithCompletionHandler({ (props) in
                        let url = props?.url?.absoluteString
                        
                        guard url != nil else { return }
                        guard (url?.hasPrefix(Const.Page.DOMAIN_PREFIX))! else { return }
                        
                        if (url?.contains(Const.Page.View))! {
                            page?.dispatchMessageToScript(withName: "fromExtension", userInfo: ["type" : Const.MessageType.Download])
                        }
                    })
                })
            })
        })
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let _i = selectRecentVisited.indexOfSelectedItem
        guard _i != 0 else { return }
        
        let _u = URL(string:"\(Const.Page.DOMAIN_PREFIX)\(vList[_i]["id"]!)")
        
        SFSafariApplication.getActiveWindow(completionHandler: {
            $0?.openTab(with: _u!, makeActiveIfPossible: true, completionHandler: {
                $0?.activate(completionHandler: { 
                    print("new tab opened")
                })
            })
        })
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return vList.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return vList[index]["name"]
    }
}
