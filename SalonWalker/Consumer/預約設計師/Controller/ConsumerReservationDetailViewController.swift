//
//  ConsumerReservationDetailViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

/*
 orderStatus (訂單狀態)
 0  付款中                      新訂單
 1  已付訂金 - 待回覆            等待設計師回覆
 2  已付訂金 - 已確定            設計師已回覆訂單 (成立設計師/場地訂單)
 3  訂單已更新服務項目            設計師更新服務項目 / 價格
 4  已完成 - 已付尾款 - 信用卡支付
 5  已完成 - 已付尾款 - 現金支付
 6  已完成 - 待退款              更新服務項目後 總金額 低於 訂金金額
 7  取消預約 - 已退訂金           消費者做取消動作
 8  取消預約 - 已退訂金           設計師做取消動作
 9  取消預約 - 已罰緩             消費者做取消動作
 10 取消預約 - 未回覆             已過特定時間，設計師未回覆訂單自動取消
 11 離開金流                     於付款輸入信用卡號，案返回上一頁 (視為訂單作廢)
 12 服務開始 - 打卡告知            服務時間開始前30分鐘 ~ 服務時間開始後10分鐘可打卡
 13 交易失敗(訂金)                綠界回傳交易失敗 (訂金)
 14 交易失敗(尾款)                綠界回傳交易失敗 (尾款)
 **/

import UIKit

// 消費者預約流程、消費者訂單記錄
class ConsumerReservationDetailViewController: BaseViewController {

    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var cityNameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var commentButton: IBInspectableButton!
    @IBOutlet private weak var commecntButtonWidth: NSLayoutConstraint!
    @IBOutlet private weak var orderDateLabel: UILabel!
    @IBOutlet private weak var orderTimeLabel: UILabel!
    @IBOutlet private weak var depositLabel: UILabel!
    @IBOutlet private weak var depositTipLabel: UILabel!
    @IBOutlet private weak var finalPaymentLabel: UILabel!
    @IBOutlet private weak var finalPaymentTipLabel: UILabel!
    @IBOutlet private weak var paymentTypeLabel: UILabel!
    @IBOutlet private weak var serviceContentLabel: UILabel!
    @IBOutlet private weak var serviceLocationLabel: UILabel!
    @IBOutlet private weak var bottomButton: IBInspectableButton!
    @IBOutlet private weak var naviRightButton: IBInspectableButton!
    @IBOutlet private weak var headerImageViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var serviceTermViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var serviceTermLabel: UILabel!
    @IBOutlet private weak var bottomButtonHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomButtonBottomSpace: NSLayoutConstraint!
    
