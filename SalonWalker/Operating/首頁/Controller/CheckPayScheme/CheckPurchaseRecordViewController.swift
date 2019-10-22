//
//  PurchaseRecordViewController.swift
//  PriceScheme
//
//  Created by Scott.Tsai on 2018/4/3.
//  Copyright © 2018年 Scott.Tsai. All rights reserved.
//

import UIKit

class CheckPurchaseRecordViewController: BaseViewController,ScrollPageMenuControllDelegate {
    
    //MARK: IBOutlet
    //下面結合 ViewController 的 ScrollView
    @IBOutlet weak var purchaseRecordScrollView: UIScrollView!
    //上面顯示標題的 View
    @IBOutlet weak var topView: UIView!
    //控制滑動頁面的View
    @IBOutlet weak var scrollMenuView: TopMenuView!
    //上面的Label
    @IBOutlet weak var topLabel: UILabel!
    
    //MARK: Property
    var pageManuContol : ScrollPageMenuControll?
    var titleString = " "
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        pageManuControlInitFunc()
        topLabel.text = titleString
    }
    //MARK: ScrollPageMenuControll Delegate
    func didSelectetPageAt(_ pageIndex: Int) {
        
    }
    
    //MARK: EvenHandler
    @IBAction func topBackButtonClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Class Method
    func pageManuControlInitFunc(){
        
        pageManuContol = ScrollPageMenuControll()
        
        //已購買
        let purchaseVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CheckPurchaseViewController") as! CheckPurchaseViewController
        //未購買
        let notPurchaseVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CheckNotPurchaseViewController") as! CheckNotPurchaseViewController
        
        pageManuContol?.setupPageViewWith(topView: scrollMenuView, scrollView: purchaseRecordScrollView, titles: [LocalizedString("AlreadyPurchase"),LocalizedString("NotPurchase")], childVCs: [purchaseVC,notPurchaseVC], baseVC: self, delegate: self)
    }
    
    func changeViewControllerInitFunc( titleString : String){
        
        self.titleString = titleString
    }
}
