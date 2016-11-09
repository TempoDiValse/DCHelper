//
//  OptionController.swift
//  LVSExtension
//
//  Created by LaValse on 2016. 11. 2..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import Cocoa

class OptionController: NSViewController {
    
    @IBOutlet var btnOpen: NSButton!
    @IBOutlet var btnSubmit: NSButton!
    @IBOutlet var imgPreview: NSImageView!
    @IBOutlet var btnCancel: NSButton!
    
    @IBOutlet var editURL: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "자동 이미지"
        let defaults = UserDefaults.standard
        
        editURL.isEditable = false
        
        if let src = defaults.string(forKey: Const.USER_IMG_SRC) {
            editURL.stringValue = src
            
            imgPreview.image = getImage(filePath: URL(string:src)!)
        }
    }
    
    @IBAction func openFileDialog(_ sender: Any) {
        let dialog = NSOpenPanel()
        
        dialog.allowedFileTypes = NSImage.imageTypes()
        dialog.beginSheetModal(for: self.view.window!, completionHandler: { (result) in
            if result == NSFileHandlingPanelOKButton {
                let url = dialog.urls[0]
                
                self.editURL.stringValue = url.absoluteString
                let image = self.getImage(filePath: url)
                
                self.imgPreview.image = image
            }
        })
    }
    
    func getImage(filePath: URL) -> NSImage?{
        var image : NSImage?
        
        image = NSImage(contentsOf: filePath)
        
        guard image != nil else {
            return nil
        }

        return image
    }
    
    @IBAction func submit(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        defaults.set(editURL.stringValue, forKey: Const.USER_IMG_SRC)
        defaults.synchronize()
        
        dismissViewController(self)
    }
    
    @IBAction func windowCancel(_ sender: Any) {
        dismissViewController(self)
    }
}