    private var moId: Int?
    private var orderDetailInfoModel: OrderDetailInfoModel?
    private var reportedReasonArray = [ReportedReasonModel.ReportedItemModel]()
    private lazy var qrCodeScannerVC = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: QRcodeScannerViewController.self)) as! QRcodeScannerViewController
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        initialize()
        apiGetReportedReason()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func setupVCWith(moId: Int) {
        self.moId = moId
    }
    
    func resetDataByRemoteNotification(moId: Int) {
        self.moId = moId
        self.callAPI()
    }
    
    private func callAPI() {
        // OD007
        // 除了預約設計師的流程之外，都需call OD007取得預約詳細資訊
        if moId != nil {
            apiGetMemberOrderInfo()
        }
    }
    
    private func initialize() {
        if SizeTool.isIphone5() { self.headerImageViewWidth.constant = 50.0 }
        setupServiceTermView()
        
        if let model = ReservationManager.shared.reservationDetailModel {
            configureDesignerInfoView(reservationDetailModel: model, orderDetailInfoModel: nil)
            configurePaymentAndOrderTimeView(reservationDetailModel: model, orderDetailInfoModel: nil)
            configureServiceContentView(reservationDetailModel: model, orderDetailInfoModel: nil)
            configureCommentView(reservationDetailModel: model, orderDetailInfoModel: nil)
            view.layoutIfNeeded()
            removeMaskView()
        }
        configureBottomButton(model: nil)
        configureNaviRightButton(model: nil)
    }
    
    private func resetUI() {
        if let model = orderDetailInfoModel {
            configureDesignerInfoView(reservationDetailModel: nil, orderDetailInfoModel: model)
            configurePaymentAndOrderTimeView(reservationDetailModel: nil, orderDetailInfoModel: model)
            configureServiceContentView(reservationDetailModel: nil, orderDetailInfoModel: model)
            configureCommentView(reservationDetailModel: nil, orderDetailInfoModel: model)
            configureBottomButton(model: model)
            configureNaviRightButton(model: model)
            view.layoutIfNeeded()
        }
    }
    
    private func configureDesignerInfoView(reservationDetailModel: ReservationDetailModel?, orderDetailInfoModel: OrderDetailInfoModel?) {
        if let model = reservationDetailModel {
            badgeImageView.isHidden = !(model.isTop ?? false)
            nameLabel.text = model.nickName
            cityNameLabel.text = "\(model.cityName ?? "") \(model.langName ?? "")"
            statusLabel.isHidden = true
            if let url = model.headerImgUrl, url.count > 0 {
                headerImageView.setImage(with: url)
            } else {
                headerImageView.image = UIImage(named: "img_account_user")
            }
        }
        if let model = orderDetailInfoModel {
            badgeImageView.isHidden = !(model.designer?.isTop ?? false)
            nameLabel.text = model.designer?.nickName
            cityNameLabel.text = "\(model.designer?.cityName ?? "") \(model.designer?.langName ?? "")"
            statusLabel.isHidden = false
            statusLabel.text = model.member?.orderStatusName
            if let url = model.designer?.headerImgUrl, url.count > 0 {
                headerImageView.setImage(with: url)
            } else {
                headerImageView.image = UIImage(named: "img_account_user")
            }
        }
    }
    
    private func configurePaymentAndOrderTimeView(reservationDetailModel: ReservationDetailModel?, orderDetailInfoModel: OrderDetailInfoModel?) {
        if let model = reservationDetailModel {
            orderDateLabel.text = "\(model.orderDate ?? "") (\(model.week ?? ""))"
            orderTimeLabel.text = model.orderTime ?? ""
            depositLabel.text = "$\((model.deposit ?? 0).transferToDecimalString())"
            depositTipLabel.text = "(\(LocalizedString("Lang_RD_025")))"
            finalPaymentLabel.text = "$\((model.finalPayment ?? 0).transferToDecimalString())"
            finalPaymentTipLabel.text = "(\(LocalizedString("Lang_RD_026")))"
            paymentTypeLabel.text = LocalizedString("Lang_RV_015")
        }
        if let model = orderDetailInfoModel {
            let date = model.orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
            let day = date.transferToString(dateFormat: "yyyy/MM/dd")
            let week = date.getDayOfWeek().transferToWeekString()
            orderDateLabel.text = "\(day) (\(week))"
            orderTimeLabel.text = model.orderTime.subString(from: 11, to: 15)
            depositLabel.text = "$\((model.deposit).transferToDecimalString())"
            depositTipLabel.text = (model.depositStatusName.count > 0) ? "(\(model.depositStatusName))" : nil
            finalPaymentLabel.text = "$\((model.finalPayment).transferToDecimalString())"
            finalPaymentTipLabel.text = (model.finalPaymentStatusName.count > 0) ? "(\(model.finalPaymentStatusName))" : nil
            paymentTypeLabel.text = LocalizedString("Lang_RV_015")
            
            switch model.orderStatus {
            case 7,8,9,10:
                orderDateLabel.textColor = color_9B9B9B
                orderTimeLabel.textColor = color_9B9B9B
                depositLabel.textColor = color_9B9B9B
                finalPaymentLabel.textColor = color_9B9B9B
                finalPaymentTipLabel.isHidden = true
                break
            default:
                orderDateLabel.textColor = .black
                orderTimeLabel.textColor = .black
                depositLabel.textColor = .black
                finalPaymentLabel.textColor = .black
                finalPaymentTipLabel.isHidden = false
                break
            }
        }
    }
    
    private func configureServiceContentView(reservationDetailModel: ReservationDetailModel?, orderDetailInfoModel: OrderDetailInfoModel?) {
        if let model = reservationDetailModel {
            var serviceContent = ""
            model.svcContent?.svcCategory?.forEach {
                if serviceContent.count == 0 {
                    serviceContent.append($0.name)
                } else {
                    serviceContent.append("/\($0.name)")
                }
            }
            serviceContentLabel.text = serviceContent
            serviceLocationLabel.text = model.placeName
        }
        if let model = orderDetailInfoModel {
            var serviceContent = ""
            model.svcContent?.svcCategory.forEach {
                if serviceContent.count == 0 {
                    serviceContent.append($0.name)
                } else {
                    serviceContent.append("/\($0.name)")
                }
            }
            serviceContentLabel.text = serviceContent
            serviceLocationLabel.text = model.provider?.nickName
        }
    }
    
    private func configureCommentView(reservationDetailModel: ReservationDetailModel?, orderDetailInfoModel: OrderDetailInfoModel?) {
        if let _ = reservationDetailModel {
            commentButton.isHidden = true
            commecntButtonWidth.constant = 0
        }
        if let model = orderDetailInfoModel {
            // 已完成才有評價按鈕
            if model.orderStatus == 4 ||
                model.orderStatus == 5 ||
                model.orderStatus == 6 {
                commentButton.isHidden = false
                commecntButtonWidth.constant = 50
                commentButton.setImage(UIImage(named: (model.evaluateStatus.evaluation == nil) ? "btn_bubble_n_32x29" : "btn_bubble_selected_32x29"), for: .normal)
                commentButton.setTitle(model.evaluateStatus.statusName, for: .normal)
            } else {
                commentButton.isHidden = true
                commecntButtonWidth.constant = 0
            }
        }
    }
    
    private func configureBottomButton(model: OrderDetailInfoModel?) {
        bottomButton.isEnabled = true
        bottomButton.isHidden = false
        bottomButton.backgroundColor = color_8F92F5
        bottomButtonHeight.constant = 50
        bottomButtonBottomSpace.constant = 15
        bottomButton.removeTarget(self, action: nil, for: .allEvents)
        var buttonTitle: String?
        var buttonAction: Selector?
        
        guard let orderStatus = model?.orderStatus else {
            buttonTitle = LocalizedString("Lang_RD_035")
            buttonAction = #selector(confirmBooking)
            bottomButton.setTitle(buttonTitle, for: [.normal, .disabled])
            if let action = buttonAction {
                bottomButton.addTarget(self, action: action, for: .touchUpInside)
            }
            return
        }
        
        // orderStatus狀態請參照最上方的說明
        switch orderStatus {
        case 0,11,13:
            buttonTitle = LocalizedString("Lang_RD_035")
            buttonAction = #selector(confirmBooking)
            break
        case 3,14:
            buttonTitle = LocalizedString("Lang_SD_012")
            buttonAction = #selector(payFinalPayment)
            break
        case 12:
            // 有簽到時間代表已通知設計師
            if (orderDetailInfoModel?.member?.punchInTime?.count ?? 0) > 0 {
                buttonTitle = "✓ \(LocalizedString("Lang_SD_013"))"
                 bottomButton.isEnabled = false
                bottomButton.backgroundColor = color_B7B9F4
            } else {
                buttonTitle = LocalizedString("Lang_SD_009")
                buttonAction = #selector(informDesigner)
            }
            break
        default:
            bottomButton.isHidden = true
            bottomButtonHeight.constant = 0
            bottomButtonBottomSpace.constant = 0
            break
        }
        bottomButton.setTitle(buttonTitle, for: .normal)
        bottomButton.setTitle(buttonTitle, for: .disabled)
        
        if let action = buttonAction {
            bottomButton.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    // 確認預約
    @objc private func confirmBooking() {
        apiMemberOrderPayDeposit()
    }
    
    // 刷尾款
    @objc private func payFinalPayment() {
        apiOrderPayFinalPayment()
    }
    
    // 通知設計師已抵達服務地點(簽到)
    @objc private func informDesigner() {
        let view = SignInOutView.getView(with: self)
        if let view = view {
            UIApplication.shared.keyWindow?.addSubview(view)
        }
    }
    
    private func configureNaviRightButton(model: OrderDetailInfoModel?) {
        var buttonTitle: String?
        var buttonAction: Selector?
        naviRightButton.isHidden = false
        naviRightButton.removeTarget(self, action: nil, for: .allEvents)
        
        guard let orderStatus = model?.orderStatus else {
            buttonTitle = LocalizedString("Lang_RD_023")
            buttonAction = #selector(cancelBook)
            naviRightButton.setTitle(buttonTitle, for: .normal)
            if let action = buttonAction {
                naviRightButton.addTarget(self, action: action, for: .touchUpInside)
            }
            return
        }
        
        // orderStatus狀態請參照最上方的說明
        switch orderStatus {
        case 0,1,2,11,13:
            buttonTitle = LocalizedString("Lang_RD_023")
            buttonAction = #selector(cancelBook)
            break
        case 3,4,5,6,14:
            buttonTitle = LocalizedString("Lang_RD_036")
            buttonAction = #selector(report)
            break
        case 12:
            // 有簽到時間代表已通知設計師
            if (orderDetailInfoModel?.member?.punchInTime?.count ?? 0) > 0 {
                buttonTitle = LocalizedString("Lang_RD_036")
                buttonAction = #selector(report)
            } else {
                buttonTitle = LocalizedString("Lang_RD_023")
                buttonAction = #selector(cancelBook)
            }
            break
        default:
            naviRightButton.isHidden = true
            break
        }

        naviRightButton.setTitle(buttonTitle, for: .normal)
        
        if let action = buttonAction {
            naviRightButton.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    // 取消預約
    @objc private func cancelBook() {
        if moId != nil {
            guard let orderStatus = orderDetailInfoModel?.orderStatus, let orderTime = orderDetailInfoModel?.orderTime else { return }
            var image = UIImage(named: "img_cancelbooking_n")
            var message = LocalizedString("Lang_RV_019")
            var shouldShowAlert = true
            switch orderStatus {
            case 0,11,13:
                shouldShowAlert = false
                popVC()
                break
            case 1:
                message += "\n\(LocalizedString("Lang_RV_020"))"
                break
            case 2:
                // 24小時前: 氣球警告；24小時內: 放鳥
                let orderDay = orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
                if orderDay.timeIntervalSince(Date()) > 24 * 60 * 60 {
                    message += "\n\(LocalizedString("Lang_RV_020"))\n\n\(LocalizedString("Lang_RV_022"))"
                } else {
                    message += "\n\(LocalizedString("Lang_RV_021"))\n\n\(LocalizedString("Lang_RV_023"))"
                    image = UIImage(named: "img_cancelbooking_money")
                }
                break
            case 12:
                message += "\n\(LocalizedString("Lang_RV_021"))\n\n\(LocalizedString("Lang_RV_023"))"
                image = UIImage(named: "img_cancelbooking_money")
                break
            default: break
            }
            if shouldShowAlert {
                PresentationTool.showTwoButtonAlertWith(image: image, message: message, leftButtonTitle: LocalizedString("Lang_RV_032"), leftButtonAction: { [unowned self] in
                    self.apiMembersOrderChgStatus(orderStatus: "cancel")
                    }, rightButtonTitle: LocalizedString("Lang_RV_033"), rightButtonAction: nil)
            }
        } else {
            popVC()
        }
    }
    
    // 檢舉
    @objc private func report() {
        if reportedReasonArray.count > 0 {
            showReportAlert()
        } else {
            apiGetReportedReason(showLoading: true) { [unowned self] in
                self.showReportAlert()
            }
        }
    }
    
    private func showReportAlert() {
        let array = reportedReasonArray.map{ $0.reason }
        PresentationTool.showReportAlert_HaveChooseReason(itemArray: array, leftButtonAction: nil) { [unowned self] (text, index) in
            self.apiGiveMemberOrderReported(rrId: self.reportedReasonArray[index].rrId, content: text)
        }
    }
    
    private func setupServiceTermView() {
        if let svcClause = UserManager.sharedInstance.svcClause {
            let top: CGFloat = 20.0
            let leading: CGFloat = 85.0
            let trailing: CGFloat = 25.0
            let labelWidth = screenWidth - leading - trailing
            
            var text = ""
            for string in svcClause {
                text.append((string == svcClause.last) ? string : "\(string)\n\n")
            }
            let attributedString = NSMutableAttributedString(string: text)
            let range = (text as NSString).range(of: LocalizedString("Lang_LI_008"))
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color_1A1C69, range: range)
            self.serviceTermLabel.attributedText = attributedString
            
            let height = top * 2 + text.height(withConstrainedWidth: labelWidth, font: UIFont.systemFont(ofSize: 12))
            self.serviceTermViewHeight.constant = height
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
            self.serviceTermLabel.addGestureRecognizer(gestureRecognizer)
        } else {
            self.serviceTermViewHeight.constant = 0
        }
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        if gesture.didTapSpecificText(text: LocalizedString("Lang_LI_008"), onLabel: self.serviceTermLabel) {
            SystemManager.openTransactionTerms()
        }
    }
    
    private func handlePayment(model: BaseModel<OrderPayModel>?) {
        if model?.syscode == 200 {
            self.hideLoading()
            if let url = model?.data?.transferUrl, url.count > 0 {
                self.gotoECPay(url: url)
                self.moId = model?.data?.moId
            } else {
                SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_010"), body: "")
            }
        } else {
            self.endLoadingWith(model: model)
        }
    }
    
    private func gotoECPay(url: String) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.setupWebVCWith(url: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func popVC() {
        guard let naviVCs = self.navigationController?.viewControllers else { return }
        for vc in naviVCs {
            if vc is DesignerDetailViewController {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        for vc in naviVCs {
            if vc is HomePageViewController ||
                vc is HairCutViewController {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showPunchInAndOutSuccessAlert(signClass: String, time: String) {
        let image = UIImage(named: (signClass == "Q") ? "img_pop_qrcode_58x58" : "img_pop_gps_51x54")
        let message = ((signClass == "Q") ? "\(LocalizedString("Lang_SD_008"))\n" : "\(LocalizedString("Lang_SD_007"))\n") + "\(LocalizedString("Lang_SD_010"))\n\(LocalizedString("Lang_SD_011"))：\(time)"
        PresentationTool.showOneButtonAlertWith(image: image, message: message, buttonTitle: LocalizedString("Lang_GE_056"), buttonAction: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                if signClass == "Q" {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.apiGetMemberOrderInfo()
                }
            })
        })
    }
    
    private func checkOrderStatus() {
        guard let orderStatus = orderDetailInfoModel?.orderStatus else { return }
        // 若狀態為0，代表消費者在點擊確認預約後至綠界支付頁面，但尚未完成付款動作回來此頁面，此時需打api告知後台消費者離開金流
        if orderStatus == 0 {
            apiMembersOrderChgStatus(orderStatus: "leave")
        }
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
    }
    
    // MARK: Event Handler
    @IBAction private func commentButtonPress(_ sender: UIButton) {
        if orderDetailInfoModel?.evaluateStatus.evaluation == nil {
            guard let dId = orderDetailInfoModel?.designer?.dId, let moId = orderDetailInfoModel?.moId else { return }
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WriteCommentViewController.self)) as! WriteCommentViewController
            vc.setupVCWith(dId: dId, moId: moId)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowCommentViewController.self)) as! ShowCommentViewController
            vc.setupVCWith(model: orderDetailInfoModel!.evaluateStatus.evaluation!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func serviceContentButtonPress(_ sender: UIButton) {
        var svcCategory = [SvcCategoryModel]()
        if let array = ReservationManager.shared.reservationDetailModel?.svcContent?.svcCategory {
            svcCategory = array
        } else if var array = orderDetailInfoModel?.svcContent?.svcCategory {
            for i in 0..<array.count {
                array[i].selectSvcClass = array[i].svcClass
            }
            svcCategory = array
        } else {
            return
        }
        let photoImgUrl = ReservationManager.shared.reservationDetailModel?.photoImgUrl ?? orderDetailInfoModel?.svcContent?.photoImgUrl
        let hairStyle = ReservationManager.shared.reservationDetailModel?.hairStyle ?? orderDetailInfoModel?.svcContent?.hairStyle
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceContentViewController.self)) as! ServiceContentViewController
        let model = SvcContentModel(photoImgUrl: photoImgUrl, hairStyle: hairStyle, svcCategory: svcCategory)
        vc.setupVCWithModel(model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func serviceLoactionButtonPress(_ sender: UIButton) {
        var pId = Int()
        if let id = ReservationManager.shared.reservationDetailModel?.pId {
            pId = id
        } else if let id = orderDetailInfoModel?.provider?.pId {
            pId = id
        } else {
            return
        }
        let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
        vc.setupVCWith(pId: pId, type: .onlyCheck)
        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.isNavigationBarHidden = true
        self.present(naviVC, animated: true, completion: nil)
    }
    
    @IBAction private func backButtonPress_self(_ sender: UIButton) {
        if moId != nil {
            if orderDetailInfoModel?.orderStatus == 0 {
                SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_RV_040"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_027"), leftHandler: nil, rightHandler: {
                    self.popVC()
                })
            } else {
                popVC()
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: API
    private func apiMemberOrderPayDeposit() {
        guard let model = ReservationManager.shared.reservationDetailModel, let dId = model.dId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            ReservationManager.apiMemberOrderPayDeposit(dId: dId, model: model, success: { [unowned self] (model) in
                self.handlePayment(model: model)
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiOrderPayFinalPayment() {
        guard let moId = orderDetailInfoModel?.moId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            ReservationManager.apiOrderFinalPayment(moId: moId, doId: nil, success: { (model) in
                self.handlePayment(model: model)
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetMemberOrderInfo() {
        guard let moId = moId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OrderDataManager.apiGetMemberOrderInfo(moId: moId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.orderDetailInfoModel = model?.data
                    self.resetUI()
                    self.removeMaskView()
                    self.hideLoading()
                    self.checkOrderStatus()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { [unowned self] (error) in
                self.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiPunchInAndOut(signClass: String, pId: Int?, lat: Double? = nil, lng: Double? = nil) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            // 簽到: true, 簽退: false
            // 有簽到時間代表已簽到
            let signType = (orderDetailInfoModel?.member?.punchInTime?.count ?? 0 > 0) ? false : true
            ReservationManager.apiPunchInAndOut(signClass: signClass, moId: orderDetailInfoModel?.moId, doId: nil, pId: pId, signType: signType, lat: lat, lng: lng, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let actTime = model?.data?.actTime {
                        let date = actTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
                        let time = date.transferToString(dateFormat: "HH:mm")
                        self.showPunchInAndOutSuccessAlert(signClass: signClass, time: time)
                    } else {
                        let time = Date().transferToString(dateFormat: "HH:mm")
                        self.showPunchInAndOutSuccessAlert(signClass: signClass, time: time)
                    }
                } else {
                    self.endLoadingWith(model: model, handler: {
                        if signClass == "Q" {
                            self.qrCodeScannerVC.reStartScanner()
                        }
                    })
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiMembersOrderChgStatus(orderStatus: String) {
        guard let moId = moId else { return }
        
        if SystemManager.isNetworkReachable(showBanner: false) {
            if orderStatus != "leave" { self.showLoading() }
            
            ReservationManager.apiMembersOrderChgStatus(moId: moId, orderStatus: orderStatus, success: { [unowned self] (model) in
                if orderStatus != "leave" {
                    if model?.syscode == 200 {
                        self.hideLoading()
                        SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                        self.apiGetMemberOrderInfo()
                        self.postNotification()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                }
            }, failure: { (error) in
                if orderStatus != "leave" {
                    SystemManager.showErrorAlert(error: error)
                }
            })
        }
    }
    
    private func apiGetReportedReason(showLoading: Bool = false, success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.showLoading() }
            SystemManager.apiGetReportedReason(type: "M", success: { [weak self] (model) in
                if let array = model?.data?.reportedItem {
                    if showLoading { self?.hideLoading() }
                    self?.reportedReasonArray = array
                    success?()
                }
                }, failure: { (error) in
                    if showLoading { SystemManager.showErrorAlert(error: error) }
            })
        }
    }
    
    private func apiGiveMemberOrderReported(rrId: Int, content: String?) {
        guard let moId = moId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OrderDataManager.apiGiveMemberOrderReported(moId: moId, rrId: rrId, content: content, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_RV_024"), body: "")
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { _ in
                SystemManager.showErrorAlert()
            })
        }
    }
}

extension ConsumerReservationDetailViewController: SignInOutViewDelegate {
    func gpsButtonPress() {
        self.showLoading()
        LocationManager.getLocationWithTarget(self)
    }
    
    func qrcodeButtonPress() {
        let type: ScanType = (orderDetailInfoModel?.member?.punchInTime?.count ?? 0) > 0 ? .SignOut : .SignIn
        qrCodeScannerVC.setupVCWith(type: type, delegate: self)
        self.navigationController?.pushViewController(qrCodeScannerVC, animated: true)
    }
}

extension ConsumerReservationDetailViewController: LocationManagerDelegate {
    func locationDidUpdateWithCoordinate(lat: Double, lng: Double) {
        self.hideLoading()
        self.apiPunchInAndOut(signClass: "G", pId: orderDetailInfoModel?.provider?.pId, lat: lat, lng: lng)
    }
    
    func didCancelAllowGPS() {
        self.hideLoading()
    }
}

extension ConsumerReservationDetailViewController: QRcodeScannerViewControllerDelegate {
    func didCatpureQRCode(string: String) {
        // 取得QRcode的資訊範例：http://[DomainName]/api/Reservation/PunchInAndOut?pId=3&signDate=20180801
        if let url = URLComponents(string: string), let parameters = url.queryItems, let pId = parameters.filter({ $0.name == "pId" }).first?.value {
            self.apiPunchInAndOut(signClass: "Q", pId: Int(pId))
        } else {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_SD_026"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: { [weak self] in
                self?.qrCodeScannerVC.reStartScanner()
            })
        }
    }
}

