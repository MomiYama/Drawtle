//
//  LikeButton.swift
//  ImageApp
//
//  Created by Kazuhiro Shibanai on 2015/09/09.
//  Copyright (c) 2015年 Kazuhiro Shibanai. All rights reserved.
//

import UIKit

class UILikeButton : UIButton  {
    
    var rowId: Int?
    
    var _likeCount: Int = 0
    var likeCount: Int {
        get {
            return _likeCount
        }
        set(newValue) {
            _likeCount = newValue
            self.setTitle(" ♥ \(_likeCount) ", forState: UIControlState.Normal)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 枠の設定
        self.layer.borderColor = self.titleLabel?.textColor.CGColor! // テキストと同じ色
        self.layer.borderWidth = 1 // 枠の太さ
        self.layer.cornerRadius = 3 // 丸める
    }
}