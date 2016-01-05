//
//  LikeListVC.swift
//
//  Created by MomijiYamamoto on 2015/09/09.
//
//

import UIKit
import Alamofire


class LikeTabVC: UITableViewController {
    
    typealias LikedTitle = (
        title_id: Int,
        date: Int,
        user_name: String,
        title: String,
        illusts: [String],
        count: Int
    )
    
    var likedTitles: [LikedTitle] = []
    
    var storage: NSUserDefaults = NSUserDefaults()
    
    var refresher:UIRefreshControl!
    
    // UIViewController
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        super.viewDidLoad()
        self.invokeGetLikedTitles()
        
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(refresher)
    }
    
    func refresh()
    {
        invokeGetLikedTitles()
    }

    
    // UIViewController
    // Segueで遷移時の処理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showLikeTabVCTo2ndVC") {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let secondVC = (segue.destinationViewController as? SecondViewController)!
                // SecondViewControllerのtitleIdに選択したtitle_idを設定する
                secondVC.titleId = self.likedTitles[indexPath.row].title_id
            }
        }
    }
    
    // UITableViewDataSource
    // セルのテキストを追加
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = self.likedTitles[indexPath.row].title

        return cell
    }

    // UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likedTitles.count
    }
    

    
    // UITableViewDelegate
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        // SecondViewControllerへ遷移するSegueを呼び出す
        //performSegueWithIdentifier("showFoobar",sender: nil)
    }
    
    
    func invokeGetLikedTitles(){
        let _user_id = storage.integerForKey("user_id")

        Alamofire
            .request(
                .GET,
                "http://133.242.234.139/api/get_liked_titles.php?user_id=\(_user_id)"
            )
            .responseJSON {( _, _, JSON, _ ) in
                println("== get_liked_titles ==")
                println(JSON)
                if let dics = JSON as? [Dictionary<String,AnyObject>] {
                    self.likedTitles = dics.map({(dic) in
                        LikedTitle(
                            title_id: dic["title_id"]! as! Int,
                            date: (dic["date"]! as! String).toInt()!,
                            user_name: dic["user_name"]! as! String,
                            title: dic["title"]! as! String,
                            illusts: dic["illusts"]! as! [String],
                            count: dic["count"]! as! Int
                        )
                    })
                    self.tableView.reloadData()
                }
                self.refresher.endRefreshing()
        }
    }
}