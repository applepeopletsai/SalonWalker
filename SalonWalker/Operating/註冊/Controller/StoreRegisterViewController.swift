//
//  RegisterViewController_Store.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/6.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StoreRegisterViewController: BaseViewController {
    
    @IBOutlet private weak var introductionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var trafficViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var deviceTableView: DeviceTableView!
    @IBOutlet private weak var deviceViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var headshotImageView: UIImageView!
    @IBOutlet private weak var storeNameTextField: UITextField!
    @IBOutlet private weak var telAreaTextField: UITextField!
    @IBOutlet private weak var telTextField: UITextField!
    @IBOutlet private weak var unifiedBusinessNoTextField: UITextField!
    @IBOutlet private weak var introductionTextView: UITextView!
    @IBOutlet private weak var trafficTextView: UITextView!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var footageTextField: UITextField!
    @IBOutlet private weak var cityLabel: IBInspectableLabel!
    @IBOutlet private weak var areaLabel: IBInspectableLabel!
    
    private var deviceArray = [EquipmentItemModel.Equipment]()
    
    private var headshot: MultipleAsset?
    private var headshotId: Int?
    private var selectCityRow: Int = -1
    private var selectAreaRow: Int = -1
    private var zcId: Int = -1
    
    private lazy var constraintArray: Array<NSLayoutConstraint> = {
        return [introductionViewHeight,trafficViewHeight]
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureRecognizerShouldBegin = false
        initialize()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        setHeaderImage()
    }
    
    private func initialize() {
        storeNameTextField.text = UserManager.sharedInstance.nickName
        deviceTableView.setupTableViewWith(targetViewController: self, delegate: self)
        setHeaderImage()
    }
    
    private func setHeaderImage() {
        if self.headshotId == nil, SystemManager.isNetworkReachable(showBanner: false) {
            if let fbImageUrl = FBManager.getPictureUrl(), UserManager.sharedInstance.loginType == .fb {
                apiTempImage(type: "url", fbImgUrl: fbImageUrl)
            }
            if let googleImageUrl = GoogleManager.getPictureUrl(), UserManager.sharedInstance.loginType == .google {
                apiTempImage(type: "url", googleImgUrl: googleImageUrl)
            }
        }
    }
    
    private func calculateTextViewHeight(_ textView: UITextView) {
        let textViewWidth = (textView.tag < 2) ? screenWidth - 25.0 - 20.0 - 10.0 * 2 : screenWidth - 25.0 - 20.0 - 24.0 - 20.0 - 10.0 * 2
        let size = textView.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.greatestFiniteMagnitude))
        let increaseHeight = size.height - textView.frame.size.height
        constraintArray[textView.tag].constant += increaseHeight
        
        let maxHeight: CGFloat = (textView.tag == 0) ? 150.0 : 180.0
        let minHeight: CGFloat = (textView.tag == 0) ? 70.0 : 100.0
        
        if constraintArray[textView.tag].constant > maxHeight {
            constraintArray[textView.tag].constant = maxHeight
        }
        if constraintArray[textView.tag].constant < minHeight {
            constraintArray[textView.tag].constant = minHeight
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func calculateTableViewHeight() {
        if deviceArray.count > 0 {
            var normalCellCount: CGFloat = 0
            var textFieldCount: CGFloat = 0
            for model in deviceArray {
                if model.permitCharacterization {
                    textFieldCount += 1
                } else {
                    normalCellCount += 1
                }
            }
            deviceViewHeight.constant = 17.0 + 10.0 + deviceNormalCellHeight * normalCellCount + deviceTextFieldCellHeight * textFieldCount
        } else {
            deviceViewHeight.constant = 0
        }
    }
    
    private func showCityPickerView() {
        let index = (selectCityRow == -1) ? 0 : selectCityRow
        PresentationTool.showPickerWith(itemArray: SystemManager.getCityNameArray(), selectedIndex: index, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
            if self.selectCityRow != index {
                self.cityLabel.text = item
                self.cityLabel.textColor = .black
                self.areaLabel.text = LocalizedString("Lang_HM_022")
                self.areaLabel.textColor = color_C7C7CD
                self.selectCityRow = index
                self.selectAreaRow = -1
                self.zcId = -1
            }
        })
    }
    
    private func checkField() -> String? {
        if storeNameTextField.text?.count == 0 {
            return LocalizedString("Lang_LI_020") + LocalizedString("Lang_RT_019")
        }
        
        if telAreaTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_029") + LocalizedString("Lang_RT_019")
        }
        
        if telTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_030") + LocalizedString("Lang_RT_019")
        }
        
        if unifiedBusinessNoTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_031") + LocalizedString("Lang_RT_019")
        }
        
        if introductionTextView.text?.count == 0 {
            return LocalizedString("Lang_RT_020") + LocalizedString("Lang_RT_019")
        }
        
        if selectCityRow == -1 {
            return LocalizedString("Lang_GE_007") +  LocalizedString("Lang_HM_021")
        }
        
        if selectAreaRow == -1 {
            return LocalizedString("Lang_GE_007") +  LocalizedString("Lang_HM_022")
        }
        
        if addressTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_050") + LocalizedString("Lang_RT_019")
        }
        
        if footageTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_040") + LocalizedString("Lang_RT_019")
        }
        
        if trafficTextView.text?.count == 0 {
            return LocalizedString("Lang_RT_035") + LocalizedString("Lang_RT_019")
        }
        
        for model in deviceArray {
            if model.selected {
                if model.permitCharacterization {
                    if model.content.count == 0 {
                        return model.name + LocalizedString("Lang_RT_018")
                    }
                } else {
                    if model.count == 0 {
                        return model.name + LocalizedString("Lang_RT_027")
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: Event Handler
    @IBAction private func headshotButtonPress(_ sender: UIButton) {
        var array: [MultipleAsset] = []
        if let headshot = headshot {
            array.append(headshot)
        }
        PresentationTool.showImagePickerWith(selectAssets: array, maxSelectCount: 1, showVideo: false, target: self)
    }
    
    @IBAction private func cityButtonPress(_ sender: UIButton) {
        if SystemManager.getCityCodeModel() != nil {
            self.showCityPickerView()
        } else {
            self.apiGetCityCode { [unowned self] in
                self.showCityPickerView()
            }
        }
    }
    
    @IBAction private func areaButtonPress(_ sender: UIButton) {
        if selectCityRow == -1 {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_HM_026"), body: "")
            return
        }
        let index = (selectAreaRow == -1) ? 0 : selectAreaRow
        if let city = self.cityLabel.text {
            PresentationTool.showPickerWith(itemArray: SystemManager.getAreaNameArray(cityName: city), selectedIndex: index, cancelAction: nil, confirmAction: { [unowned self] (item, index) in
                self.areaLabel.text = item
                self.areaLabel.textColor = .black
                self.selectAreaRow = index
                if let cityName = self.cityLabel.text, let areaName = self.areaLabel.text, let id = SystemManager.getZcId(cityName: cityName, areaName: areaName) {
                    self.zcId = id
                }
            })
        }
    }
    
    @IBAction private func uploadCoverPhotoButtonPress(_ sender: UIButton) {

        if let errorBody = checkField() {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_008"), body: errorBody)
            return
        }
        
        let areaSize = Int(footageTextField.text!) ?? 0
        var headerImg: HeaderImg?
        if let headshotId = headshotId {
            headerImg = HeaderImg(imgUrl: nil, headerImgId: nil, tempImgId: headshotId, act: "add")
        }
        var equipment: [EquipmentModel] = []
        for model in deviceArray {
            if model.selected {
               equipment.append(EquipmentModel(name: model.name, num: model.count, characterization: model.content))
            }
        }
        let model = ProviderInfoModel(ouId: UserManager.sharedInstance.ouId!, pId: 0, email: "", nickName: storeNameTextField.text!, telArea: telAreaTextField.text!, tel: telTextField.text!,internationalPrefix: "", phone: "", uniformNumber: unifiedBusinessNoTextField.text!, zcId: zcId, cityName: cityLabel.text, areaName: areaLabel.text, address: addressTextField.text!, areaSize: areaSize, characterization: introductionTextView.text!, contactInformation: trafficTextView.text!, equipment: equipment, coverImg: [], headerImg: headerImg, slId: 0, cautionTotal: 0, missTotal: 0, cautionDetail: nil, missDetail: nil, reminder: true, notice: true, status: 0, penalty: nil, pushTotal: 0)
        
        let vc = UIStoryboard.init(name: "Register", bundle: nil).instantiateViewController(withIdentifier: String(describing: UploadPhotoViewController.self)) as! UploadPhotoViewController
        vc.setupVCWithModel(model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API
    private func apiGetCityCode(_ success: actionClosure? = nil) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            SystemManager.apiGetCityCode(success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let cityCodeModel = model?.data {
                        SystemManager.saveCityCodeModel(cityCodeModel)
                        success?()
                    }
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
                }, failure: { (error) in
                    SystemManager.showErrorAlert(error: error)
            })
        }
    }
    
    private func apiTempImage(type: String, imageString: String? = nil, fbImgUrl: String? = nil, googleImgUrl: String? = nil) {
        self.showLoading()
        
        SystemManager.apiTempImage(imageType: type, image: imageString, fbImgUrl: fbImgUrl, googleImgUrl: googleImgUrl, tempImgId: nil, mId: nil, ouId: nil, licenseImgId: nil, coverImgId: nil, act: "new", success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                self.headshotId = model?.data?.tempImgId
                if let imgUrl = model?.data?.imgUrl {
                    self.headshotImageView.setImage(with: imgUrl)
                }
                self.hideLoading()
            } else {
                self.endLoadingWith(model: model)
            }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
        })
    }
}

