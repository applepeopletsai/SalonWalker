//
//  OperatingReservationDetailViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/12.
//  Copyright © 2018年 skywind. All rights reserved.
//
/*
 orderStatus (訂單狀態)
 0    付款中                      新訂單
 1    已付訂金 - 已預定
 2    訂單已更新租金價格            場地業者更新租金時間 / 價格
 3    已完成 - 已付尾款 - 信用卡支付
 4    取消預約 - 已退訂金           設計師做取消動作
 5    取消預約 - 已罰緩             設計師做取消動作
 11   離開金流                     於付款輸入信用卡號，案返回上一頁 (視為訂單作廢)
 13   交易失敗(訂金)               綠界回傳交易失敗 (訂金)
 14   交易失敗(尾款)               綠界回傳交易失敗 (尾款)
 */
import UIKit

// 設計師預約流程、場地預約訂單(設計師查看場地預約訂單)、設計師預約訂單(場地業者查看設計師訂單)
class OperatingReservationDetailViewController: BaseViewController {
    
    @IBOutlet private weak var naviRightButton: IBInspectableButton!
    @IBOutlet private weak var orderSiteTitleLabel: UILabel!
    @IBOutlet private weak var storeImageView: UIImageView!
    @IBOutlet private weak var storeImageViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var badgeImageView: UIImageView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var storeAddressLabel: UILabel!
    @IBOutlet private weak var storePhoneLabel: UILabel!
    @IBOutlet private weak var storePhoneLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var orderStatusLabel: UILabel!
    @IBOutlet private weak var orderTimeViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var orderDateLabel: UILabel!
    @IBOutlet private weak var orderTimeLabel: UILabel!
    @IBOutlet private weak var depositLabel: UILabel!
    @IBOutlet private weak var depositTipLabel: UILabel!
    @IBOutlet private weak var depositViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var finalPaymentTitleLabel: UILabel!
    @IBOutlet private weak var finalPaymentLabel: UILabel!
    @IBOutlet private weak var finalPaymentTipLabel: UILabel!
    @IBOutlet private weak var svcTypeLabel: UILabel!
    @IBOutlet private weak var paymentTypeLabel: UILabel!
    @IBOutlet private weak var customerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var customerImageView: UIImageView!
    @IBOutlet private weak var customerNameLabel: UILabel!
    @IBOutlet private weak var customerOrderStatusLabel: UILabel!
    @IBOutlet private weak var serviceContentViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var serviceContentLabel: UILabel!
    @IBOutlet private weak var serviceTermLabel: UILabel!
    @IBOutlet private weak var serviceTermViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomButton: IBInspectableButton!
    @IBOutlet private weak var bottomButtonHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet private weak var commentButton: IBInspectableButton!
    @IBOutlet private weak var commentButtonWidth: NSLayoutConstraint!
    
