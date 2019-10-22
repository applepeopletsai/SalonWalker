//
//  AccountStoreInfoViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class AccountStoreInfoViewController: BaseViewController, ScrollPageMenuControllDelegate {
    
    @IBOutlet private weak var bottomScrollView: GestureSimultaneouslyScrollView!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reservationButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    private var pageMenuControll: ScrollPageMenuControll?
    
    //店名
    @IBOutlet weak var storeNameLabel: UILabel!
    //評價人數
    @IBOutlet weak var evaluationCountLabel: UILabel!
    //收藏人數
    @IBOutlet weak var collectCountLabel: UILabel!
    //    //右上角_愛心按鈕
    //    @IBOutlet weak var heartButton: UIButton!
    //    //右上角_分享按鈕
    //    @IBOutlet weak var shareButton: UIButton!
    //平日_剪髮字串
    @IBOutlet weak var weekdayTitleLabel: UILabel!
    //平日_剪髮價格
    @IBOutlet weak var weekdayPriceLabel: UILabel!
    //假日_剪髮字串
    @IBOutlet weak var holidayTitleLabel: UILabel!
    //假日_剪髮價格
    @IBOutlet weak var holidayPriceLabel: UILabel!
    
//    //店名
//    private var storeNameString : String = ""
//    //收藏人數
//    private var collectCount : Int = 1164
//    //評價人數
//    private var evuluationCount : Int = 0
//    //平日_剪髮價格
//    private var weekdayPrice : Int = 0
//    //假日_剪髮價格
//    private var holidayPrice : Int = 0
//
//    private var pageMenu : ScrollPageMenuControll?
//
//    /// 頂部Y軸的偏移量
//    private var topOffsetY: CGFloat = 44.0 + 0.0
//    /// 紀錄Y軸的偏移量
//    private var currentOffsetY: CGFloat = 0.0
//    // 紀錄TopView是否已經在頂部，由此來判斷使那個scrollview來偏移
//    private var isScrollToTop: Bool = false
//
//    private var headerViewHeight: CGFloat = 335.0 {
//        didSet {
//            changeConstants()
//        }
//    }
//
//    //MARK: Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupLabelData()
//        initialization()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        pageMenuControll?.resizeFrame()
//    }
//
//    //MARK: Event Handler
//    //右上角_分享按鈕
//    @IBAction func shareButtonHandler(_ sender: UIButton) {
//
//    }
//
//    //右上角_愛心按鈕
//    @IBAction func heartButtonHandler(_ sender: UIButton) {
//
//    }
//
//
//    //MARK: Method
//    func PreviousVCValue(storeNameString: String , evaluationCount: Int , weekdayPrice: Int , holidayPrice: Int){
//        self.storeNameString = storeNameString
//        self.evuluationCount = evaluationCount
//        self.weekdayPrice = weekdayPrice
//        self.holidayPrice = holidayPrice
//    }
//
//    private func initialization() {
//        //ScrollPageMenuControll
//        pageMenu = ScrollPageMenuControll()
//        //場地資訊
//        let storeInformationVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "StoreInformationViewController") as! StoreInformationViewController
//        storeInformationVC.multipleScrollViewProtocol = self
//        //設備
//        let storeEquipmentVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "StoreEquipmentViewController") as! StoreEquipmentViewController
//        storeEquipmentVC.multipleScrollViewProtocol = self
//        //場地照
//        let courtImageVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CourtImageViewController") as! CourtImageViewController
//        courtImageVC.multipleScrollViewProtocol = self
//        //營業資訊
//        let operateInformationVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "OperateInformationViewController") as! OperateInformationViewController
//        operateInformationVC.multipleScrollViewProtocol = self
//
//        pageMenu?.setupPageViewWith(topView: topMenuView, scrollView: contentScrollView, titles: [LocalizedString("SiteInformation"),LocalizedString("Device"),LocalizedString("CourtImage"),LocalizedString("OperateInformation")], childVCs: [storeInformationVC,storeEquipmentVC,courtImageVC,operateInformationVC], baseVC: self, delegate: self, showBorder: true)
//
//        if #available(iOS 11.0, *) {
//            bottomScrollView.contentInsetAdjustmentBehavior = .never
//        }
//        bottomScrollView.delegate = self
//        changeConstants()
//
//        if SizeTool.isIphone5() {
//            self.reservationButtonWidthConstraint.constant = 80.0
//        }
//    }
//
//    private func changeConstants() {
//        bottomViewHeightConstraint.constant = headerViewHeight - topOffsetY
//        headerViewHeightConstraint.constant = headerViewHeight
//    }
//
//    //Label
//    private func setupLabelData() {
//
//        collectCountLabel.text = "\(collectCount) 位收藏"
//        evaluationCountLabel.text = "(\(evuluationCount))"
//        storeNameLabel.text = storeNameString
//        weekdayPriceLabel.text = "$\(weekdayPrice)"
//        holidayPriceLabel.text = "$\(holidayPrice)"
//        navigationTitleLabel.text = storeNameString
//    }

    //MARK: ScrollPageMenuControllDelegare
    func didSelectetPageAt(_ pageIndex: Int) {

    }
//}
//
//extension StoreDetailViewController: UIScrollViewDelegate {
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if  scrollView == bottomScrollView {
//            let offsetY = scrollView.contentOffset.y
//            currentOffsetY = offsetY
//            if (offsetY >= headerViewHeightConstraint.constant - topOffsetY) {
//                self.topView.backgroundColor = UIColor(white: 1, alpha: 1)
//                self.navigationTitleLabel.alpha = 1
//            } else {
//                let alpha = offsetY / (headerViewHeightConstraint.constant - topOffsetY) >= 1.0 ? 1.0 : offsetY / (headerViewHeightConstraint.constant - topOffsetY)
//                self.topView.backgroundColor = UIColor(white: 1, alpha: alpha)
//                self.navigationTitleLabel.alpha = alpha
//            }
//        }
//
//        if isScrollToTop {
//            bottomScrollView.contentOffset = CGPoint(x: 0.0, y: headerViewHeightConstraint.constant - topOffsetY)
//        }
//    }
//}
//
//extension StoreDetailViewController: MultipleScrollViewProtocol {
//
//    func baseScrollViewDidScroll(_ view: UIScrollView, offsetY: CGFloat) {
//        if currentOffsetY < headerViewHeightConstraint.constant - topOffsetY {
//            if offsetY < 0.0 && currentOffsetY == 0.0 {
//                view.contentOffset = CGPoint(x: 0.0, y: offsetY)
//            } else {
//                view.contentOffset = CGPoint.zero
//            }
//        } else {
//            isScrollToTop = true
//            view.contentOffset = CGPoint(x: 0.0, y: offsetY)
//        }
//
//        if offsetY <= 0.0 || currentOffsetY == 0.0 {
//            isScrollToTop = false
//        }
//    }
//
//    func baseScrollViewWillBeginDragging(_ view: UIScrollView, offsetY: CGFloat) {
//
//    }
//
//    func baseScrollViewWillBeginDecelerating(_ view: UIScrollView, offsetY: CGFloat) {
//
//    }
//
//    func baseScrollViewDidEndDecelerating(_ view: UIScrollView, offsetY: CGFloat) {
//
//    }
//
//    func baseScrollViewDidEndDragging(_ view: UIScrollView, offsetY: CGFloat) {
//
//    }
//
}
