//
//  DesignerReservationByConsumerDetailViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/4/10.
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

// 設計師：客戶預約訂單(設計師查看消費者預約記錄)
class DesignerReservationByConsumerDetailViewController: BaseViewController {

    @IBOutlet private weak var scrollview: UIScrollView!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var langNameLabel: UILabel!
    @IBOutlet private weak var headerImageViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var orderDateLabel: UILabel!
    @IBOutlet private weak var orderTimeLabel: UILabel!
    @IBOutlet private weak var depositLabel: UILabel!
    @IBOutlet private weak var depositTipLabel: UILabel!
    @IBOutlet private weak var finalPaymentLabel: UILabel!
    @IBOutlet private weak var finalPaymentTipLabel: UILabel!
    @IBOutlet private weak var paymentTypeLabel: UILabel!
    @IBOutlet private weak var commentButton: IBInspectableButton!
    @IBOutlet private weak var commentButtonWidth: NSLayoutConstraint!
    @IBOutlet private weak var serviceContentLabel: UILabel!
    @IBOutlet private weak var serviceLocationLabel: UILabel!
    @IBOutlet private weak var serviceTermLabel: UILabel!
    @IBOutlet private weak var serviceTermViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var naviRightButton: IBInspectableButton!
    @IBOutlet private weak var bottomButton: IBInspectableButton!
    @IBOutlet private weak var bottomButtonHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomButtonBottomSpace: NSLayoutConstraint!
    
