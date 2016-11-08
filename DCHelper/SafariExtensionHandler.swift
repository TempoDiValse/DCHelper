//
//  SafariExtensionHandler.swift
//  DCHelper
//
//  Created by LaValse on 2016. 11. 1..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    let defaults = UserDefaults.standard
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        if messageName == Const.Page.List || messageName == Const.Page.View{
            
            let blocks = defaults.array(forKey: Const.USER_BLOCK_ARRAY) as! [String]?
            
            if blocks?.count != 0 {
                page.dispatchMessageToScript(withName: "fromExtension", userInfo: [
                    "type": Const.MessageType.Block,
                    "args": blocks!.joined(separator: "|")
                ])
            }
        } else if messageName == Const.Page.Write {
            let url = defaults.string(forKey: Const.USER_IMG_SRC)
            
            if url != nil {
                do{
                    let fileName = URL(string:url!)?.lastPathComponent
                    let data = try Data.init(contentsOf: URL(string:url!)!).base64EncodedString()
                    
                    let width = defaults.string(forKey: Const.USER_IMAGE_WIDTH)
                    
                    page.dispatchMessageToScript(withName: "fromExtension", userInfo: [
                        "type": Const.MessageType.AutoImage,
                        "args": [
                            "fileName": fileName,
                            "data": data,
                            "width": width
                        ]
                    ])
                }catch{
                    print(error)
                }
            }
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        print(#function)
    }
    
    override func popoverDidClose(in window: SFSafariWindow) {
        print(#function)
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
