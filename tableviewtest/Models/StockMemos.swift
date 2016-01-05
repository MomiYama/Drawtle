//
//  StockMemos.swift
//  teamApple
//
//  Created by 山本 紅葉 on 2015/09/08.
//
//

import Foundation
import UIKit
import Alamofire

class StockMemos: NSObject {

    
    // 保存ボタンが押されたときに呼ばれるメソッドを定義
    class func postMemo(memo: Memo) {
        
        var params: [String: AnyObject] = [
            "user_id": 2,
            "user_name": "marie",
            "title": memo.text,
        ]
        
        // HTTP通信
        Alamofire.request(.POST, "http://133.242.234.139/api/post_title.php", parameters: params, encoding: .URL).responseJSON { (request, response, JSON, error) in
            
            println("=============request=============")
            println(request)
            println("=============response============")
            println(response)
            println("=============JSON================")
            println(JSON)
            println("=============error===============")
            println(error)
            println("=================================")
        }
        
    }
}