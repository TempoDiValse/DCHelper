//
//  SafariExtensionViewController.swift
//  DCHelper
//
//  Created by LaValse on 2016. 11. 1..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController, NSMenuDelegate{
    
    static let shared = SafariExtensionViewController()
    let defaults = UserDefaults.standard
    
    @IBOutlet var btnList: NSButton!
    @IBOutlet var btnOpen: NSButton!
    @IBOutlet var checkAuto: NSButton!
    
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
        self.presentViewControllerAsModalWindow(BlockController())
    }
    
    @IBAction func openFileDialog(_ sender: Any) {
        self.presentViewControllerAsModalWindow(OptionController())
    }
    
    @IBAction func isAutoMode(_ sender: Any) {
        let btn = sender as! NSButton
        
        print(btn.state == 1)
        
        defaults.set(btn.state == 1, forKey: Const.USER_IMG_ADD_AUTO)
    }
}
