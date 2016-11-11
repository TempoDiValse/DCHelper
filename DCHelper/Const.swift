//
//  Const.swift
//  LVSExtension
//
//  Created by 머니투데이 on 2016. 11. 3..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import Foundation

struct Const {
    static let USER_IMAGE_WIDTH = "u_img_w"
    static let USER_IMG_SRC = "u_img_src"
    static let USER_IMG_DATA = "u_img_data"
    static let USER_IMG_ADD_AUTO = "u_img_add_auto"
    static let USER_BLOCK_ARRAY = "u_block_array"
    
    struct Page {
        static let DOMAIN_PREFIX = "http://gall.dcinside.com/"
        static let List = "lists";
        static let Write = "write";
        static let View = "view";
    }
    
    struct MessageType {
        static let AutoImage = "auto_image"
        static let Block = "block"
        static let AddButton = "add_button"
        static let Download = "download_file"
        
        static let GetImage = "get_image"
        static let SendURLFromWeb = "send_urls"
    }
}
