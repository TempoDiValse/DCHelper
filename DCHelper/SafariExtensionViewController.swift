//
//  SafariExtensionViewController.swift
//  DCHelper
//
//  Created by LaValse on 2016. 11. 1..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared = SafariExtensionViewController()
    let defaults = UserDefaults.standard
    
    @IBOutlet var btnList: NSButton!
    @IBOutlet var btnOpen: NSButton!
    
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
    }
    
    @IBAction func openBlocker(_ sender: Any) {
        self.presentViewControllerAsModalWindow(BlockController())
    }
    
    @IBAction func openFileDialog(_ sender: Any) {
        self.presentViewControllerAsModalWindow(OptionController())
    }
}
