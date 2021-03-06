//
//  SafariExtensionHandler.swift
//  DCHelper
//
//  Created by LaValse on 2016. 11. 1..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    let BRIDGE_FUNC = "fromExtension"
    
    let defaults = UserDefaults.standard
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        
        page.getPropertiesWithCompletionHandler({
            let url = $0?.url?.absoluteString
            
            if (url?.hasPrefix(Const.Page.DOMAIN_PREFIX))! {
                if((url?.contains(Const.Page.List))! || (url?.contains(Const.Page.View))!){
                    /* specific function of its page */
                    
                    guard messageName != Const.MessageType.SendURLFromWeb else {
                        let href = userInfo!["href"] as! String
                        let urls = userInfo!["urls"] as! [[String:String]]
                        
                        /* 이미 꺼져 버린 페이지에서 호출이 일어나 URL 대조가 필요 */
                        guard href == url else {
                            return
                        }
                        
                        let ctrlr = ImageDownloadController()
                        ctrlr.setURLs(url: urls)
                        
                        self.performSelector(onMainThread: #selector(self.openDownloadList), with: ctrlr, waitUntilDone: true)
                        
                        return;
                    }
                    
                    /* common function of its page */
                    let blocks = self.defaults.array(forKey: Const.USER_BLOCK_ARRAY) as! [String]?
                    if blocks?.count != 0 {
                        page.dispatchMessageToScript(withName: self.BRIDGE_FUNC, userInfo: [
                            "type": Const.MessageType.Block,
                            "args": blocks!.joined(separator: "|")
                        ])
                    }
                }else if(url?.contains(Const.Page.Write))!{
                    guard messageName != Const.MessageType.GetImage else{
                        self.sendFixImage()
                        return
                    }
                    
                    let isAutoAdd = self.defaults.bool(forKey: Const.USER_IMG_ADD_AUTO)
                    if isAutoAdd {
                        self.sendFixImage()
                    }else{
                        page.dispatchMessageToScript(withName: self.BRIDGE_FUNC, userInfo: ["type": Const.MessageType.AddButton])
                    }
                }
            }
        })
    }
    
    func openDownloadList(sender: Any){
        let pVC = self.popoverViewController()
        
        pVC.presentViewController(sender as! ImageDownloadController, asPopoverRelativeTo: NSRect(x: 0, y: 0, width: 0, height: 0), of: pVC.view, preferredEdge: NSRectEdge.maxX, behavior: .transient)
    }
    
    func sendFixImage(){
        let url = defaults.string(forKey: Const.USER_IMG_SRC)
        
        if url != nil {
            do{
                let fileName = URL(string:url!)?.lastPathComponent
                let data = try Data.init(contentsOf: URL(string:url!)!).base64EncodedString()
                
                let datas =  [
                    "type": Const.MessageType.AutoImage,
                    "args": [
                        "fileName": fileName,
                        "data": data
                    ]
                ] as [String : Any]
                
                SFSafariApplication.getActiveWindow(completionHandler: {
                    $0?.getActiveTab(completionHandler: {
                        $0?.getActivePage(completionHandler: {
                            $0?.dispatchMessageToScript(withName: self.BRIDGE_FUNC, userInfo: datas)
                        })
                    })
                })
            }catch{
                print(error)
            }
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        validationHandler(true, "")
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {}
    override func popoverDidClose(in window: SFSafariWindow) {}
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
