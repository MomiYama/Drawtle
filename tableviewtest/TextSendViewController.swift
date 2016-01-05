//
//  TextSendViewController.swift
//  teamApple
//
//  Created by 山本 紅葉 on 2015/09/08.
//
//

import Foundation
import UIKit
import Alamofire

class TextSendViewController: UIViewController,UITextFieldDelegate, UIActionSheetDelegate{
    
    var storage: NSUserDefaults = NSUserDefaults()
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        self.textField.delegate = self
        self.textField.becomeFirstResponder()
        super.viewDidLoad()
    }
    
    @IBAction func tapTitlePostBtn(sender: UIButton) {
        postTitle()
    }
    
    func postTitle(){
        var sheet: UIActionSheet = UIActionSheet()
        sheet.delegate = self
        sheet.addButtonWithTitle("キャンセル")
        // キャンセルボタンのindexを指定
        sheet.cancelButtonIndex = 0
        let input = self.textField.text ?? ""
        let reg = NSRegularExpression(pattern:"^\\s*$", options: nil, error: nil)
        let matches = reg!.matchesInString(input, options: nil, range: NSMakeRange(0, count(input)))
        if matches.count > 0 {
            sheet.title = "空投稿は禁じられています！"
        }else {
            sheet.title = "お題を投稿してもいいですか？"
            sheet.addButtonWithTitle("投稿する")
        }
        // UIActionSheet表示
        sheet.showInView(self.view)
    }
    
    // メニューから押された時
    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1: // 投稿するが押された時
            
            let user_id = storage.integerForKey("user_id")
            let title = textField.text ?? ""
            let user_name = "anonymous" // userNameTextField.text!
            
            Alamofire.request(
                .POST,
                "http://133.242.234.139/api/post_title.php",
                parameters: [
                    "title": title,
                    "user_id": user_id,
                    "user_name": user_name
                ]
                ).responseJSON { (request, response, JSON, error) in
                    println(JSON)
                    if error != nil {
                        return
                    }
                    let ctlrs = self.navigationController!.viewControllers
                    if let parent = ctlrs[ctlrs.count - 2] as? ViewController {
                        println("==="+typeof(parent)+"===")
                        parent.invokeGetTitles()
                    }
                    self.navigationController!.popViewControllerAnimated(true)!
            }

        default:
            break
        }
    }


    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        self.view.endEditing(true)
        
        postTitle()
        
        return false
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}