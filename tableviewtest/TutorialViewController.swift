//
//  TutorialViewController.swift
//
//  Created by MomijiYamamoto on 2015/09/10.
//
//

import Foundation
import UIKit
class TutorialViewController: UIViewController, UIScrollViewDelegate {
    
    var alert : UIAlertController?
    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    
    let C_NSUSERDEFAULT_FIRST_TIME = "isFirstTimeDone";
    
    // チュートリアルページの数
    let pageSize = 8
    // チュートリアルページのページを表すindicatorの高さ
    let controlH: CGFloat = 20.0
    // 埋め込む画像のの高さと
    let imageW: CGFloat = 475
    let imageH: CGFloat = 327
    let paddingTop: CGFloat = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = self.view.frame.maxX, height = self.view.frame.maxY
        // swipeしてページをめくるViewの生成
        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSizeMake(CGFloat(self.pageSize) * width, 0)
        self.view.addSubview(scrollView)
        for var i = 0; i < self.pageSize; i++ {
            let x = CGFloat(i) * width
            //let margin = height - imageH - twBtnH - paddingTop * 2 - controlH
            // 表示する画像の位置調整
            let diffW = (width - imageW)
            let imageView: UIImageView = UIImageView(frame: CGRectMake(x - (width),0, width, height))
            let image = UIImage(named: ("intro" + String(i)))
                imageView.image = image
            scrollView.addSubview(imageView)
        }
        // チュートリアルのページindicatorの表示
        pageControl = UIPageControl(frame: CGRectMake(0, paddingTop * 2, width, controlH))
        pageControl.numberOfPages = self.pageSize
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        self.view.addSubview(pageControl)
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: C_NSUSERDEFAULT_FIRST_TIME);
        NSUserDefaults.standardUserDefaults().synchronize();
        
    }
    
    static func isTutorialDone() ->Bool{
        let obj: Bool = NSUserDefaults.standardUserDefaults().boolForKey("isFirstTimeDone");
        if (obj){
            return false;
        }
        return true;
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            //let page = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
            //pageControl.currentPage = page
            //if page == 0 {
                self.dismissViewControllerAnimated(false, completion: nil)
            //}
        }
    }
}