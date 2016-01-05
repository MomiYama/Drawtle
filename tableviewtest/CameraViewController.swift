//
//  CameraViewController.swift
//  Shasin
//
//  Created by Kazuhiro Shibanai on 2015/09/08.
//  Copyright (c) 2015年 Kazuhiro Shibanai. All rights reserved.
//

import UIKit
import Alamofire

class CameraViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var storage: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // ボタンが押された時
    @IBAction func tapButton(sender : AnyObject) {
        // アクションシートの作成
        var sheet: UIActionSheet = UIActionSheet()
        let title: String = "投稿したいイラストを選んでください？"
        sheet.title  = title
        sheet.delegate = self
        sheet.addButtonWithTitle("諦める")
        sheet.addButtonWithTitle("写真を撮る")
        sheet.addButtonWithTitle("カメラロールから選択")
        
        // キャンセルボタンのindexを指定
        sheet.cancelButtonIndex = 0
        
        // UIActionSheet表示
        sheet.showInView(self.view)
    }
    
    // メニューから押された時
    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        println("index %d %@", buttonIndex, sheet.buttonTitleAtIndex(buttonIndex))
        switch buttonIndex {
        case 1: // 写真を撮るが押された時
            pickImageFromCamera()
        case 2: // カメラロールを押された時
            pickImageFromLibrary()
        default:
            break
        }
    }
    
    // カメラから画像を選択する
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    // ライブラリから写真を選択する
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    // 写真を選択した時に呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 画像データの取得
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let data = UIImageJPEGRepresentation(image, 0.8) // JPEGデータに変換
            
            // 画像データをTag:1 の UIImageView にセット
            let imgview = self.view.viewWithTag(1) as! UIImageView
            imgview.image = image
            
            // パラメータを文字列で指定
            let title_id = "1".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let user_name = "Tomori Nao".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            let _user_id = storage.integerForKey("user_id")
            let user_id = "\(_user_id)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            
            // アップロード部分
            Alamofire.upload(
                .POST,
                URLString: "http://133.242.234.139/api/post_illust.php",
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: user_name, name: "user_name")
                    multipartFormData.appendBodyPart(data: title_id, name: "title_id")
                    multipartFormData.appendBodyPart(data: user_id, name: "user_id")
                    multipartFormData.appendBodyPart(data: data, name: "file", fileName: "image.jpeg", mimeType: "image/jpeg")
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { request, response, JSON, error in
                            // 完了時のレスポンス
                            println(JSON)
                            println(error)
                            println(request)
                            println(response)
                            
                        }
                    case .Failure(let encodingError):
                        println("EncodingError", encodingError) // エラー時
                    }
                }
            )
        }
        
        // これよくわかんない
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}