extension StoreRegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField == footageTextField, let text = textField.text {
            if let count = Int(text), count < 10 {
                SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_RT_039"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if let totalString = totalString {
            if textField == storeNameTextField || textField == unifiedBusinessNoTextField {
                let maxTextCount = (textField == storeNameTextField) ? 10 : 8
                if totalString.count > maxTextCount {
                    return false
                }
            }
        }
        return true
    }
}

extension StoreRegisterViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        calculateTextViewHeight(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        if let totalString = totalString, totalString.count > 50 {
            return false
        }
        return true
    }
}

extension StoreRegisterViewController: MultipleSelectImageViewControllerDelegate {
    
    func didSelectAssets(_ assets: [MultipleAsset]) {
        if SystemManager.isNetworkReachable() {
            
            if let asset = assets.first {
                asset.fetchOriginalImage(completeBlock: { [unowned self] (image, info) in
                    if let image = image {
                        self.headshot = asset
                        
                        self.showLoading()
                        image.resize(CGSize(width: 1024, height: 1024), completion: { (newImage) in
                            self.apiTempImage(type: "jpeg", imageString: newImage?.transformToBase64String(format: .jpeg(0.5)))
                        })
                    }
                })
            }
        }
    }
    
    func didCancel() {
        
    }
}

extension StoreRegisterViewController: DeviceTableViewDelegate {
    
    func updateDeviceData(with deviceArray: [EquipmentItemModel.Equipment]) {
        self.deviceArray = deviceArray
    }
    
    func getDeviceSuccess(with deviceArray: [EquipmentItemModel.Equipment]) {
        self.deviceArray = deviceArray
        self.calculateTableViewHeight()
    }
}
