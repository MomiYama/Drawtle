//
//  TabBarVC.swift
//  teamApple
//
//  Created by yohsukeino on 2015/09/10.
//
//

import Foundation
import UIKit
import Alamofire

func typeof<T>(a: T)-> String {
    return "\(a.dynamicType)"
}

class TabBarVC: UITabBarController,UITabBarControllerDelegate {
    
    typealias Reactions = (
        type: Int,
        date: Int,
        illust_id: Int?,
        title: String,
        title_id: Int
    )
    
    var reactions: [Reactions] = []
    
    var storage: NSUserDefaults = NSUserDefaults()
    
    override func viewDidLoad() {
        self.delegate = self
        self.fetchMentionNumber()
        super.viewDidLoad()
    }
    
    var lastSelectedViewController : UIViewController?
    
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
                    if self.storage.objectForKey("latest_reaction_date") == nil {
                        self.storage.setObject(0, forKey: "latest_reaction_date")
                    }
                    
                    var dates = self.reactions.map({reaction in reaction.date })
                    sort(&dates)
                    if let latest = dates.last {
                        let _latest = self.storage.integerForKey("latest_reaction_date")
                        let new_reactions = dates.filter({(date) in date > _latest})
                        (self.tabBar.items as! [UITabBarItem])[1].badgeValue = (new_reactions.count == 0) ? nil : "\(new_reactions.count)"
                        if self.selectedIndex == 1 {
                            (self.tabBar.items as! [UITabBarItem])[1].badgeValue = nil
                            if(latest > _latest){
                                self.storage.setObject(latest, forKey: "latest_reaction_date")
                            }
                        }
                    }
                    
                }
        }
    }
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        println("===="+typeof(viewController)+"====")
        self.fetchMentionNumber()
        if viewController is UINavigationController {
            let a = viewController as! UINavigationController
            let b = a.topViewController
            
            let didChangedView = b != lastSelectedViewController
            lastSelectedViewController = b
            
            if let c = b as? AlarmViewController {
                let tableView = c.view.viewWithTag(999) as! UITableView
                tableView.setContentOffset(CGPointMake(0, 0 - tableView.contentInset.top), animated:true)
                if didChangedView { c.fetchMentionNumber() }
            } else if let c = b as? ViewController {
                // c.invokeGetTitles()
                c.tableView.setContentOffset(CGPointMake(0, 0 - c.tableView.contentInset.top), animated:true)
                if didChangedView { c.invokeGetTitles() }
            } else if let c = b as? LikeTabVC {
                let tableView = c.view as! UITableView
                tableView.setContentOffset(CGPointMake(0, 0 - tableView.contentInset.top), animated:true)
                if didChangedView { c.invokeGetLikedTitles() }
            }
            
            (self.tabBar.items as! [UITabBarItem])[self.selectedIndex].badgeValue = nil
        }
    }
    
    
}