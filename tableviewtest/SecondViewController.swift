//
//  SecondViewController.swift
//  tableviewtest
//
//  Created by sensei on 2015/08/31.
//  Copyright (c) 2015年 senseiswift. All rights reserved.
//

import UIKit
import Alamofire

// 非同期で読み込むマン
extension UIImageView {
    func loadSyncFromURL(urlString: String) {
        let url = NSURL(string: urlString)
        var err: NSError?
        let imageData = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
        var image: UIImage?
        
        // 画面の横幅
        let frameWidth = UIScreen.mainScreen().bounds.width
        
        if let _data = imageData {
            image = UIImage(data: _data)
            
            // 画像の縦横比を求める
            let imageSize = image!.size
            let imageAspect = imageSize.height / imageSize.width
            
            // 高さを画像の縦横比に合わせる
            self.setTranslatesAutoresizingMaskIntoConstraints(false) // AutoLayout無効化
            self.frame = CGRectMake(0, 0, frameWidth, frameWidth * imageAspect)
            self.setTranslatesAutoresizingMaskIntoConstraints(true) // AutoLayout有効化
            
            self.image = image
        }
    }
    
    func loadAsyncFromURL(urlString: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url = NSURL(string: urlString)
            var err: NSError?
            let imageData = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
            var image: UIImage?
            if let _data = imageData {
                image = UIImage(data: _data)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.image = image
                })
            }
        })
    }
}

class Illust {
    init(name: String, likeCount: Int, image: String, illustId: Int, illustSize: (Int, Int)) {
        self.name = name
        self.image = image
        self.likeCount = likeCount
        self.illustId = illustId
        self.illustSize = illustSize
    }
    
