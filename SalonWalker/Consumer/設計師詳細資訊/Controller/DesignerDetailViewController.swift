//
//  DesignerDetailViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/30.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import LLCycleScrollView
import Cosmos
import Kingfisher

class DesignerDetailViewController: BaseViewController {

    @IBOutlet private weak var bottomScrollView: GestureSimultaneouslyScrollView!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var cycleCoverBaseView: UIView!
    @IBOutlet private weak var titleNameLabel: UILabel!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var evaluationCountLabel: UILabel!
    @IBOutlet private weak var favCountLabel: UILabel!
    @IBOutlet private weak var favButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var reservationButton: IBInspectableButton! // 預約、分享場地資訊
    @IBOutlet private weak var reportButton: UIButton!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var starView: CosmosView!
    @IBOutlet private weak var bottomScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var photoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var reservationButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    
    private let pageMenuControl = ScrollPageMenuControl()
    private let personalVC = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: PersonalInfoViewController.self)) as! PersonalInfoViewController
    private let serviceVC = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceViewController.self)) as! ServiceViewController
    private let portfolioVC = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: PortfolioViewController.self)) as! PortfolioViewController
    private let serviceTimeVC = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceTimeViewController.self)) as! ServiceTimeViewController
    
    /// 頂部Y軸的偏移量
    private var topOffsetY: CGFloat = 44 + 0.0
    /// 紀錄Y軸的偏移量
    private var currentOffsetY: CGFloat = 0.0
    // 紀錄TopView是否已經在頂部，由此來判斷使那個scrollview來偏移
    private var isScrollToTop: Bool = false
    
    private var headerViewHeight: CGFloat = 290.0 {
        didSet {
            changeConstraints()
        }
    }
    
    private var type: ShowDetailType = .canBook
    private var dId = 0
    private var designerDetailModel: DesignerDetailModel?
    private var previewModel: DesignerDetailModel?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        initialize()
        addObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Metohd
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(dId: Int) {
        self.dId = dId
    }
    
    func setupVCWith(previewModel: DesignerDetailModel) {
        self.dId = previewModel.dId
        self.previewModel = previewModel
        self.type = .onlyCheck
    }
    
    func resetDataByBranch(dId: Int) {
        self.dId = dId
        self.callAPI(forceRefresh: true)
    }
    
    func resetDataByRemoteNotification(dId: Int) {
        self.dId = dId
        self.callAPI(forceRefresh: true)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterLoginout), name: NSNotification.Name(rawValue: kRefreshUIAfterLoginout), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUIAfterLoginout), name: NSNotification.Name(rawValue: kAPISyscode_501), object: nil)
    }
    
    @objc private func refreshUIAfterLoginout() {
        callAPI(forceRefresh: true)
    }
    
    private func callAPI(forceRefresh: Bool = false) {
        if designerDetailModel == nil || forceRefresh {
            apiGetDesignerDetail()
        }
    }
    
    private func initialize() {
        if #available(iOS 11.0, *) {
            bottomScrollView.contentInsetAdjustmentBehavior = .never
        }
        
        personalVC.multipleScrollViewProtocol = self
        serviceVC.multipleScrollViewProtocol = self
        portfolioVC.multipleScrollViewProtocol = self
        serviceTimeVC.multipleScrollViewProtocol = self
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: contentScrollView, titles: [LocalizedString("Lang_DD_001"), LocalizedString("Lang_DD_002"), LocalizedString("Lang_DD_003"), LocalizedString("Lang_DD_004")], childVCs: [personalVC, serviceVC, portfolioVC, serviceTimeVC], baseVC: self, delegate: self, showBorder: true)
        
        changeConstraints()
        setupPhotoImageView()
    }
    
    private func setupPhotoImageView() {
        if SizeTool.isIphone5() {
            self.photoImageViewWidthConstraint.constant = 80.0
        }
        self.photoImageView.layer.cornerRadius = self.photoImageViewWidthConstraint.constant / 2
    }
    
    private func changeConstraints() {
        bottomScrollViewHeightConstraint.constant = headerViewHeight - topOffsetY
        headerViewHeightConstraint.constant = headerViewHeight
    }
    
    private func resetDesignerDetailModel() {
        if let model = previewModel {
            designerDetailModel?.headerImgUrl = model.headerImgUrl
            designerDetailModel?.nickName = model.nickName
            designerDetailModel?.characterization = model.characterization
            designerDetailModel?.position = model.position
            designerDetailModel?.cityName = model.cityName
            designerDetailModel?.areaName = model.areaName
            designerDetailModel?.experience = model.experience
            designerDetailModel?.licenseImg = model.licenseImg
            designerDetailModel?.coverImg = model.coverImg
        }
    }
    
    private func setupDesignerDetailUI() {
        self.dismissButton.setImage(UIImage(named: (self.type == .onlyCheck) ? "ic_close_w" : "icon_arrow_l_black"), for: .normal)
        if (SystemManager.getAppIdentity() == .SalonWalker && !UserManager.isLoginSalonWalker()) {
            self.favButton.isHidden = true
            self.reportButton.isHidden = true
        } else {
            if self.type == .onlyCheck {
                self.favButton.isHidden = true
                self.shareButton.isHidden = true
                self.reportButton.isHidden = true
            } else {
                self.favButton.isHidden = false
                self.shareButton.isHidden = false
                self.reportButton.isHidden = false
            }
        }
        
        switch UserManager.sharedInstance.userIdentity {
        case .consumer?:
            if !(designerDetailModel?.isRes ?? false) ||
                UserManager.sharedInstance.accountStatus == .suspend_temporary ||
                UserManager.sharedInstance.accountStatus == .suspend_permanent ||
                self.type == .onlyCheck ||
                (SystemManager.getAppIdentity() == .SalonWalker && !UserManager.isLoginSalonWalker()) {
                self.reservationButton.isHidden = true
                self.reservationButtonWidthConstraint.constant = 0
            } else {
                self.reservationButton.isHidden = false
                self.reservationButtonWidthConstraint.constant = (SizeTool.isIphone5()) ? 80 : 100
            }
            break
        case .store?:
            self.reservationButton.setTitle(LocalizedString("Lang_DD_026"), for: .normal)
            self.reservationButton.setImage(nil, for: .normal)
            self.reservationButton.imageViewLabelSpace = 0
            self.reservationButton.titleLabel?.font = UIFont.systemFont(ofSize: (SizeTool.isIphone5()) ? 12 : 14)
            self.reservationButtonWidthConstraint.constant = (SizeTool.isIphone5()) ? 80 : 100
            break
        default:
            self.reservationButton.isHidden = true
            self.reservationButtonWidthConstraint.constant = 0
            break
        }
        
        if let model = designerDetailModel {
            if let url = model.headerImgUrl, url.count > 0 {
                self.photoImageView.setImage(with: url)
            } else {
                self.photoImageView.image = UIImage(named: "img_account_user")
            }
            self.setupCycleCoverView(model.coverImg.map({ $0.imgUrl ?? "" }))
            self.badgeImageView.isHidden = (!model.isTop)
            self.titleNameLabel.text = model.nickName
            self.nameLabel.text = model.nickName
            self.addressLabel.text = "\(model.cityName) \(model.areaName),\(model.langName)"
            self.evaluationCountLabel.text = "(\(model.evaluationTotal))"
            self.favCountLabel.text = "\(model.favTotal)" + LocalizedString("Lang_DD_021")
            self.favButton.setImage((model.isFav) ? UIImage(named: "icon_like_active") : UIImage(named: "icon_like_normal"), for: .normal)
            self.starView.rating = model.evaluationAve
            
            self.personalVC.designerDetailModel = nil
            self.serviceVC.designerDetailModel = nil
            self.portfolioVC.designerDetailModel = nil
            self.serviceTimeVC.designerDetailModel = nil
            self.setDesignerModel()
        }
    }
    
    private func setDesignerModel() {
        guard let model = designerDetailModel else { return }
        switch pageMenuControl.getCurrentPage() {
        case 0:
            personalVC.designerDetailModel = model
            break
        case 1:
            serviceVC.designerDetailModel = model
            break
        case 2:
            portfolioVC.designerDetailModel = model
            break
        case 3:
            serviceTimeVC.designerDetailModel = model
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
    
    private func handlerEditFavSuccess() {
        self.designerDetailModel!.isFav = !self.designerDetailModel!.isFav
        AnimationTool.favImageAnimation(sender: self.favButton, isFav: self.designerDetailModel!.isFav)
    }
    
    // MARK: Event Handler
    @IBAction private func starViewDidTap(_ sender: UIButton) {
        let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as! CommentViewController
        vc.setupVCWith(dId: dId, pId: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func reportButtonPress(_ sender: UIButton) {
        PresentationTool.showReportAlert_OnlyReasonWith(leftButtonAction: nil, rightButtonAction: { [unowned self] (text) in
            self.apiGiveDesignerReportedWithContent(text)
        })
    }
    
    // 消費者：預約；場地：分享場地資訊
    @IBAction private func reservationButtonPress(_ sender: UIButton) {
        #if SALONWALKER
        // 預約
        guard let model = designerDetailModel else { return }
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing:ReserveDesignerViewController.self)) as! ReserveDesignerViewController
        vc.setupVCWith(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
        #else
        // 分享場地資訊
        if UserManager.sharedInstance.userIdentity == .store {
            SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_DD_027"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_027"), leftHandler: nil, rightHandler: {
                self.apiProviderSharePlaces()
            })
        }
        #endif
    }
    
    @IBAction private func favButtonPress(_ sender: UIButton) {
        apiEditFavDesignerList()
    }
    
    @IBAction private func shareButtonPress(_ sender: UIButton) {
        guard let model = designerDetailModel else { return }
        
        BranchManager.createDeepLinkUrl(dId: model.dId, title: model.nickName, contentDescription: model.characterization, imageUrl: model.headerImgUrl, success: { (url) in
            
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
    
    @IBAction private func dismissButtonPress(_ sender: UIButton) {
        if type == .onlyCheck {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: API
    private func apiGetDesignerDetail() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            DetailManager.apiGetDesignerDetail(dId: dId, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.designerDetailModel = model?.data
                    self?.resetDesignerDetailModel()
                    self?.setupDesignerDetailUI()
                    self?.removeMaskView()
                    self?.hideLoading()
                } else {
                    self?.endLoadingWith(model: model)
                }
            }, failure: { [weak self] (error) in
                self?.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGiveDesignerReportedWithContent(_ content: String) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            DetailManager.apiGiveDesignerReported(dId: dId, content: content, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_006"), body: "")
                    self?.hideLoading()
                } else {
                    self?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiEditFavDesignerList() {
        guard let model = designerDetailModel else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            let act = (model.isFav) ? "del" : "add"
            if UserManager.sharedInstance.userIdentity == .consumer {
                HomeManager.apiEditFavDesignerList(ouId: model.ouId, act: act, success: { (model) in
                    if model?.syscode == 200 {
                        self.handlerEditFavSuccess()
                        self.hideLoading()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
                })
            } else {
                HomeManager.apiEditFavProviderList(pId: nil, dId: model.dId, act: act, success: { (model) in
                    if model?.syscode == 200 {
                        self.handlerEditFavSuccess()
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
    
    private func apiProviderSharePlaces() {
        guard let douId = designerDetailModel?.ouId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            PushManager.apiProviderSharePlaces(douId: douId, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    PresentationTool.showNoButtonAlertWith(image: nil, message: LocalizedString("Lang_DD_028"), autoDismiss: false, completion: nil)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension DesignerDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  scrollView == bottomScrollView {
            let offsetY = scrollView.contentOffset.y
            currentOffsetY = offsetY
            if (offsetY >= headerViewHeightConstraint.constant - topOffsetY) {
                self.topView.backgroundColor = UIColor(white: 1, alpha: 1)
                self.titleNameLabel.alpha = 1
            } else {
                let alpha = offsetY / (headerViewHeightConstraint.constant - topOffsetY) >= 1.0 ? 1.0 : offsetY / (headerViewHeightConstraint.constant - topOffsetY)
                self.topView.backgroundColor = UIColor(white: 1, alpha: alpha)
                self.titleNameLabel.alpha = alpha
            }
        }
        
        if isScrollToTop {
            bottomScrollView.contentOffset = CGPoint(x: 0.0, y: headerViewHeightConstraint.constant - topOffsetY)
        }
    }
}

extension DesignerDetailViewController: MultipleScrollViewProtocol {
    
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

extension DesignerDetailViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.setDesignerModel()
        }
    }
}

