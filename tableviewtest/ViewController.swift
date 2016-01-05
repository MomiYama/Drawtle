//
//  ViewController.swift
//  tableviewtest
//
//  Created by sensei on 2015/08/30.
//  Copyright (c) 2015年 senseiswift. All rights reserved.
//

import UIKit
import Alamofire

class Title {
    var text: String
    var titleId: Int
    var illustsUrl: [String]
    var illustsData: [UIImage?]
    var illustsId: [Int]
    
    init(text: String, titleId: Int, illustsId: [Int]){
        self.text = text
        self.titleId = titleId
        self.illustsId = illustsId
        self.illustsUrl = illustsId.map { id in "http://133.242.234.139/api/thumb.php?illust_id=\(id)" }
        self.illustsData = illustsId.map { _ in nil }
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
     var refreshControl:UIRefreshControl!
    
    // 選択状態を解除するIndexPathを入れる変数
    var selectedRow: NSIndexPath?

    var titles: [Title] = []
    
    // key: illustId, value: Optional(illustData)
    var imageCache = [Int: UIImage]()
    
    var readList: [Int] = []
    
    var defaultOffset : CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !TutorialViewController.isTutorialDone() {
            let tutorial = TutorialViewController()
            // self.presentViewController(tutorial, animated: true, completion: nil)
            
            //tutorial.dismissViewControllerAnimated(true, completion: nil)
            //tutorial.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        invokeGetTitles()
    }

    func refresh()
    {
        invokeGetTitles()
    }

    override func viewDidAppear(animated: Bool) {
        defaultOffset = tableView.contentOffset
        println("ContentOffset = \(tableView.contentOffset)")
        println("ContentInset = \(tableView.contentInset)")
    }
    
    // 画面が表示される時に呼ばれるメソッドを追加
    override func viewWillAppear(animated: Bool) {
        
        self.invokeGetTitles()
        super.viewDidDisappear(animated)

        // tableView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0)
        
        // invokeGetTitles(
        tableView.reloadData()
        
        // selectedRowがセットされていたら選択を解除する
        if (selectedRow != nil)
        {
            tableView?.deselectRowAtIndexPath(selectedRow!, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    @IBOutlet weak var spaceBetweenLabelAndImage: NSLayoutConstraint!

    // セルのテキストを追加
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! UITableViewCell
        
        let i = indexPath.row
        
        let title_label = cell.viewWithTag(1) as! UILabel
        title_label.text = titles[i].text
        
        let illustCount = titles[i].illustsUrl.count
        
        let count_label = cell.viewWithTag(2) as! UILabel
        count_label.text = "\(illustCount)"
        //  <color key="textColor" red="0.0" green="0.47843137250000001" blue="1" alpha="1" colorSpace="calibratedRGB"/>
        // red="1" green="0.75215926639999997" blue="0.38359957449999998" alpha="1"
        count_label.textColor = contains(readList, titles[i].titleId)
                                ? UIColor(red:1.0, green:0.75215926639999997, blue: 0.38359957449999998, alpha:1 )
                                : UIColor(red:0.0, green:0.47843137250000001, blue:1, alpha:1 )
        
        let moreLabel = cell.viewWithTag(3) as! UILabel
        moreLabel.hidden = illustCount <= 3
        
        for imageIndex in 0...2 {
            let imageView = cell.viewWithTag(10 + imageIndex) as! UIImageView // ImageView
            
            if titles[i].illustsData.count > imageIndex {
                let illustId = titles[i].illustsId[imageIndex]
                let illustData = titles[i].illustsData[imageIndex]
                let illustUrl = titles[i].illustsUrl[imageIndex]
                
                imageView.frame = CGRectMake(0, 0, 80, 80)
                // imageView.hidden = false
                imageView.image = nil
                if let cacheData = imageCache[illustId] {
                    imageView.image = cacheData
                    print("used cache")
                } else {
                    // imageView.image = nil

                    Alamofire
                        .request(.GET, illustUrl)
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
                imageView.image = nil
                // imageView.hidden = true
            }
            println("imageView loaded")
        }
        
        // 画像がない時 shrink する
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var label: UILabel = UILabel()
        if indexPath.row < titles.count  {
            label.text = titles[indexPath.row].text
        } else {
            label.text = ""
        }
        
        label.font = UIFont.systemFontOfSize(17)
        label.frame.size = CGSizeMake(tableView.frame.width - 32 - 16, 1024)
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label.frame.height + 108
    }
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        selectedRow = indexPath
        
        // SecondViewControllerへ遷移するSegueを呼び出す
        if titles.count > selectedRow!.row {
            performSegueWithIdentifier("showSecondView",sender: nil)
        }
    }
    
    // Segueで遷移時の処理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showSecondView") {
            let secondVC: SecondViewController = (segue.destinationViewController as? SecondViewController)!

            let titleId = titles[selectedRow!.row].titleId
            // SecondViewControllerのtitleIdに選択したtitle_idを設定する
            secondVC.titleId = titleId
            // 既読リスト
            readList.append(titleId)
        }
    }
    
    func invokeGetTitles(){
        Alamofire.request(.GET, "http://133.242.234.139/api/get_titles.php")
            .responseJSON {( _, _, JSON, _ ) in
                self.titles.removeAll()
                if let titles = JSON as? Array<Dictionary<String,AnyObject>> {
                    print(titles)
                    for title in titles {
                        self.titles.append(Title(
                            text: title["title"] as! String,
                            titleId: title["title_id"] as! Int,
                            illustsId: title["illust_ids"] as! [Int]
                        ))
                    }
                    //self.tableView.setContentOffset(CGPoint(x:0, y:0), animated:true)
                    self.tableView.reloadData()
                    //NSTimer.scheduledTimerWithTimeInterval(0.001, target: self.tableView, selector: Selector("reloadData"), userInfo: nil, repeats: false)
                    //NSTimer.scheduledTimerWithTimeInterval(0.002, target: self.tableView, selector: Selector("reloadData"), userInfo: nil, repeats: false)
                }
                self.refreshControl.endRefreshing()
        }
    }
}