    var name: String
    var likeCount: Int
    var image: String
    var illustId: Int
    var illustData: UIImage?
    var illustSize : (Int, Int)
}

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // @IBOutlet weak var titleLabel: UILabel!
    // @IBOutlet weak var bookmarkButton: UIButton!
    
    // ViewControllerから受け取った title_id を保持する
    var titleId: Int?
    
    var titleText: String?
    
    var storage: NSUserDefaults = NSUserDefaults()
    
    var illusts: [Illust] = []
    
    var bookmarked: Bool?
    
    var shouldShowPlaceHolder: Bool?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        println("didload")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        
        invokeGetResponses()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの流し込み処理
    func invokeGetResponses(){
        
        // titleLabel.text = "画像を取得中…"
        // ふぁぼってるか確認
        let userId = storage.integerForKey("user_id")
        Alamofire.request(.GET, "http://133.242.234.139/api/get_liked_titles.php", parameters: ["title_id": titleId!, "user_id": userId])
            .responseJSON {( _, _, JSON, error ) in
                if error == nil {
                    if let title = JSON as? Array<AnyObject> {
                        if title.count == 0 {
                            // お気に入りに追加されていない
                            self.bookmarked = false
                            // self.bookmarkButton.setTitle(" お題をブックマークする ", forState: .Normal)
                        } else {
                            // お気に入りに追加されている
                            self.bookmarked = true
                            // self.bookmarkButton.setTitle(" ブックマーク済み ", forState: .Normal)
                        }
                    }
                }
            }
        
        // 画像リスト
        Alamofire.request(.GET, "http://133.242.234.139/api/get_responses.php", parameters: ["title_id": titleId!])
            .responseJSON {( _, _, JSON, _ ) in
                
                if let title = JSON as? Dictionary<String,AnyObject> {
                    
                    self.illusts.removeAll()
                    
                    // お題
                    self.titleText = title["title"] as! String
                    // self.titleLabel.text = titleText
                    
                    // イラスト
                    let illusts = title["responses"] as! Array<Dictionary<String,AnyObject>>
                    
                    self.shouldShowPlaceHolder = illusts.count == 0
                    
                    for illust in illusts.reverse() {
                        let name = illust["user_name"] as! String
                        let id = illust["illust_id"] as! Int
                        let url = illust["illust_url"] as! String
                        let likes = illust["likes"] as! Int
                        
                        let width = illust["width"] as! Int
                        let height = illust["height"] as! Int
                        
                        self.illusts.append(Illust(
                            name: name,
                            likeCount: likes,
                            image: url,
                            illustId: id,
                            illustSize: (width, height)
                        ))
                        
                    }
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    // テーブルの行数を追加
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowPlaceHolder == true ? 2 : illusts.count + 1
    }
    
    // セルのテキストを追加
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath) as! UITableViewCell
            let titleLabel = cell.viewWithTag(1) as! UILabel
            titleLabel.text = titleText
            let likeButton = cell.viewWithTag(2) as! UIButton
            if bookmarked != nil {
                likeButton.setTitle( (bookmarked! ? " ブックマーク済み " : " このお題をブックマークする "), forState: .Normal)
            }
            return cell
        }
        
        if shouldShowPlaceHolder == true { // placeholder
            return tableView.dequeueReusableCellWithIdentifier("PlaceHolderCell", forIndexPath: indexPath) as! UITableViewCell
        }
        
        var border: UIView!
        
        var illust = illusts[indexPath.row - 1]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! UITableViewCell
        
        // let titleLabel = cell.viewWithTag(1) as! UILabel
        // titleLabel.text = illusts[i].name
        
        let likeButton = cell.viewWithTag(3) as! UILikeButton
        likeButton.likeCount = illust.likeCount
        likeButton.rowId = indexPath.row - 1
        
        let imgView = cell.viewWithTag(2) as! UIImageView
        
        imgView.image = nil
        
        let frameWidth = UIScreen.mainScreen().bounds.width
        imgView.setTranslatesAutoresizingMaskIntoConstraints(false) // AutoLayout無効化
        let size = illust.illustSize
        let imageAspect = CGFloat(size.1) / CGFloat(size.0)
        imgView.frame = CGRectMake(0, 0, frameWidth, frameWidth * imageAspect)
        imgView.setTranslatesAutoresizingMaskIntoConstraints(true) // AutoLayout有効化
        
        if illust.illustData != nil {
            imgView.image = illust.illustData
            print("used cache")
        } else {
            // サムネイル画像（アレ）
            Alamofire
                .request(.GET, "http://133.242.234.139/api/thumb.php?illust_id=\(illust.illustId)")
                .response() { (request, response, data, error) in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue()) { () in
                            if imgView.image == nil {
                                illust.illustData = UIImage(data: data! as NSData)
                                imgView.image = illust.illustData
                            }
                        }
                    }
            }
            // 本当の画像
            Alamofire
            .request(.GET, illust.image)
            .response() { (request, response, data, error) in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) { () in
                        illust.illustData = UIImage(data: data! as NSData)
                        imgView.image = illust.illustData
                    }
                }
            }
        }
        
        println("> tableView Called")
        
        return cell
    }
    
    @IBAction func likeButton_touchDown(sender: UILikeButton) {
        
        let illustId = illusts[sender.rowId!].illustId
        
        // ふぁぼ処理
        Alamofire.request(
            .POST,
            "http://133.242.234.139/api/favorite.php",
            parameters: [
                "illust_id": illustId
            ]
        ).responseJSON { (request, response, JSON, error) in
            println(JSON)
        }
        
        
        // ふぁぼのカウントを反映
        sender.likeCount++
        
        // ふぁぼ数のデータを更新
        illusts[sender.rowId!].likeCount = sender.likeCount
    }

    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        
        if (indexPath.row == 0)
        {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    
    @IBAction func bookmarkButtonPressed(sender: AnyObject) {
        if self.bookmarked != false {
            return
        }
        
        let userId = storage.integerForKey("user_id")
        // self.bookmarkButton.setTitle(" ブックマーク中… ", forState: .Normal)
        
        // お題ふぁぼ処理
        Alamofire.request(
            .POST,
            "http://133.242.234.139/api/like_title.php",
            parameters: [
                "user_id": userId,
                "title_id": titleId!
            ]
            ).responseJSON { (request, response, JSON, error) in
                println(JSON)
                if error == nil {
                    self.bookmarked = true
                    self.tableView.reloadData()
                    // self.bookmarkButton.setTitle(" ブックマーク済み ", forState: .Normal)
                }
            }
    }
    
    
    // 投稿ボタンが押された時
    @IBAction func tapButton(sender : AnyObject) {
        // アクションシートの作成
        var sheet: UIActionSheet = UIActionSheet()
        let title: String = "このお題に送るイラストを選んでください"
        sheet.title  = title
        sheet.delegate = self
        sheet.addButtonWithTitle("キャンセル")
        sheet.addButtonWithTitle("写真を撮る")
        sheet.addButtonWithTitle("既存の項目を選択")
        
        // キャンセルボタンのindexを指定
        sheet.cancelButtonIndex = 0
        
        // UIActionSheet表示
        sheet.showInView(self.view)
    }
    
    // メニューから押された時
    func actionSheet(sheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
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
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 画像データの取得
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            var alertController = UIAlertController(title: "確認", message: "写真を投稿してよろしいですか？", preferredStyle: .Alert)
            
            
            let cancelAction = UIAlertAction(title: "いいえ", style: .Default) { action in
                return
            }
            let otherAction = UIAlertAction(title: "はい", style: .Default) { action in
                self.invokePostIllust(image)
            }
            
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
            
            
            presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
    }
    
    
    func invokePostIllust(image: UIImage){
        // くるくるを表示
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // let sendingModal = UIAlertController(title: "写真を投稿中です…", message: "", preferredStyle: .Alert)
        // self.presentViewController(sendingModal, animated: true, completion: nil)
        
        let data = UIImageJPEGRepresentation(image, 0.6) // JPEGデータに変換
        // パラメータを文字列で指定
        let title_id = "\(titleId!)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let user_name = "No Name".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
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
                    upload
                        .responseJSON { request, response, JSON, error in
                        
                        //sendingModal.dismissViewControllerAnimated(false, completion: nil)
                            
                        // くるくるを消す
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            
                        if error != nil {
                            let alertController = UIAlertController(title: "エラー", message: "写真が投稿できませんでした", preferredStyle: .Alert)

                            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                            return
                        }
                            
                        
                        self.invokeGetResponses()
                    }
                case .Failure(let encodingError):
                    // sendingModal.dismissViewControllerAnimated(false, completion: nil)
                    
                    // くるくるを消す
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    
                    let alertController = UIAlertController(title: "エラー", message: "写真が投稿できませんでした", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                        
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        )
    }
}
