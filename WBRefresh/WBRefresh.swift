//
//  WBRefreshHeaderView.swift
//  WBPullToRefresh
//
//  Created by caowenbo on 16/1/13.
//  Copyright © 2016年 曹文博. All rights reserved.
//

import UIKit

private let pullText = "下拉加载更多"
private let promptText = "松开即可刷新"
private let refreshtext = "正在为你疯狂刷新中"
private let headerViewTag = 888


 extension UIScrollView{
    
    var header:WBRefreshHeaderView?{
        return viewWithTag(headerViewTag) as? WBRefreshHeaderView
    }
    
    func refreshBlock(refreshBlock:()->Void){
        
        if let header = header{
            header.action = refreshBlock
        }else{
            alwaysBounceVertical = true
            let header =  WBRefreshHeaderView.init(self, refreshBlock:refreshBlock)
            header.tag = headerViewTag
        }
    }
    
    func endRefresh(){
        header?.endRefeshing()
        
    }
    
    func removeObserve(){
        header?.scrollView.removeObserver(header!, forKeyPath: "contentOffSet")
    }
}


//滚动的最大高度
private let maxScrollHeight:CGFloat = 110
//下拉刷新的界限
let refreshHeight:CGFloat = 90

class WBRefreshHeaderView: UIView{
    
    //  下拉的进度
    private var progress:CGFloat!
    //  需要添加刷新的tableView
    private weak var scrollView:UIScrollView!
    //    太阳
    private var sun:RefreshView?
    //    行走的小人
    private var people:RefreshView?
    //   显示的文字
    private var hearderLabel:UILabel?
    //    是否正在刷新
    private var loading = false
    //   刷新时的action
    private var action:()->Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init(_ scrollView:UIScrollView,refreshBlock:()->Void) {
        let frame = CGRectMake(0, -maxScrollHeight, CGRectGetWidth(scrollView.frame), maxScrollHeight)
        self.init(frame:frame)
        
        self.action = refreshBlock
        self.scrollView = scrollView
        self.scrollView.addObserver(self, forKeyPath:"contentOffset", options:.Initial, context: nil)
        self.scrollView.addSubview(self)
        self.clipsToBounds = true
        
        self.setUpRefreshImage()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    func endRefeshing(){
        
        if !loading{
            return
        }
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.scrollView.contentInset.top -= refreshHeight
        }
        
        people!.stopAnimating()
        loading = false
        
    }
    
    //    初始化图片
    func setUpRefreshImage(){
        
        let peopleImage = UIImage.imageName("walk3")
        let sunImage = UIImage.imageName("sun")
        
        people = RefreshView.init(image:peopleImage, endLocation:CGPoint(x:peopleImage.size.width, y: CGRectGetHeight(bounds)-peopleImage.size.height*0.5 - 15),ratio:1.0)
        sun = RefreshView.init(image:sunImage, endLocation:CGPoint(x:CGRectGetMaxX(bounds) - 50, y:20+sunImage.size.height*0.5),ratio:2.5)
        
        hearderLabel = UILabel.init()
        hearderLabel!.textColor = UIColor.grayColor()
        
        addSubview(people!)
        addSubview(sun!)
        addSubview(hearderLabel!)
        
    }
    
    //   更新view的位置
    func updateLocation(){
        
        people?.updateLocations(progress)
        sun?.updateLocations(progress)
        
        self.backgroundColor = UIColor.init(white: 0.7 * progress + 0.2, alpha: 1.0)
        
        if loading {
            return
        }
        sun?.rotation(progress)
    }
    
    
    //    KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //       有navigationController的情况下，scorllView 的inset.top为64
        var visibleHeight = max(0, -scrollView.contentOffset.y - scrollView.contentInset.top)
        
        
        if loading {
            //  刷新的时候inset.top变多，需要更改visibleHeight
            visibleHeight = max(0, -scrollView.contentOffset.y - scrollView.contentInset.top + refreshHeight)
            if visibleHeight > maxScrollHeight{
                scrollView.contentOffset.y = -scrollView.contentInset.top - maxScrollHeight + refreshHeight
            }
        }else{
            if visibleHeight > maxScrollHeight{
                scrollView.contentOffset.y = -scrollView.contentInset.top - maxScrollHeight
            }
        }
        
        
        progress = min(1, visibleHeight/refreshHeight)
        updateLocation()
        
        if loading{
            return
        }
        
        
        if visibleHeight>refreshHeight{
            if visibleHeight > refreshHeight + 5{
                            hearderLabel!.text = promptText
            }
            if !scrollView.dragging{
                loading = true
                action()
                hearderLabel!.text = refreshtext
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.scrollView.contentInset.top = self.scrollView.contentInset.top + refreshHeight
                    self.scrollView.contentOffset.y = -self.scrollView.contentInset.top
                })
                
                people!.walk()
            }
        }else{
            
            hearderLabel?.text = pullText
        }
        
        hearderLabel?.sizeToFit()
        hearderLabel?.center = CGPoint(x: CGRectGetMidX(bounds), y:maxScrollHeight - refreshHeight * 0.5)
        
        
    }
    

    
}//WBRefreshHeaderView

extension UIImage{
   private class func imageName(name:String) -> UIImage{
        
        let str = NSBundle.mainBundle().pathForResource("WBRefresh", ofType: "bundle")
        let bundle = NSBundle.init(path: str!)
        return UIImage.init(named:name, inBundle: bundle, compatibleWithTraitCollection: nil)!
        
    }
}


private let rotationTime:Double = 2

private class RefreshView:UIImageView{
    
    private var endLocation:CGPoint!
    private var startLocation:CGPoint!
    //    移动速率
    private var ratio:CGFloat!
    
    
    convenience init(image:UIImage,endLocation:CGPoint, ratio:CGFloat) {
        self.init(image: image)
        self.endLocation = endLocation
        self.startLocation = CGPoint(x: endLocation.x, y: endLocation.y+ratio*refreshHeight)
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLocations(progress:CGFloat){
        self.center = CGPoint(x: startLocation.x, y: startLocation.y + (endLocation.y - startLocation.y) * CGFloat(progress))
    }
    
    func walk(){
        self.animationImages = [UIImage.imageName("walk3"),UIImage.imageName("walk4")]
        self.animationDuration = 0.5
        self.startAnimating()
    }
    
    
    
    func rotation(progress:CGFloat){
        
        if let _ = layer.animationForKey("rotation"){
            if progress < 1{
                layer.removeAnimationForKey("rotation")
            }
            return
        }
        
        if progress >= 1 {
            let animation = CAKeyframeAnimation()
            animation.keyPath = "transform.rotation"
            animation.repeatCount = MAXFLOAT
            animation.values = [0,M_PI * 2]
            animation.duration = rotationTime
            layer.addAnimation(animation, forKey:"rotation")
            return
            
        }
        
        self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)*progress * 4)
    }
    
    
}
