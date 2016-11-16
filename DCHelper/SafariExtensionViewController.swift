//
//  SafariExtensionViewController.swift
//  DCHelper
//
//  Created by LaValse on 2016. 11. 1..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController{
    
    static let shared = SafariExtensionViewController()
    let defaults = UserDefaults.standard
    
    @IBOutlet var btnList: NSButton!
    @IBOutlet var btnOpen: NSButton!
    @IBOutlet var checkAuto: NSButton!
    @IBOutlet var btnDownload: NSButton!
    
    @IBOutlet var lBlocker: NSTextField!
    @IBOutlet var bgLabel1: NSVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _view = self.view as! NSVisualEffectView
        
        _view.blendingMode = .behindWindow
        _view.material = .ultraDark
        
        bgLabel1.layer?.backgroundColor = CGColor(red: 174.0/255.0, green: 118.0/255.0, blue: 232.0/255.0, alpha: 1.0)
        bgLabel1.blendingMode = .withinWindow
        bgLabel1.material = .dark
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let count = defaults.array(forKey: Const.USER_BLOCK_ARRAY)?.count ?? 0
        lBlocker.stringValue = String(count)
        
        let autoState = defaults.bool(forKey: Const.USER_IMG_ADD_AUTO) ? 1 : 0
        checkAuto.state = autoState
    }
    
    @IBAction func openBlocker(_ sender: Any) {
        self.presentViewController(BlockController(), asPopoverRelativeTo: NSRect(x: 0, y: 100, width: 0, height: 0), of: self.view, preferredEdge: NSRectEdge.maxX, behavior: .transient)
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
}
