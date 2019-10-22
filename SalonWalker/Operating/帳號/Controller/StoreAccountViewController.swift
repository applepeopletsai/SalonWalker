//
//  StoreAccountViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreAccountViewController: BaseViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var irregularView: UIView!
    @IBOutlet private weak var warningView: UIView!
    @IBOutlet private weak var designerPhotoImageView: UIImageView!
    @IBOutlet private weak var cautionCountLabel: UILabel!
    @IBOutlet private weak var missCountLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    
    private var designerInfoModel: DesignerInfoModel?
    private var providerInfoModel: ProviderInfoModel?
    private var orderCount: Int = 0
    
    private var titleArray: [String] {
        if UserManager.sharedInstance.userIdentity == .designer {
            return [LocalizedString("Lang_RD_001"),
                    LocalizedString("Lang_AC_011"),
                    LocalizedString("Lang_AC_021"),
                    LocalizedString("Lang_DD_001"),
                    LocalizedString("Lang_AC_007"),
                    LocalizedString("Lang_AC_040"),
                    LocalizedString("Lang_AC_062")]
        } else {
            return [LocalizedString("Lang_RD_001"),
                    LocalizedString("Lang_AC_011"),
                    LocalizedString("Lang_AC_007"),
                    LocalizedString("Lang_AC_006"),
                    LocalizedString("Lang_AC_040"),
                    "QR Code",
                    LocalizedString("Lang_AC_062")]
        }
    }
    
    private var iconImageStringArray: [String] {
        if UserManager.sharedInstance.userIdentity == .designer {
            return ["Rectangle 2",
                    "Rectangle 2 Copy",
                    "Rectangle 2 Copy 2",
                    "Rectangle 2 Copy 3",
                    "Rectangle 2 Copy 4",
                    "Rectangle 2 Copy 5",
                    "btn_push"]
        } else {
            return ["Rectangle 2",
                    "Rectangle 2 Copy",
                    "Rectangle 2 Copy 4",
                    "Rectangle 13",
                    "Rectangle 2 Copy 5",
                    "btn_qrcode",
                    "btn_push"]
        }
    }
    
    private let dispatchGroup = DispatchGroup()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        initializeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.designerPhotoImageView.layer.cornerRadius = self.designerPhotoImageView.bounds.width / 2
    }

    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    private func initializeUI() {
        if UserManager.sharedInstance.userIdentity == .store {
            irregularView.isHidden = true
            warningView.isHidden = true
            shareButton.isHidden = false
        }
    }
    
    private func setupUI() {
        if UserManager.sharedInstance.userIdentity == .designer {
            if let model = designerInfoModel {
                cautionCountLabel.text = String(model.cautionTotal)
                missCountLabel.text = String(model.missTotal)
                nameLabel.text = model.nickName
                if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                    designerPhotoImageView.setImage(with: imgUrl)
                }
            }
        } else {
            if let model = providerInfoModel {
                nameLabel.text = model.nickName
                if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                    designerPhotoImageView.setImage(with: imgUrl)
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    private func callAPI() {
        if UserManager.sharedInstance.userIdentity == .designer {
            dispatchGroup.enter()
            apiGetDesignerInfo()
            dispatchGroup.enter()
            apiGetOrderStatusNum()
        } else {
            dispatchGroup.enter()
            apiGetProviderInfo()
        }
        dispatchGroup.notify(queue: .main, execute: { [weak self] in
            self?.collectionView.reloadData()
        })
    }
    
    private func openQRcode(url: String) {
        let vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: QRcodeViewController.self)) as! QRcodeViewController
        vc.setupVCWith(url: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showWarningList(type: WarningListType) {
        guard let data = (type == .caution) ? designerInfoModel?.cautionDetail : designerInfoModel?.missDetail else { return }
        if data.count == 0 { return }
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WarningListViewController.self)) as! WarningListViewController
        vc.setupVCWith(data: data, type: type)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Event Handler
    @IBAction func settingButtonClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: String(describing: SettingHomePageViewController.self)) as! SettingHomePageViewController
        if UserManager.sharedInstance.userIdentity == .designer {
            vc.setupVCWith(model: designerInfoModel)
        } else {
            vc.setupVCWith(model: providerInfoModel)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func shareButtonPress(_ sender: UIButton) {
        BranchManager.createDeepLinkUrl(pId: providerInfoModel?.pId, title: providerInfoModel?.nickName, contentDescription: providerInfoModel?.characterization, success: { [weak self] (url) in
            let content = "\(self?.providerInfoModel?.nickName ?? "")\n\(self?.providerInfoModel?.characterization ?? "")\n\n\(url)"
            SystemManager.goingToShareInfoAbout(text: content)
        }, failure: { error in
            SystemManager.showErrorMessageBanner(title: error?.localizedDescription ?? LocalizedString("Lang_GE_010"), body: "")
        })
    }
    
    @IBAction private func missButtonPress(_ sender: UIButton) {
        showWarningList(type: .miss)
    }
    
    @IBAction private func cautionButtonPress(_ sender: UIButton) {
        showWarningList(type: .caution)
    }
    
    @IBAction private func fbButtonPress(_ sender: UIButton) {
        SystemManager.openSalonWalkerFB()
    }
    
    @IBAction private func igButtonPress(_ sender: UIButton) {
        SystemManager.openSalonWalkerIG()
    }
    
    // MARK: API
    private func apiGetDesignerInfo() {
        if SystemManager.isNetworkReachable() {
            if designerInfoModel == nil { self.showLoading() }
            
            OperatingManager.apiGetDesignerInfo(success: { [weak self] (model) in
                if model?.syscode == 200 {
                    if let status = model?.data?.status {
                        UserManager.sharedInstance.accountStatus = AccountStatus(rawValue: status)
                    }
                    UserManager.sharedInstance.penalty = model?.data?.penalty
                    self?.designerInfoModel = model?.data
                    self?.setupUI()
                    self?.removeMaskView()
                    self?.hideLoading()
                } else {
                    self?.endLoadingWith(model: model)
                }
                self?.dispatchGroup.leave()
            }, failure: { [weak self] (error) in
                self?.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetProviderInfo() {
        if SystemManager.isNetworkReachable() {
            if providerInfoModel == nil { self.showLoading() }
            
            OperatingManager.apiGetProviderInfo(success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.providerInfoModel = model?.data
                    self?.setupUI()
                    self?.removeMaskView()
                    self?.hideLoading()
                } else {
                    self?.endLoadingWith(model: model)
                }
                self?.dispatchGroup.leave()
            }, failure: { [weak self] (error) in
                self?.removeMaskView()
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiGetOrderStatusNum() {
        if SystemManager.isNetworkReachable() {
            OperatingManager.apiGetOrderStatusNum(success: { [weak self] (model) in
                self?.orderCount = 0
                if model?.syscode == 200 {
                    if let count = model?.data?.orderStatusNum {
                        self?.orderCount = count
                    }
                }
                self?.dispatchGroup.leave()
                }, failure: { _ in })
        }
    }
    
    private func apiQRcodeImgUrl() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            ReservationManager.apiQRcodeImgUrl(success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let url = model?.data?.qrCodeImgUrl {
                        self.openQRcode(url: url)
                    } else {
                        SystemManager.showErrorAlert()
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension StoreAccountViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: StoreAccountCell.self), for: indexPath) as! StoreAccountCell
        let pushCount = designerInfoModel?.pushTotal ?? providerInfoModel?.pushTotal ?? 0
        cell.setupCellWith(iconImageString: iconImageStringArray[indexPath.item], title: titleArray[indexPath.item], orderCount: orderCount, pushCount: pushCount, indexPath: indexPath)
        return cell
    }
    
}

extension StoreAccountViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = screenWidth / 3
        let height = (screenWidth / 375 * 325) / 3
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var vc = BaseViewController()
        if UserManager.sharedInstance.userIdentity == .designer {
            switch indexPath.item {
            case 0: // 訂單記錄
                vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: BookRecordViewController.self)) as! BookRecordViewController
                break
            case 1: // 交易設定
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: BargainSettingViewController.self)) as! BargainSettingViewController
                break
            case 2: // 我的客戶
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: MyCustomerViewController.self)) as! MyCustomerViewController
                break
            case 3: // 個人資料
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerInfoViewController.self)) as! DesignerInfoViewController
                (vc as! DesignerInfoViewController).setupVCWith(model: designerInfoModel)
                break
            case 4: // 我的窩客牆
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: MyHomeWallViewController.self)) as! MyHomeWallViewController
                break
            case 5: // 服務設定
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: AccountServiceSettingViewController.self)) as! AccountServiceSettingViewController
                break
            case 6: // 推播通知
                vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: NotificationListViewController.self)) as! NotificationListViewController
                break
            default: break
            }
            
        } else {
            switch indexPath.item {
            case 0: // 訂單記錄
                vc = UIStoryboard(name: "OrderRecord", bundle: nil).instantiateViewController(withIdentifier: String(describing: CustomerOrderListMainViewController.self)) as! CustomerOrderListMainViewController
                break
            case 1: // 交易設定
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: BargainSettingViewController.self)) as! BargainSettingViewController
                break
            case 2: // 我的窩客牆
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: MyHomeWallViewController.self)) as! MyHomeWallViewController
                break
            case 3: // 場地資料
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: ProviderInfoViewController.self)) as! ProviderInfoViewController
                (vc as! ProviderInfoViewController).setupVCWith(model: providerInfoModel)
                break
            case 4: // 服務設定
                vc = UIStoryboard(name: kStory_StoreAccount, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreServiceSettingViewController.self)) as! StoreServiceSettingViewController
                break
            case 5: // QR Code
                apiQRcodeImgUrl()
                return
            case 6: // 推播通知
                vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: NotificationListViewController.self)) as! NotificationListViewController
                break
            default: break
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
