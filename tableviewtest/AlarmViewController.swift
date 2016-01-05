//
//  AlarmViewController.swift
//
//  Created by sensei on 2015/08/30.
//  Copyright (c) 2015年 senseiswift. All rights reserved.
//

import UIKit
import Alamofire

class AlarmViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    typealias Reactions = (
        type: Int,
        date: Int,
        illust_id: Int?,
        title: String,
        title_id: Int
    )

    // 画像のキャッシュ
    var imageCache = [Int: UIImage?]()
    
    var reactions: [Reactions] = []
    
    var storage: NSUserDefaults = NSUserDefaults()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchMentionNumber()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func refresh()
    {
        fetchMentionNumber()
    }
    
    // 画面が表示される時に呼ばれるメソッドを追加
    /*override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // selectedRowがセットされていたら選択を解除する
        if (selectedRow != nil){
            tableView?.deselectRowAtIndexPath(selectedRow!, animated: false)
        }
    }*/
    
    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactions.count
    }
    
    
    
    // セルのテキストを追加
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("AlarmCell", forIndexPath: indexPath) as! UITableViewCell
        
        let reaction = self.reactions[indexPath.row]
        var labelText = ""
        
        switch reaction.type {
            case 1:
                labelText = "あなたのお題「" + reaction.title + "」にイラストが投稿されました"
            case 2:
                labelText = "あなたが投稿した絵が♥されました"
            case 3:
                labelText = "あなたのお題「" + reaction.title + "」がブックマークされました"
            default:
                break
        }
        
        // view の更新
        let label = cell.viewWithTag(1) as! UILabel
        label.text = labelText

        let imageView = cell.viewWithTag(2) as! UIImageView // ImageView
        
        imageView.image = nil
        
        if let illustId = reaction.illust_id {
            imageView.frame = CGRectMake(0, 0, 100, 100)
            
            if let cacheImage = imageCache[illustId] {
                println("used cache")
                imageView.image = cacheImage
            } else {
                Alamofire
                    .request(.GET, "http://133.242.234.139/api/thumb.php?illust_id=\(illustId)")
                    .response() { (request, response, data, error) in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) { () in
                                var illustData = UIImage(data: data! as NSData)
                                self.imageCache[illustId] = illustData
                                imageView.image = illustData
                            }
                        }
                }
            }
        } else {
            imageView.image = UIImage(named: "Bookmark")
        }
        
        return cell
    }
    
    
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        // performSegueWithIdentifier("showSecondView2",sender: nil)
    }
    
    // Segueで遷移時の処理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showSecondView2") {
            let secondVC: SecondViewController = (segue.destinationViewController as? SecondViewController)!
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let reaction = self.reactions[indexPath.row]
                println("== AAA ==\(reaction.title_id)")
                secondVC.titleId = reaction.title_id
            }
        }
    }
    
    
    func fetchMentionNumber(){
        let _user_id = storage.integerForKey("user_id")
        
        Alamofire
            .request(
                .GET,
                "http://133.242.234.139/api/get_reactions.php?user_id=\(_user_id)"
            )
            .responseJSON {( _, _, JSON, _ ) in
                println("==== "+typeof(self)+" ====")
                println(JSON)
                if let dics = JSON as? [Dictionary<String,AnyObject>] {
                    self.reactions = dics.map({(dic) in
                        let _type = dic["type"]! as! Int
                        return (
                            type: _type,
                            date: (dic["date"]! as! String).toInt()!,
                            title: dic["title"]! as! String,
                            title_id: dic["title_id"]! as! Int,
                            illust_id: _type == 3 ? nil : (dic["illust_id"]! as? Int)
                        )
                    })
                    self.tableView.reloadData()
                }
                self.refreshControl.endRefreshing()
        }
    }
    
}