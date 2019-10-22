//
//  ProviderInfoViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/7/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ProviderInfoViewController: BaseViewController {
    
    @IBOutlet private weak var saveButton: UIButton!
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
    @IBOutlet private weak var collectionView: UploadPhotoCollectionView!
    @IBOutlet private weak var coverViewHeight: NSLayoutConstraint!
    
    private var deviceArray = [EquipmentItemModel.Equipment]()
    
    private var headshot: MultipleAsset?
    private var selectCityRow: Int = -1
    private var selectAreaRow: Int = -1
    private var zcId: Int = -1
    
    private var providerInfoModel: ProviderInfoModel?
    private var coverArray: [CoverImg] = []
    private var deleteCoverArray: [CoverImg] = []
    private var itemWidth: CGFloat {
        let collectionViewMargin: CGFloat = 20 + 25
        let width = (screenWidth - collectionViewMargin) / 2
        return width
    }
    
    private lazy var constraintArray: Array<NSLayoutConstraint> = {
        return [introductionViewHeight,trafficViewHeight]
    }()
    
    // MARK: Lice Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        setupTextField()
    }
    
    // MARK: Methods
    func setupVCWith(model: ProviderInfoModel?) {
        self.providerInfoModel = model
    }

    private func initialize() {
        if let model = providerInfoModel {
            if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                headshotImageView.setImage(with: imgUrl)
            }
            storeNameTextField.text = model.nickName
            telAreaTextField.text = model.telArea
            telTextField.text = model.tel
            unifiedBusinessNoTextField.text = model.uniformNumber
            introductionTextView.text = model.characterization
            calculateTextViewHeight(introductionTextView)
            
            zcId = model.zcId
            if let cityName = model.cityName , let cityIndex = SystemManager.getSelectCityIndex(cityName: cityName) {
                cityLabel.text = cityName
                cityLabel.textColor = .black
                selectCityRow = cityIndex
                
                if let areaName = model.areaName, let areaIndex = SystemManager.getSelectAreaIndex(cityName: cityName, areaName: areaName) {
                    areaLabel.text = areaName
                    areaLabel.textColor = .black
                    selectAreaRow = areaIndex
                }
            }
            addressTextField.text = model.address
            
            footageTextField.text = String(model.areaSize)
            trafficTextView.text = model.contactInformation
            calculateTextViewHeight(trafficTextView)
            
            deviceTableView.setupTableViewWith(targetViewController: self, delegate: self)
            
            coverArray = model.coverImg
            collectionView.setupCollectionViewWith(coverArray:coverArray, itemWidth: itemWidth, targetViewController: self, delegate: self, type: .EditProviderInfo)
            collectionView.reloadData()
            resetCoverCollectionViewHeight()
        }
    }
    
    private func setupTextField() {
        storeNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        telAreaTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        telTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        unifiedBusinessNoTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        footageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkSaveButtonEnable()
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
    
    private func resetDeviceViewHeight() {
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
    
    private func resetCoverCollectionViewHeight() {
        let cellCount = (coverArray.count < 5) ? coverArray.count + 1 : coverArray.count
        let line = Int(ceil(CGFloat(cellCount) / 2))
        coverViewHeight.constant = 17.0 + 8.0 + itemWidth * CGFloat(line)
    }
    
    private func resetDeviceData() {
        if let equipment = providerInfoModel?.equipment {
            for i in 0..<deviceArray.count {
                for model in equipment {
                    if model.name == deviceArray[i].name {
                        deviceArray[i].count = model.num
                        deviceArray[i].content = model.characterization
                        deviceArray[i].selected = true
                        break
                    }
                }
            }
            deviceTableView.reloadDataWithDeviceArray(deviceArray)
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
            self.checkSaveButtonEnable()
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
                    if model.permitQuantity {
                        if model.count == 0 {
                            return model.name + LocalizedString("Lang_RT_027")
                        }
                    }
                }
            }
        }
        
        if coverArray.count == 0 {
            return LocalizedString("Lang_RT_047")
        }
        
        return nil
    }
    
    private func checkSaveButtonEnable() {
        self.saveButton.isEnabled = false
        let newDevice = deviceArray.filter{ $0.selected }
        let oldDevice = providerInfoModel?.equipment
        if providerInfoModel?.headerImg?.tempImgId != nil ||
            storeNameTextField.text != providerInfoModel?.nickName ||
            telAreaTextField.text != providerInfoModel?.telArea ||
            telTextField.text != providerInfoModel?.tel ||
            unifiedBusinessNoTextField.text != providerInfoModel?.uniformNumber ||
            introductionTextView.text != providerInfoModel?.characterization ||
            zcId != providerInfoModel?.zcId ||
            addressTextField.text != providerInfoModel?.address ||
            Int(footageTextField.text ?? "") != providerInfoModel?.areaSize ||
            trafficTextView.text != providerInfoModel?.contactInformation ||
            newDevice.count != oldDevice?.count ||
            coverArray.count != providerInfoModel?.coverImg.count {
            self.saveButton.isEnabled = true
            return
        }
        
        if let oldDevice = oldDevice {
            for new in newDevice {
                if (oldDevice.contains{$0.name == new.name && ($0.num != new.count || $0.characterization != new.content)
                }) {
                    self.saveButton.isEnabled = true
                    return
                }
            }
        }
        
        for cover in coverArray {
            if cover.tempImgId != nil {
                self.saveButton.isEnabled = true
                return
            }
        }
    }
    
    private func checkIsUploadingWithErrorBody(_ body: String) -> Bool {
        if collectionView.isUploading {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_008"), body: body)
            return true
        }
        return false
    }
    
    private func preview(pId: Int, lat: Double = -1, lng: Double = -1) {
        var equipment = [EquipmentModel]()
        deviceArray.forEach {
            if $0.selected {
                equipment.append(EquipmentModel(name: $0.name, num: $0.count, characterization: $0.content))
            }
        }
        
        let previewModel = ProviderDetailModel(ouId: 0, pId: pId, isRes: false, isFav: false, nickName: storeNameTextField.text ?? "", cityName: cityLabel.text ?? "", areaName: areaLabel.text ?? "", address: addressTextField.text ?? "", telArea: telAreaTextField.text ?? "", tel: telTextField.text ?? "", uniformNumber: unifiedBusinessNoTextField.text ?? "", characterization: introductionTextView.text, contactInformation: trafficTextView.text, lat: lat, lng: lng, evaluationAve: 0, evaluationTotal: 0, favTotal: 0, cautionTotal: 0, missTotal: 0, svcHoursPrices: nil, svcTimesPrices: nil, svcLeasePrices: nil, headerImgUrl: providerInfoModel?.headerImg?.imgUrl, coverImg: coverArray, equipment: equipment, works: nil, openHour: nil)
        let vc = UIStoryboard(name: kStory_StoreDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: StoreDetailViewController.self)) as! StoreDetailViewController
        vc.setupVCWith(previewModel: previewModel)
        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.isNavigationBarHidden = true
        self.present(naviVC, animated: true, completion: nil)
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
                self.checkSaveButtonEnable()
            })
        }
    }
    
    @IBAction private func previewButtonPress(_ sender: UIButton) {
        guard let pId = providerInfoModel?.pId else { return }
        
        let wholeAddress = (cityLabel.text ?? "") + (areaLabel.text ?? "") + (addressTextField.text ?? "")
        if wholeAddress.count > 0 {
            self.showLoading()
            LocationManager.tranferAddressToCoordinat(address: wholeAddress, success: { [unowned self] (coordinate) in
                self.hideLoading()
                self.preview(pId: pId, lat: coordinate.latitude, lng: coordinate.longitude)
            }, failure: { [unowned self] error in
                self.hideLoading()
                self.preview(pId: pId)
            })
        } else {
            preview(pId: pId)
        }
    }
    
    @IBAction private func saveButtonPress(_ sender: UIButton) {
        if !checkIsUploadingWithErrorBody(LocalizedString("Lang_AC_060")) {
            
            if let errorBody = checkField() {
                SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_008"), body: errorBody)
                return
            }
            apiSetProviderInfo()
        }
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
    
    private func apiTempImg_header(imageString: String?) {
        SystemManager.apiTempImage(imageType: "jpeg", image: imageString, fbImgUrl: nil, googleImgUrl: nil, tempImgId: nil, mId: nil, ouId: nil, licenseImgId: nil, coverImgId: nil, act: "new", success: { [unowned self] (model) in
            if model?.syscode == 200 {
                self.providerInfoModel?.headerImg = HeaderImg(imgUrl: model?.data?.imgUrl, headerImgId: nil, tempImgId: model?.data?.tempImgId, act: "add")
                if let imgUrl = model?.data?.imgUrl {
                    self.headshotImageView.setImage(with: imgUrl)
                }
                self.checkSaveButtonEnable()
                self.hideLoading()
            } else {
                self.endLoadingWith(model: model)
            }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
        })
    }
    
    private func apiSetProviderInfo() {
        if SystemManager.isNetworkReachable() {
            if let model = providerInfoModel {
                self.showLoading()
                
                let areaSize = Int(footageTextField.text!) ?? 0
                var equipment: [EquipmentModel] = []
                for model in deviceArray {
                    if model.selected {
                        if model.permitCharacterization {
                            equipment.append(EquipmentModel(name: model.name, num: 0, characterization: model.content))
                        } else {
                            equipment.append(EquipmentModel(name: model.name, num: model.count, characterization: ""))
                        }
                    }
                }
                
                var coverImg = coverArray.filter({ return $0.coverImgId == nil })
                coverImg.append(contentsOf: deleteCoverArray)
                
                OperatingManager.apiSetProviderInfo(editType: "E", nickName: storeNameTextField.text!, telArea: telAreaTextField.text!, tel: telTextField.text!, uniformNumber: unifiedBusinessNoTextField.text!, zcId: zcId, address: addressTextField.text!, areaSize: areaSize, characterization: introductionTextView.text!, contactInformation: trafficTextView.text!, equipment: equipment, coverImg: coverImg, headerImg: model.headerImg, success: { [unowned self] (model) in
                    if model?.syscode == 200 {
                        SystemManager.showAlertWith(alertTitle: model?.data?.msg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            self.navigationController?.popToRootViewController(animated: true)
                        })
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
}

extension ProviderInfoViewController: UITextFieldDelegate {
    
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

extension ProviderInfoViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        calculateTextViewHeight(textView)
        checkSaveButtonEnable()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let totalString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        if let totalString = totalString, totalString.count > 50 {
            return false
        }
        return true
    }
}

extension ProviderInfoViewController: MultipleSelectImageViewControllerDelegate {
    
    func didSelectAssets(_ assets: [MultipleAsset]) {
        if SystemManager.isNetworkReachable() {
            if let asset = assets.first {
                asset.fetchOriginalImage(completeBlock: { [unowned self] (image, info) in
                    if let image = image {
                        self.headshot = asset
                        
                        self.showLoading()
                        image.resize(CGSize(width: 1024, height: 1024), completion: { (newImage) in
                            self.apiTempImg_header(imageString: newImage?.transformToBase64String(format: .jpeg(0.5)))
                        })
                    }
                })
            }
        }
    }
    
    func didCancel() {}
}

extension ProviderInfoViewController: DeviceTableViewDelegate {
    
    func updateDeviceData(with deviceArray: [EquipmentItemModel.Equipment]) {
        self.deviceArray = deviceArray
        self.checkSaveButtonEnable()
    }
    
    func getDeviceSuccess(with deviceArray: [EquipmentItemModel.Equipment]) {
        self.deviceArray = deviceArray
        self.resetDeviceData()
        self.resetDeviceViewHeight()
    }
}

extension ProviderInfoViewController: UploadPhotoCollectionViewDelegate {
    
    func updatePhotoData(with coverArray: [CoverImg]) {
        self.coverArray = coverArray
        self.resetCoverCollectionViewHeight()
        self.checkSaveButtonEnable()
    }
    
    func deletePhoto(at index: Int) {
        if coverArray[index].coverImgId != nil {
            coverArray[index].act = "del"
            deleteCoverArray.append(coverArray[index])
        }
        coverArray.remove(at: index)
        resetCoverCollectionViewHeight()
        checkSaveButtonEnable()
    }
}