    private var moId: Int?
    private var orderDetailInfoModel: OrderDetailInfoModel?
    private var reportedReasonArray = [ReportedReasonModel.ReportedItemModel]()
    private lazy var qrCodeScannerVC = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: QRcodeScannerViewController.self)) as! QRcodeScannerViewController
    
    // 當消費者取消訂單且該訂單為已回覆(已預定場地)時，設計師點擊推播後要跳提醒視窗，可以直接到場地訂單
    private var bindDoId: Int?
    private var remoteNotifyMsg: String?
    private var alertType: String?
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.checkNeedShowRemoteNotifyMsgAlert()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerImageView.layer.cornerRadius = self.headerImageView.bounds.width / 2
    }
    
    // MARK: Method
    func setupVCWith(moId: Int?, bindDoId: Int? = nil, remoteNotifyMsg: String? = nil, alertType: String? = nil) {
        self.moId = moId
        self.bindDoId = bindDoId
        self.remoteNotifyMsg = remoteNotifyMsg
        self.alertType = alertType
    }
    
    func resetDataByRemoteNotification(moId: Int?, bindDoId: Int? = nil, remoteNotifyMsg: String? = nil, alertType: String? = nil) {
        self.moId = moId
        self.bindDoId = bindDoId
        self.remoteNotifyMsg = remoteNotifyMsg
        self.alertType = alertType
        self.callAPI()
        self.checkNeedShowRemoteNotifyMsgAlert()
    }
    
    private func callAPI() {
        if moId != nil {
            apiGetMemberOrderInfo()
        }
    }
    
    private func initialize() {
        if SizeTool.isIphone5() { headerImageViewWidth.constant = 50 }
        configureServiceTermView()
    }
    
    private func setupUI() {
        if let model = orderDetailInfoModel {
            configureMemberInfoView(model: model)
            configurePaymentAndOrderTimeView(model: model)
            configureServiceContentView(model: model)
            configureCommentView(model: model)
            configureNaviRightButton(model: model)
            configureBottomButton(model: model)
            view.layoutIfNeeded()
            removeMaskView()
        }
    }
    
    private func configureMemberInfoView(model: OrderDetailInfoModel) {
        nameLabel.text = model.member?.nickName
        langNameLabel.text = model.member?.langName
        statusLabel.text = model.member?.orderStatusName
        if let url = model.member?.headerImgUrl {
            headerImageView.setImage(with: url)
        }
    }
    
    private func configurePaymentAndOrderTimeView(model: OrderDetailInfoModel) {
        let date = model.orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss")
        let day = date.transferToString(dateFormat: "yyyy/MM/dd")
        let week = date.getDayOfWeek().transferToWeekString()
        orderDateLabel.text = "\(day) (\(week))"
        orderTimeLabel.text = date.transferToString(dateFormat: "HH:mm")
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
    
    private func configureServiceContentView(model: OrderDetailInfoModel) {
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
    
    private func configureCommentView(model: OrderDetailInfoModel) {
        // 已完成才有評價按鈕
        // 設計師只能查看評價
        if model.orderStatus == 4 ||
            model.orderStatus == 5 ||
            model.orderStatus == 6 {
            commentButton.isHidden = !(model.evaluateStatus.evaluation != nil)
            commentButtonWidth.constant = (model.evaluateStatus.evaluation != nil) ? 50 : 0
            commentButton.setTitle(model.evaluateStatus.statusName, for: .normal)
        } else {
            commentButton.isHidden = true
            commentButtonWidth.constant = 0
        }
    }
    
    private func configureNaviRightButton(model: OrderDetailInfoModel) {
        var buttonTitle: String?
        var buttonAction: Selector?
        naviRightButton.isHidden = false
        naviRightButton.removeTarget(self, action: nil, for: .allEvents)
        
        switch model.orderStatus {
        case 0,1:
            buttonTitle = LocalizedString("Lang_RD_023")
            buttonAction = #selector(cancelBook)
            break
        case 2,11,13:
            buttonTitle = LocalizedString("Lang_RD_023")
            buttonAction = #selector(cancelBook_Punishment)
            break
        case 3,4,5,6,14:
            buttonTitle = LocalizedString("Lang_RD_036")
            buttonAction = #selector(report)
            break
        case 12:
            if (model.designer?.punchInTime.count ?? 0) > 0 {
                buttonTitle = LocalizedString("Lang_RD_036")
                buttonAction = #selector(report)
            } else {
                buttonTitle = LocalizedString("Lang_RD_023")
                buttonAction = #selector(cancelBook_Punishment)
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
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_RV_019"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_RV_033"), rightButtonTitle: LocalizedString("Lang_RV_032"), leftHandler: nil, rightHandler: {
            self.apiMembersOrderChgStatus()
        })
    }
    
    @objc private func cancelBook_Punishment() {
        guard let orderDay = orderDetailInfoModel?.orderTime.transferToDate(dateFormat: "yyyy-MM-dd HH:mm:ss") else { return }
        // 24小時前: 氣球警告；24小時內: 放鳥
        var image = UIImage(named: "img_cancelbooking_n")
        var message = LocalizedString("Lang_RV_019")
        if orderDay.timeIntervalSince(Date()) > 24 * 60 * 60 {
            message += "\n\(LocalizedString("Lang_RV_022"))"
        } else {
            message += "\n\(LocalizedString("Lang_RV_023"))"
            image = UIImage(named: "img_cancelbooking_money")
        }
        PresentationTool.showTwoButtonAlertWith(image: image, message: message, leftButtonTitle: LocalizedString("Lang_RV_032"), leftButtonAction: { [unowned self] in
            self.apiMembersOrderChgStatus()
            }, rightButtonTitle: LocalizedString("Lang_RV_033"), rightButtonAction: nil)
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
        PresentationTool.showReportAlert_HaveChooseReason(itemArray: array, leftButtonAction: nil) { (text, index) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                self.apiGiveMemberOrderReported(rrId: self.reportedReasonArray[index].rrId, content: text)
            })
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
        switch model.orderStatus {
        case 1:
            buttonTitle = LocalizedString("Lang_WE_011")
            buttonAction = #selector(reserveSite)
            break
        case 3,14:
            buttonTitle = "✓ \(LocalizedString("Lang_SD_014"))"
            bottomButton.isEnabled = false
            bottomButton.backgroundColor = color_B7B9F4
            break
        case 4,5,6:
            if (model.designer?.punchOutTime.count ?? 0) > 0 {
                hideBottomButton()
            } else {
                buttonTitle = LocalizedString("Lang_SD_017")
                buttonAction = #selector(signOut)
            }
            break
        case 12:
            if (model.designer?.punchInTime.count ?? 0) > 0 {
                buttonTitle = LocalizedString("Lang_SD_015")
                buttonAction = #selector(confirmServiceContent)
            } else {
                buttonTitle = LocalizedString("Lang_SD_016")
                buttonAction = #selector(informConsumer)
            }
            break
        default:
            hideBottomButton()
            break
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
    
    // 預約場地
    @objc private func reserveSite() {
        guard let moId = moId else { return }
        let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: HasOrderPricingPlanViewController.self)) as! HasOrderPricingPlanViewController
        vc.setupVCWith(moId: moId, orderDetailInfoModel: orderDetailInfoModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 簽退
    @objc private func signOut() {
        let view = SignInOutView.getView(with: self)
        if let view = view {
            UIApplication.shared.keyWindow?.addSubview(view)
        }
    }
    
    // 確認服務項目
    @objc private func confirmServiceContent() {
        guard let mId = orderDetailInfoModel?.member?.mId, let dId = orderDetailInfoModel?.designer?.dId, let moId = orderDetailInfoModel?.moId else { return }
        let vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: ConfirmServiceContentViewController.self)) as! ConfirmServiceContentViewController
        vc.setupVCWith(mId: mId, dId: dId, moId: moId, customerName: orderDetailInfoModel?.member?.nickName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 通知消費者已抵達服務地點(簽到)
    @objc private func informConsumer() {
        let view = SignInOutView.getView(with: self)
        if let view = view {
            UIApplication.shared.keyWindow?.addSubview(view)
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
    
    private func showPunchInAndOutSuccessAlert(signClass: String, time: String, signType: Bool) {
        let image = UIImage(named: (signClass == "Q") ? "img_pop_qrcode_58x58" : "img_pop_gps_51x54")
        var message = (signClass == "Q") ? "\(LocalizedString("Lang_SD_008"))\n\n" : "\(LocalizedString("Lang_SD_007"))\n"
        if signType {
            message += "\(LocalizedString("Lang_SD_018"))\n\(LocalizedString("Lang_SD_011"))："
        } else {
            message += "\(LocalizedString("Lang_SD_019"))："
        }
        message += time
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
    
    private func showCancelSiteOrderAlert() {
        // orderStatus為1代表消費者預定設計師，但設計師尚未回覆(尚未預定場地)
        if self.orderDetailInfoModel?.orderStatus == 0 ||
            self.orderDetailInfoModel?.orderStatus == 1 {
            self.apiGetMemberOrderInfo()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_cancelbooking_n"), message: "\(LocalizedString("Lang_RV_025"))\n\(LocalizedString("Lang_RV_026"))", leftButtonTitle: LocalizedString("Lang_GE_057"), leftButtonAction: { [unowned self] in
                self.apiGetMemberOrderInfo()
            }, rightButtonTitle: LocalizedString("Lang_RV_027"), rightButtonAction: { [unowned self] in
                let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController

                vc.setupVCWith(doId: self.orderDetailInfoModel?.bindDoId, orderDetailInfoModel: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            })
        })
    }
    
    private func checkNeedShowRemoteNotifyMsgAlert() {
        if let remoteNotifyMsg = remoteNotifyMsg, let alertType = alertType {
            if alertType == "200" {
                PresentationTool.showTwoButtonAlertWith(image: UIImage(named: "img_cancelbooking_n"), message: remoteNotifyMsg, leftButtonTitle: LocalizedString("Lang_GE_057"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_RV_027"), rightButtonAction: { [unowned self] in
                    let vc = UIStoryboard(name: kStory_ReserveStore, bundle: nil).instantiateViewController(withIdentifier: String(describing: OperatingReservationDetailViewController.self)) as! OperatingReservationDetailViewController
                    
                    vc.setupVCWith(doId: self.bindDoId, orderDetailInfoModel: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.bindDoId = nil
                })
            } else {
                PresentationTool.showOneButtonAlertWith(image: UIImage(named: "img_pop_receive"), message: remoteNotifyMsg, buttonTitle: LocalizedString("Lang_GE_027"), buttonAction: nil)
            }
            self.remoteNotifyMsg = nil
            self.alertType = nil
        }
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kShouldReloadOrderRecord), object: nil)
    }
    
    // MARK: Event Handler
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
    
    @IBAction private func serviceLocationButtonClick(_ sender: UIButton) {
        guard let pId = orderDetailInfoModel?.provider?.pId else { return }
        let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
        vc.setupVCWith(pId: pId, type: .onlyCheck)
        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.isNavigationBarHidden = true
        present(naviVC, animated: true, completion: nil)
    }
    
    @IBAction private func commentButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowCommentViewController.self)) as! ShowCommentViewController
        vc.setupVCWith(model: orderDetailInfoModel!.evaluateStatus.evaluation!)
        self.navigationController?.pushViewController(vc, animated: true)
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
                    self.setupUI()
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiMembersOrderChgStatus() {
        guard let moId = moId else { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            ReservationManager.apiMembersOrderChgStatus(moId: moId, orderStatus: "cancel", success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: model?.data?.msg ?? LocalizedString("Lang_GE_021"), body: "")
                    self.postNotification()
                    self.showCancelSiteOrderAlert()
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
            ReservationManager.apiPunchInAndOut(signClass: signClass, moId: orderDetailInfoModel?.moId, doId: nil, pId: pId, signType: signType, lat: lat, lng: lng, success: { [unowned self] (model) in
                
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

extension DesignerReservationByConsumerDetailViewController: SignInOutViewDelegate {
    
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

extension DesignerReservationByConsumerDetailViewController: LocationManagerDelegate {
    func locationDidUpdateWithCoordinate(lat: Double, lng: Double) {
        self.hideLoading()
        self.apiPunchInAndOut(signClass: "G", pId: orderDetailInfoModel?.provider?.pId, lat: lat, lng: lng)
    }
    
    func didCancelAllowGPS() {
        self.hideLoading()
    }
}

extension DesignerReservationByConsumerDetailViewController: QRcodeScannerViewControllerDelegate {
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