    private var doId: Int?
    private var orderDetailInfoModel: OrderDetailInfoModel?
    private var reportedReasonArray = [ReportedReasonModel.ReportedItemModel]()
    private lazy var qrCodeScannerVC = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: QRcodeScannerViewController.self)) as! QRcodeScannerViewController
    
    private var bindMoId: Int?
    private var remoteNotifyMsg: String?
    private var alertType: String?
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.checkNeedShowRemoteNotifyMsgAlert()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.storeImageView.layer.cornerRadius = self.storeImageView.bounds.width / 2
        self.customerImageView.layer.cornerRadius = self.customerImageView.bounds.width / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Method
    func setupVCWith(doId: Int?, bindMoId: Int? = nil, orderDetailInfoModel: OrderDetailInfoModel?, remoteNotifyMsg: String? = nil, alertType: String? = nil) {
        self.doId = doId
        self.bindMoId = bindMoId
        self.remoteNotifyMsg = remoteNotifyMsg
        self.alertType = alertType
        self.orderDetailInfoModel = orderDetailInfoModel
    }
    
    func resetDataByRemoteNotification(doId: Int?, bindMoId: Int? = nil, remoteNotifyMsg: String? = nil, alertType: String? = nil) {
        self.doId = doId
        self.bindMoId = bindMoId
        self.remoteNotifyMsg = remoteNotifyMsg
        self.alertType = alertType
        self.callAPI()
        self.checkNeedShowRemoteNotifyMsgAlert()
    }
    
    private func initialize() {
        configureServiceTermView()
        setupUI()
        if SizeTool.isIphone5() { storeImageViewWidth.constant = 50 }
    }
    
    private func callAPI() {
        if doId != nil {
            apiGetDesignerOrderInfo()
        }
    }
    
    private func configureServiceTermView() {
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
    
    private func setupUI() {
        if let model = orderDetailInfoModel {
            configurePaymentAndOrderTimeView(model: model)
            configureDesignerOrProviderInfoView(model: model)
            configureMemberView(model: model)
            configureCommentView(model: model)
            configureNaviRightButton(model: model)
            configureBottomButton(model: model)
            view.layoutIfNeeded()
            removeMaskView()
        }
    }
    
    private func configurePaymentAndOrderTimeView(model: OrderDetailInfoModel) {
        /*
         orderType(訂單類別)：
         1:小時方案
         2:次數方案
         3:長租方案 (購買)
         4:長租方案 (使用)
         */
        let orderTime = model.orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
        let endTime = model.endTime?.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
        let week = orderTime.getDayOfWeek().transferToWeekString()
        orderDateLabel.text = "\(orderTime.transferToString(dateFormat: "yyyy/MM/dd")) (\(week))"
        orderTimeLabel.text = "\(orderTime.transferToString(dateFormat: "HH:mm")) - \(endTime.transferToString(dateFormat: "HH:mm"))"
        
        var svcType: String?
        switch model.orderType {
        case 1,2:
            svcType = (model.orderType == 1) ? LocalizedString("Lang_PS_002") : LocalizedString("Lang_PS_003")
            finalPaymentTitleLabel.text = LocalizedString("Lang_RD_016")
            depositLabel.text = "$\(model.deposit.transferToDecimalString())"
            depositViewHeight.constant = 65
            break
        case 3,4:
            svcType = LocalizedString("Lang_PS_004")
            finalPaymentTitleLabel.text = LocalizedString("Lang_PS_005")
            depositViewHeight.constant = 0
            if model.orderType == 3 {
                let startDay = model.svcLongLeasePrices?.startDay?.subString(from: 0, to: 9).replacingOccurrences(of: "-", with: "/") ?? ""
                let endDay = model.svcLongLeasePrices?.endDay?.subString(from: 0, to: 9).replacingOccurrences(of: "-", with: "/") ?? ""
                orderDateLabel.text = (startDay.count > 0 && endDay.count > 0) ? "\(startDay) \(LocalizedString("Lang_DD_012")) \(endDay)" : ""
                orderTimeLabel.isHidden = true
                orderTimeViewHeight.constant = 55
            } else {
                orderTimeLabel.isHidden = false
                orderTimeViewHeight.constant = 90
            }
            break
        default: break
        }
        
        svcTypeLabel.text = svcType
        depositTipLabel.text = (model.depositStatusName.count > 0) ? "(\(model.depositStatusName))" : nil
        finalPaymentTipLabel.text = (model.finalPaymentStatusName.count > 0) ? "(\(model.finalPaymentStatusName))" : nil
        finalPaymentLabel.text = "$\(model.finalPayment.transferToDecimalString())"
        paymentTypeLabel.text = model.paymentTypeName
        
        orderDateLabel.textColor = .black
        orderTimeLabel.textColor = .black
        depositLabel.textColor = .black
        finalPaymentLabel.textColor = .black
        switch model.orderStatus {
        case 0,1,2,3,11,12,13,14:
            depositTipLabel.isHidden = false
            finalPaymentTipLabel.isHidden = false
            break
        case 4,5:
            depositTipLabel.isHidden = false
            finalPaymentTipLabel.isHidden = true
            orderDateLabel.textColor = color_9B9B9B
            orderTimeLabel.textColor = color_9B9B9B
            depositLabel.textColor = color_9B9B9B
            finalPaymentLabel.textColor = color_9B9B9B
            break
        default:
            depositTipLabel.isHidden = true
            finalPaymentTipLabel.isHidden = true
            break
        }
    }
    
    private func configureDesignerOrProviderInfoView(model: OrderDetailInfoModel) {
        if UserManager.sharedInstance.userIdentity == .designer {
            // 設計師查看場地訂單
            orderSiteTitleLabel.text = LocalizedString("Lang_WE_011")
            badgeImageView.isHidden = true
            storeNameLabel.text = model.provider?.nickName
            storeAddressLabel.text = "\(model.provider?.cityName ?? "")\(model.provider?.areaName ?? "")\(model.provider?.address ?? "")"
            storePhoneLabel.text = "\(model.provider?.telArea ?? "")-\(model.provider?.tel ?? "")"
            storePhoneLabelHeight.constant = 20
            orderStatusLabel.text = model.provider?.orderStatusName
            if let url = model.provider?.headerImgUrl, url.count > 0 {
                storeImageView.setImage(with: url)
            }
        } else {
            // 場地業者查看設計師訂單
            orderSiteTitleLabel.text = LocalizedString("Lang_RT_001")
            badgeImageView.isHidden = !(model.designer?.isTop ?? false)
            storeNameLabel.text = model.designer?.nickName
            storeAddressLabel.text = "\(model.designer?.cityName ?? "") \(model.designer?.areaName ?? ""),\(model.designer?.langName ?? "")"
            storePhoneLabelHeight.constant = 0
            orderStatusLabel.text = model.designer?.orderStatusName
            if let url = model.designer?.headerImgUrl, url.count > 0 {
                storeImageView.setImage(with: url)
            }
        }
    }
    
    private func configureMemberView(model: OrderDetailInfoModel) {
        if model.member == nil {
            customerViewHeight.constant = 0
            serviceContentViewHeight.constant = 0
        } else {
            customerViewHeight.constant = 60
            serviceContentViewHeight.constant = 60
            customerNameLabel.text = model.member?.nickName
            if model.member?.orderStatus == 7 ||
                model.member?.orderStatus == 8 ||
                model.member?.orderStatus == 9 ||
                model.member?.orderStatus == 10 {
                customerOrderStatusLabel.isHidden = false
                customerOrderStatusLabel.text = model.member?.orderStatusName
            } else {
                customerOrderStatusLabel.isHidden = true
            }
            if let url = model.member?.headerImgUrl, url.count > 0 {
                customerImageView.setImage(with: url)
            } else {
                customerImageView.image = UIImage(named: "img_account_user")
            }
            
            var serviceContent = ""
            model.svcContent?.svcCategory.forEach {
                if serviceContent.count == 0 {
                    serviceContent.append($0.name)
                } else {
                    serviceContent.append("/\($0.name)")
                }
            }
            serviceContentLabel.text = serviceContent
        }
    }
    
    private func configureCommentView(model: OrderDetailInfoModel) {
        // 已完成顯示評價按鈕
        // 設計師可以給評價，也可查看評價；場地業者只能看評價
        if model.orderStatus == 3 {
            if model.evaluateStatus.evaluation == nil {
                commentButton.setImage(UIImage(named: "btn_bubble_n_32x29"), for: .normal)
                commentButton.isHidden = !(UserManager.sharedInstance.userIdentity == .designer)
                commentButtonWidth.constant = ((UserManager.sharedInstance.userIdentity == .designer)) ? 50 : 0
            } else {
                commentButton.setImage(UIImage(named: "btn_bubble_selected_32x29"), for: .normal)
                commentButton.isHidden = false
                commentButtonWidth.constant = 50
            }
            commentButton.setTitle(model.evaluateStatus.statusName, for: .normal)
        } else {
            commentButton.isHidden = true
            commentButtonWidth.constant = 0
        }
    }
    
    private func configureBottomButton(model: OrderDetailInfoModel) {
        bottomButton.isEnabled = true
        bottomButton.isHidden = false
        bottomButton.backgroundColor = color_8F92F5
        bottomButtonHeight.constant = 50
        bottomButtonBottomSpace.constant = 15
        bottomButton.removeTarget(self, action: nil, for: .allEvents)
        var buttonTitle: String?
        var buttonAction: Selector?
        
        // orderStatus狀態請參照最上方的說明
        if UserManager.sharedInstance.userIdentity == .designer {
            switch model.orderStatus {
            case 0,11,13:
                buttonTitle = LocalizedString("Lang_RD_035")
                buttonAction = #selector(confirmBooking)
                break
            case 2,14:
                buttonTitle = LocalizedString("Lang_SD_012")
                buttonAction = #selector(payFinalPayment)
                break
            case 12:
                if (model.designer?.punchInTime.count ?? 0) > 0 {
                    if (model.designer?.punchOutTime.count ?? 0) > 0 {
                        hideBottomButton()
                    } else {
                        // 簽退
                        buttonTitle = LocalizedString("Lang_SD_017")
                        buttonAction = #selector(punchInAndOut)
                    }
                } else {
                    // 簽到(通知場地)
                    buttonTitle = LocalizedString("Lang_SD_024")
                    buttonAction = #selector(punchInAndOut)
                }
                break
            default:
                hideBottomButton()
                break
            }
        } else {
            switch model.orderStatus {
            case 1,12:
                if (model.designer?.punchOutTime.count ?? 0) > 0 {
                    buttonTitle = LocalizedString("Lang_SD_020")
                    buttonAction = #selector(confirmRentTotalPrice)
                } else {
                    hideBottomButton()
                }
                break
            case 2:
                buttonTitle = "✓ \(LocalizedString("Lang_SD_021"))"
                bottomButton.isEnabled = false
                bottomButton.backgroundColor = color_B7B9F4
                break
            default:
                hideBottomButton()
                break
            }
        }
        
        bottomButton.setTitle(buttonTitle, for: .normal)
        bottomButton.setTitle(buttonTitle, for: .disabled)
        if let action = buttonAction {
            bottomButton.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    private func hideBottomButton() {
        bottomButton.isHidden = true
        bottomButtonHeight.constant = 0
        bottomButtonBottomSpace.constant = 0
    }
    
    // 確認預約
    @objc private func confirmBooking() {
        apiDesignerOrderPayDeposit()
    }
    
    // 付尾款
    @objc private func payFinalPayment() {
        apiOrderPayFinalPayment()
    }
    
    // 確認租金總價
    @objc private func confirmRentTotalPrice() {
        guard let model = orderDetailInfoModel else { return }
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: ConfirmRentPriceViewController.self)) as! ConfirmRentPriceViewController
        vc.setupVCWith(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 簽到(通知場地已抵達服務地點)、簽退
    @objc private func punchInAndOut() {
        let view = SignInOutView.getView(with: self)
        if let view = view {
            UIApplication.shared.keyWindow?.addSubview(view)
        }
    }
    
    private func configureNaviRightButton(model: OrderDetailInfoModel) {
        var buttonTitle: String?
        var buttonAction: Selector?
        naviRightButton.isHidden = false
        naviRightButton.removeTarget(self, action: nil, for: .allEvents)
        
        // orderStatus狀態請參照最上方的說明
        if UserManager.sharedInstance.userIdentity == .designer {
            switch model.orderStatus {
            case 0:
                if model.doId != nil {
                    buttonTitle = LocalizedString("Lang_RD_023")
                    buttonAction = #selector(cancelBook)
                } else {
                    naviRightButton.isHidden = true
                }
                break
            case 1,11,13:
                buttonTitle = LocalizedString("Lang_RD_023")
                buttonAction = #selector(cancelBook)
                break
            case 2,3,14:
                buttonTitle = LocalizedString("Lang_RD_036")
                buttonAction = #selector(report)
                break
            case 12:
                if (model.designer?.punchInTime.count ?? 0) > 0 {
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
        } else {
            switch model.orderStatus {
            case 2,3,14:
                buttonTitle = LocalizedString("Lang_RD_036")
                buttonAction = #selector(report)
                break
            default:
                naviRightButton.isHidden = true
                break
            }
        }
        
        naviRightButton.setTitle(buttonTitle, for: .normal)
        
        if let action = buttonAction {
            naviRightButton.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    // 取消預約
    @objc private func cancelBook() {
        guard let orderStatus = orderDetailInfoModel?.orderStatus, let orderTime = orderDetailInfoModel?.orderTime else { return }
        switch orderStatus {
        case 0,11,13:
            self.navigationController?.popToRootViewController(animated: true)
            break
        case 1,12:
            var image = UIImage(named: "img_cancelbooking_n")
            var message = LocalizedString("Lang_RV_019")
            // 24小時前: 氣球警告；24小時內: 放鳥
            let orderDay = orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
            if orderDay.timeIntervalSince(Date()) > 24 * 60 * 60 {
                message += "\n\(LocalizedString("Lang_RV_020"))\n\n\(LocalizedString("Lang_RV_022"))"
            } else {
                message += "\n\(LocalizedString("Lang_RV_021"))\n\n\(LocalizedString("Lang_RV_023"))"
                image = UIImage(named: "img_cancelbooking_money")
            }
            PresentationTool.showTwoButtonAlertWith(image: image, message: message, leftButtonTitle: LocalizedString("Lang_RV_032"), leftButtonAction: { [unowned self] in
                self.apiDesignerOrderChgStatus(orderStatus: "cancel")
                }, rightButtonTitle: LocalizedString("Lang_RV_033"), rightButtonAction: nil)
            break
        default: break
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
            self.apiGiveDesignerOrderReported(rrId: self.reportedReasonArray[index].rrId, content: text)
        }
    }
    
    private func handlePayment(model: BaseModel<OrderPayModel>?) {
        if model?.syscode == 200 {
            self.hideLoading()
            if let doId = model?.data?.doId {
                self.doId = doId
                if let url = model?.data?.transferUrl, url.count > 0 {
                    self.gotoECPay(url: url)
                } else {
                    self.callAPI()
                }
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
    
    private func checkOrderStatus() {
        guard let orderStatus = orderDetailInfoModel?.orderStatus else { return }
        // 若狀態為0，代表設計師在點擊確認預約後至綠界支付頁面，但尚未完成付款動作回來此頁面，此時需打api告知後台設計師離開金流
        if orderStatus == 0 {
            apiDesignerOrderChgStatus(orderStatus: "leave")
        }
    }
    
    private func showCancelCustomerAlert() {
        // bindMoId為0代表純預約場地(沒有消費者)
        if orderDetailInfoModel?.bindMoId == 0 {
            self.apiGetDesignerOrderInfo()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_cancelbooking_n"), message: "\(LocalizedString("Lang_RV_029"))\n\(LocalizedString("Lang_RV_030"))", leftButtonTitle: LocalizedString("Lang_GE_057"), leftButtonAction: {
                self.apiGetDesignerOrderInfo()
            }, rightButtonTitle: LocalizedString("Lang_RV_031"), rightButtonAction: {
                let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerReservationByConsumerDetailViewController.self)) as! DesignerReservationByConsumerDetailViewController
                vc.setupVCWith(moId: self.orderDetailInfoModel?.bindMoId)
                self.navigationController?.pushViewController(vc, animated: true)
            })
        })
    }
    
    private func showPunchInAndOutSuccessAlert(signClass: String, time: String, signType: Bool) {
        let image = UIImage(named: (signClass == "Q") ? "img_pop_qrcode_58x58" : "img_pop_gps_51x54")
        var message = (signClass == "Q") ? "\(LocalizedString("Lang_SD_008"))\n\n" : "\(LocalizedString("Lang_SD_007"))\n"
        if signType {
            message += "\(LocalizedString("Lang_SD_025"))\n\(LocalizedString("Lang_SD_011"))："
        } else {
            message += "\(LocalizedString("Lang_SD_019"))："
        }
        message += time
        PresentationTool.showOneButtonAlertWith(image: image, message: message, buttonTitle: LocalizedString("Lang_GE_056"), buttonAction: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                if signClass == "Q" {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.apiGetDesignerOrderInfo()
                }
            })
        })
    }
    
    private func checkNeedShowRemoteNotifyMsgAlert() {
        if let remoteNotifyMsg = remoteNotifyMsg, let alertType = alertType {
            if alertType == "201" {
                PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_pop_receive"), message: remoteNotifyMsg, leftButtonTitle: LocalizedString("Lang_GE_057"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_RV_031"), rightButtonAction: {
                    
                    let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerReservationByConsumerDetailViewController.self)) as! DesignerReservationByConsumerDetailViewController
                    vc.setupVCWith(moId: self.bindMoId)
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
                self.remoteNotifyMsg = nil
                self.alertType = nil
            }
        }
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
    }
    
    // MARK: Event Handler
    // 計價方式
    @IBAction private func countPriceButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: PricingPlanDetailViewController.self)) as! PricingPlanDetailViewController
        vc.setupVCWith(svcHours: orderDetailInfoModel?.svcHoursPrices, svcTimes: orderDetailInfoModel?.svcTimesPrices, svcLongLease: orderDetailInfoModel?.svcLongLeasePrices)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 服務內容
    @IBAction private func serviceContentButtonClick(_ sender: UIButton) {
        guard var svcCategory = orderDetailInfoModel?.svcContent?.svcCategory else { return }
        for i in 0..<svcCategory.count {
            svcCategory[i].selectSvcClass = svcCategory[i].svcClass
        }
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ServiceContentViewController.self)) as! ServiceContentViewController
        let model = SvcContentModel(photoImgUrl: orderDetailInfoModel?.svcContent?.photoImgUrl, hairStyle: orderDetailInfoModel?.svcContent?.hairStyle, svcCategory: svcCategory)
        vc.setupVCWithModel(model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 評價
    @IBAction private func commentButtonClick(_ sender: UIButton) {
        if orderDetailInfoModel?.evaluateStatus.evaluation == nil {
            guard let pId = orderDetailInfoModel?.provider?.pId, let doId = orderDetailInfoModel?.doId else { return }
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WriteCommentViewController.self)) as! WriteCommentViewController
            vc.setupVCWith(pId: pId, doId: doId)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowCommentViewController.self)) as! ShowCommentViewController
            vc.setupVCWith(model: orderDetailInfoModel!.evaluateStatus.evaluation!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func backButtonPress_self(_ sender: UIButton) {
        if orderDetailInfoModel?.orderStatus == 1 {
            for vc in self.navigationController?.viewControllers ?? [] {
                if vc is StoreDetailViewController ||
                    vc is CustomerOrderListMainViewController ||
                    vc is DesignerReservationByConsumerDetailViewController {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: API
    private func apiGetReportedReason(showLoading: Bool = false, success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.showLoading() }
            SystemManager.apiGetReportedReason(type: "D", success: { [weak self] (model) in
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
    
    private func apiGetDesignerOrderInfo() {
        guard let doId = doId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OrderDataManager.apiGetDesignerOrderInfo(doId: doId, success: { (model) in
                if model?.syscode == 200 {
                    self.orderDetailInfoModel = model?.data
                    self.setupUI()
                    self.hideLoading()
                    self.checkOrderStatus()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiDesignerOrderPayDeposit() {
        guard let pId = orderDetailInfoModel?.provider?.pId, let orderType = orderDetailInfoModel?.orderType else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            var orderDate: String?
            var startTime: String?
            var endTime: String?
            var deposit: Int?
            var finalPayment: Int?
            var rent: Int?
            
            switch orderType {
            case 1,2,4:
                orderDate = orderDetailInfoModel?.orderTime.subString(from: 0, to: 9).replacingOccurrences(of: "-", with: "/")
                startTime = orderDetailInfoModel?.orderTime.subString(from: 11, to: 15)
                endTime = orderDetailInfoModel?.endTime?.subString(from: 11, to: 15)
                if orderType != 4 {
                    deposit = orderDetailInfoModel?.deposit
                    finalPayment = orderDetailInfoModel?.finalPayment
                } else {
                    rent = orderDetailInfoModel?.finalPayment
                }
                break
            case 3:
                rent = orderDetailInfoModel?.finalPayment
                break
            default: break
            }
            
            ReservationManager.apiDesignerOrderPayDeposit(moId: orderDetailInfoModel?.moId, pId: pId, orderType: orderType, orderDate: orderDate, startTime: startTime, endTime: endTime, deposit: deposit, finalPayment: finalPayment, rent: rent, model: orderDetailInfoModel, success: { [unowned self] (model) in
                self.handlePayment(model: model)
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiOrderPayFinalPayment() {
        guard let doId = orderDetailInfoModel?.doId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            ReservationManager.apiOrderFinalPayment(moId: nil, doId: doId, success: { (model) in
                self.handlePayment(model: model)
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiDesignerOrderChgStatus(orderStatus: String) {
        guard let doId = doId else { return }
        
        if SystemManager.isNetworkReachable(showBanner: false) {
            if orderStatus != "leave" { self.showLoading() }
            
            ReservationManager.apiDesignerOrderChgStatus(doId: doId, orderStatus: orderStatus, success: { [unowned self] (model) in
                if orderStatus != "leave" {
                    if model?.syscode == 200 {
                        self.hideLoading()
                        SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                        self.postNotification()
                        self.showCancelCustomerAlert()
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
    
    private func apiGiveDesignerOrderReported(rrId: Int, content: String?) {
        guard let doId = doId else { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            OrderDataManager.aoiGiveDesignerOrderReported(doId: doId, rrId: rrId, content: content, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_RV_024"), body: "")
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiPunchInAndOut(signClass: String, pId: Int?, lat: Double? = nil, lng: Double? = nil) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            // 簽到: true, 簽退: false
            // 有簽到時間代表已簽到
            let signType = (orderDetailInfoModel?.designer?.punchInTime.count ?? 0 > 0) ? false : true
            ReservationManager.apiPunchInAndOut(signClass: signClass, moId: nil, doId: orderDetailInfoModel?.doId, pId: pId, signType: signType, lat: lat, lng: lng, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let time = model?.data?.actTime?.subString(from: 11, to: 15) {
                        self.showPunchInAndOutSuccessAlert(signClass: signClass, time: time, signType: signType)
                    } else {
                        let time = Date().transferToString(dateFormat: "HH:mm")
                        self.showPunchInAndOutSuccessAlert(signClass: signClass, time: time, signType: signType)
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
}

extension OperatingReservationDetailViewController: SignInOutViewDelegate {
    
    func gpsButtonPress() {
        self.showLoading()
        LocationManager.getLocationWithTarget(self)
    }
    
    func qrcodeButtonPress() {
        let type: ScanType = (orderDetailInfoModel?.designer?.punchInTime.count ?? 0) > 0 ? .SignOut : .SignIn
        qrCodeScannerVC.setupVCWith(type: type, delegate: self)
        self.navigationController?.pushViewController(qrCodeScannerVC, animated: true)
    }
}

extension OperatingReservationDetailViewController: LocationManagerDelegate {
    func locationDidUpdateWithCoordinate(lat: Double, lng: Double) {
        self.hideLoading()
        self.apiPunchInAndOut(signClass: "G", pId: orderDetailInfoModel?.provider?.pId, lat: lat, lng: lng)
    }
    
    func didCancelAllowGPS() {
        self.hideLoading()
    }
}

extension OperatingReservationDetailViewController: QRcodeScannerViewControllerDelegate {
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
