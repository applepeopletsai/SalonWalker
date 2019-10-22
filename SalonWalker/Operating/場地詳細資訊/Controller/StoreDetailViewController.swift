//
//  StoreDetailViewController.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/7.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos
import LLCycleScrollView
import Kingfisher

enum ShowDetailType {
    case canBook
    case onlyCheck
}

class StoreDetailViewController: BaseViewController {

    @IBOutlet private weak var bottomScrollView: GestureSimultaneouslyScrollView!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reservationButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reservationButton: IBInspectableButton!
    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var evaluationCountLabel: UILabel!
    @IBOutlet private weak var collectCountLabel: UILabel!
    @IBOutlet private weak var starView: CosmosView!
    @IBOutlet private weak var heartButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var reportButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var cycleCoverBaseView: UIView!
    @IBOutlet private weak var priceLabelHeight: NSLayoutConstraint!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let storeInformationVC = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreInformationViewController.self)) as! StoreInformationViewController
    private let storeEquipmentVC = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreEquipmentViewController.self)) as! StoreEquipmentViewController
    private let courtImageVC = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: CourtImageViewController.self)) as! CourtImageViewController
    private let operateInformationVC = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperateInformationViewController.self)) as! OperateInformationViewController
    
    /// 頂部Y軸的偏移量
    private var topOffsetY: CGFloat = 44.0 + 0.0
    /// 紀錄Y軸的偏移量
    private var currentOffsetY: CGFloat = 0.0
    // 紀錄TopView是否已經在頂部，由此來判斷使那個scrollview來偏移
    private var isScrollToTop: Bool = false
    
    private var headerViewHeight: CGFloat = 335.0 {
        didSet {
            changeConstants()
        }
    }
    
    private var pId: Int?
    private var type: ShowDetailType = .canBook
    private var providerDetailModel: ProviderDetailModel?
    private var previewModel: ProviderDetailModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        initialization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(pId: Int, type: ShowDetailType) {
        self.pId = pId
        self.type = type
    }
    
    func setupVCWith(previewModel: ProviderDetailModel) {
        self.pId = previewModel.pId
        self.previewModel = previewModel
        self.type = .onlyCheck
    }
    
    func resetDataByBranch(pId: Int) {
        self.pId = pId
        self.providerDetailModel = nil
        self.callAPI()
    }
    
    func resetDataByRemoteNotification(pId: Int) {
        self.pId = pId
        self.providerDetailModel = nil
        self.callAPI()
    }
    
    private func callAPI() {
        if providerDetailModel == nil {
            apiGetProviderDetail()
        }
    }
    
    private func initialization() {
        storeInformationVC.multipleScrollViewProtocol = self
        storeEquipmentVC.multipleScrollViewProtocol = self
        courtImageVC.multipleScrollViewProtocol = self
        operateInformationVC.multipleScrollViewProtocol = self
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: contentScrollView, titles: [LocalizedString("Lang_RT_034"),LocalizedString("Lang_RT_041"),LocalizedString("Lang_HM_008"),LocalizedString("Lang_HM_009")], childVCs: [storeInformationVC,storeEquipmentVC,courtImageVC,operateInformationVC], baseVC: self, delegate: self, showBorder: true)
        
        if #available(iOS 11.0, *) {
            bottomScrollView.contentInsetAdjustmentBehavior = .never
        }
        bottomScrollView.delegate = self
        changeConstants()
    }
    
    private func changeConstants() {
        bottomViewHeightConstraint.constant = headerViewHeight - topOffsetY
        headerViewHeightConstraint.constant = headerViewHeight
    }
    
    private func resetProviderDetailModel() {
        if let model = previewModel {
            providerDetailModel?.nickName = model.nickName
            providerDetailModel?.telArea = model.telArea
            providerDetailModel?.tel = model.tel
            providerDetailModel?.uniformNumber = model.uniformNumber
            providerDetailModel?.characterization = model.characterization
            providerDetailModel?.contactInformation = model.contactInformation
            providerDetailModel?.cityName = model.cityName
            providerDetailModel?.areaName = model.areaName
            providerDetailModel?.address = model.address
            providerDetailModel?.equipment = model.equipment
            providerDetailModel?.coverImg = model.coverImg
            if model.lat != -1 && model.lng != -1 {
                providerDetailModel?.lat = model.lat
                providerDetailModel?.lng = model.lng
            }
        }
    }
    
    private func setupProviderDetailUI() {
        if type == .canBook &&
            UserManager.sharedInstance.accountStatus == .enable &&
            UserManager.sharedInstance.userIdentity == .designer {
            reservationButton.isHidden = false
            reservationButtonWidthConstraint.constant = (SizeTool.isIphone5()) ?  80.0 : 100.0
        } else {
            reservationButton.isHidden = true
            reservationButtonWidthConstraint.constant = 0.0
        }
        
        if type == .onlyCheck {
            heartButton.isHidden = true
            shareButton.isHidden = true
            reportButton.isHidden = true
            backButton.setImage(UIImage(named: "ic_close_w"), for: .normal)
        } else {
            backButton.setImage(UIImage(named: "icon_arrow_l_black"), for: .normal)
        }
        
        if let model = providerDetailModel {
            setupCycleCoverView(model.coverImg.map({ $0.imgUrl ?? "" }))
             heartButton.setImage((model.isFav) ? UIImage(named: "icon_like_active") : UIImage(named: "icon_like_normal"), for: .normal)
            navigationTitleLabel.text = model.nickName
            storeNameLabel.text = model.nickName
            priceLabel.attributedText = DetailManager.getPriceStringWith(svcHoursPrices: model.svcHoursPrices, svcTimesPrices: model.svcTimesPrices, svcLeasePrices: model.svcLeasePrices, type: "Detail")
            starView.rating = model.evaluationAve
            evaluationCountLabel.text = "(\(model.evaluationTotal))"
            collectCountLabel.text = "\(model.favTotal)" + LocalizedString("Lang_DD_021")
            
            storeInformationVC.providerDetailModel = nil
            storeEquipmentVC.providerDetailModel = nil
            courtImageVC.providerDetailModel = nil
            operateInformationVC.providerDetailModel = nil
            setProviderModel()
        }
        
        if UserManager.sharedInstance.userIdentity == .consumer {
            priceLabelHeight.constant = 0
        }
    }
    
    private func setProviderModel() {
        guard let model = providerDetailModel else { return }
        switch pageMenuControl.getCurrentPage() {
        case 0:
            storeInformationVC.providerDetailModel = model
            break
        case 1:
            storeEquipmentVC.providerDetailModel = model
            break
        case 2:
            courtImageVC.providerDetailModel = model
            break
        case 3:
            operateInformationVC.providerDetailModel = model
            break
        default:break
        }
    }
    
    private func setupCycleCoverView(_ imageUrls: [String]) {
        let cycleView = LLCycleScrollView.llCycleScrollViewWithFrame(self.cycleCoverBaseView.bounds)
        cycleView.autoScrollTimeInterval = 3.0
        cycleView.coverImage = UIImage(named: "logo_salon_walker_132x132")
        cycleView.imageViewContentMode = .scaleAspectFill
        cycleView.scrollDirection = .horizontal
        cycleView.customPageControlStyle = .system
        cycleView.pageControlCurrentPageColor = color_8F92F5
        cycleView.imagePaths = imageUrls
        self.cycleCoverBaseView.addSubview(cycleView)
    }
    
    // MARK: Event Handler
    @IBAction private func starViewDidTap(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as! CommentViewController
        vc.setupVCWith(dId: nil, pId: pId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func shareButtonClick(_ sender: UIButton) {
        guard let model = providerDetailModel else { return }
        
        BranchManager.createDeepLinkUrl(pId: model.pId, title: model.nickName, contentDescription: model.characterization, imageUrl: model.headerImgUrl, success: { (url) in
            
            let content = "\(model.nickName)\n\(model.characterization)\n\n\(url)"
            
            if let coverImgUrl = model.coverImg.first?.imgUrl, let url = URL(string: coverImgUrl) {
                SystemManager.showLoading()
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { (image, error, type, url) in
                    SystemManager.hideLoading()
                    if error != nil {
                        SystemManager.showErrorMessageBanner(title: error?.localizedDescription ?? LocalizedString("Lang_GE_010"), body: "")
                    } else {
                        if let image = image {
                            SystemManager.goingToShareInfoAbout(text: content, images: [image])
                        } else {
                            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_010"), body: "")
                        }
                    }
                })
            } else {
                SystemManager.showErrorMessageBanner(title:LocalizedString("Lang_GE_010"), body: "")
            }
        }, failure: { error in
            SystemManager.showErrorMessageBanner(title: error?.localizedDescription ?? LocalizedString("Lang_GE_010"), body: "")
        })
    }
    
    @IBAction private func heartButtonClick(_ sender: UIButton) {
        apiEditFavProviderList()
    }
    
    @IBAction private func backButtonClick(_ sender: UIButton) {
        if self.type == .onlyCheck {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func bookButtonClick(_ sender: UIButton) {
        #if SALONMAKER
        guard let model = providerDetailModel else { return }
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: NoOrderPricingPlanViewController.self)) as! NoOrderPricingPlanViewController
        let provider = OrderDetailInfo_Provider(pId: model.pId, nickName: model.nickName, headerImgUrl: model.headerImgUrl, cityName: model.cityName, areaName: model.areaName, address: model.address, telArea: model.telArea, tel: model.tel, orderStatusName: "")
        let evaluateStatus = EvaluateStatusModel(statusName: "", evaluation: nil)
        let orderDetailInfoModel = OrderDetailInfoModel(moId: nil, doId: nil, bindMoId: nil, bindDoId: nil, orderNo: "", orderType: nil, orderTime: "", estimateEndTime: nil, endTime: nil, deposit: 0, depositStatusName: "", finalPayment: 0, finalPaymentStatusName: "", paymentTypeName: LocalizedString("Lang_RV_015"), orderStatus: 0, member: nil, designer: nil, provider: provider, svcContent: nil, evaluateStatus: evaluateStatus, svcHoursPrices: nil, svcTimesPrices: nil, svcLongLeasePrices: nil)
        vc.setupVCWith(model: orderDetailInfoModel, type: .choose)
        self.navigationController?.pushViewController(vc, animated: true)
        #endif
    }
    
    @IBAction private func reportButtonClick(_ sender: UIButton) {
        PresentationTool.showReportAlert_OnlyReasonWith(leftButtonAction: nil, rightButtonAction: { [unowned self] (text) in
            self.apiGiveProviderReportedWithContent(text)
        })
    }
    
    // MARK: API
    private func apiGetProviderDetail() {
        guard let pId = pId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            DetailManager.apiGetProviderDetail(pId: pId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.providerDetailModel = model?.data
                    self.resetProviderDetailModel()
                    self.setupProviderDetailUI()
                    self.removeMaskView()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { [unowned self] (error) in
                    self.removeMaskView()
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGiveProviderReportedWithContent(_ content: String) {
        guard let pId = pId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            DetailManager.apiGiveProviderReported(pId: pId, content: content, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_006"), body: "")
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: {(error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiEditFavProviderList() {
        guard let model = providerDetailModel, let pId = pId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            let act = (model.isFav) ? "del" : "add"
            HomeManager.apiEditFavProviderList(pId: pId, dId: nil, act: act, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.providerDetailModel!.isFav = !self.providerDetailModel!.isFav
                    AnimationTool.favImageAnimation(sender: self.heartButton, isFav: self.providerDetailModel!.isFav)
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension StoreDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  scrollView == bottomScrollView {
            let offsetY = scrollView.contentOffset.y
            currentOffsetY = offsetY
            if (offsetY >= headerViewHeightConstraint.constant - topOffsetY) {
                self.topView.backgroundColor = UIColor(white: 1, alpha: 1)
                self.navigationTitleLabel.alpha = 1
            } else {
                let alpha = offsetY / (headerViewHeightConstraint.constant - topOffsetY) >= 1.0 ? 1.0 : offsetY / (headerViewHeightConstraint.constant - topOffsetY)
                self.topView.backgroundColor = UIColor(white: 1, alpha: alpha)
                self.navigationTitleLabel.alpha = alpha
            }
        }
        
        if isScrollToTop {
            bottomScrollView.contentOffset = CGPoint(x: 0.0, y: headerViewHeightConstraint.constant - topOffsetY)
        }
    }
}
extension StoreDetailViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.setProviderModel()
        }
    }
}

extension StoreDetailViewController: MultipleScrollViewProtocol {
    
    func baseScrollViewDidScroll(_ view: UIScrollView, offsetY: CGFloat) {
        if currentOffsetY < headerViewHeightConstraint.constant - topOffsetY {
            if offsetY < 0.0 && currentOffsetY == 0.0 {
                view.contentOffset = CGPoint(x: 0.0, y: offsetY)
            } else {
                view.contentOffset = CGPoint.zero
            }
        } else {
            isScrollToTop = true
            view.contentOffset = CGPoint(x: 0.0, y: offsetY)
        }
        
        if offsetY <= 0.0 || currentOffsetY == 0.0 {
            isScrollToTop = false
        }
    }
    
    func baseScrollViewWillBeginDragging(_ view: UIScrollView, offsetY: CGFloat) {}
    func baseScrollViewWillBeginDecelerating(_ view: UIScrollView, offsetY: CGFloat) {}
    func baseScrollViewDidEndDecelerating(_ view: UIScrollView, offsetY: CGFloat) {}
    func baseScrollViewDidEndDragging(_ view: UIScrollView, offsetY: CGFloat) {}
    
}

