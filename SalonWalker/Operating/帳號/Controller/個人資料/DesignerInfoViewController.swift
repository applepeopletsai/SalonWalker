//
//  DesignerInfoViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/6/28.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class DesignerInfoViewController: BaseViewController {
    
    @IBOutlet private weak var saveButton: IBInspectableButton!
    @IBOutlet private weak var myIntroductionViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var myIntroductionTextView: IBInspectableTextView!
    @IBOutlet private weak var licenseTableView: LicenseTableView!
    @IBOutlet private weak var licenseViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var maleButton: IBInspectableButton!
    @IBOutlet private weak var femaleButton: IBInspectableButton!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var qualificationLabel: UILabel!
    @IBOutlet private weak var headshotImageView: UIImageView!
    @IBOutlet private weak var nickNameTextField: IBInspectableTextField!
    @IBOutlet private weak var realNameTextField: IBInspectableTextField!
    @IBOutlet private weak var idNumberTextField: IBInspectableTextField!
    @IBOutlet private weak var jobTitleTextField: IBInspectableTextField!
    @IBOutlet private weak var realNameTipLabel: IBInspectableLabel!
    @IBOutlet private weak var idNumberTipLabel: IBInspectableLabel!
    @IBOutlet private weak var cityLabel: IBInspectableLabel!
    @IBOutlet private weak var areaLabel: IBInspectableLabel!
    @IBOutlet private weak var addressTextField: IBInspectableTextField!
    @IBOutlet private weak var collectionView: UploadPhotoCollectionView!
    @IBOutlet private weak var coverViewHeight: NSLayoutConstraint!
    
    private var headshot: MultipleAsset?
    private var selectCityRow = -1
    private var selectAreaRow = -1
    private var zcId = -1
    private var licenseArray = [LicenseImg]()
    private var deleteLicenseArray = [LicenseImg]()
    
    private var designerInfoModel: DesignerInfoModel?
    private var coverArray: [CoverImg] = []
    private var deleteCoverArray: [CoverImg] = []
    private var itemWidth: CGFloat {
        let collectionViewMargin: CGFloat = 20 + 25
        let width = (screenWidth - collectionViewMargin) / 2
        return width
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextField()
    }
    
    // MARK: Methods
    func setupVCWith(model: DesignerInfoModel?) {
        self.designerInfoModel = model
    }
    
    private func setupUI() {
        if let model = designerInfoModel {
            if let imgUrl = model.headerImg?.imgUrl, imgUrl.count > 0 {
                headshotImageView.setImage(with: imgUrl)
            }
            nickNameTextField.text = model.nickName
            realNameTextField.text = model.realName
            idNumberTextField.text = model.identityNo
            myIntroductionTextView.text = model.characterization
            calculateTextViewHeight(myIntroductionTextView)
            jobTitleTextField.text = model.position
            
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
            
            if model.sex == "m" {
                maleButton.isSelected = true
                maleButton.backgroundColor = color_1A1C69
            } else {
                femaleButton.isSelected = true
                femaleButton.backgroundColor = color_1A1C69
            }
            
            qualificationLabel.text = (model.experience == 25) ? String(model.experience) + LocalizedString("Lang_RT_015") + "+" : String(model.experience) + LocalizedString("Lang_RT_015")
            slider.value = Float(model.experience)
            
            if let license = model.licenseImg {
                licenseArray = license
            }
            licenseTableView.setupTableViewWith(licenseArray: licenseArray, targetViewController: self, delegate: self)
            resetLicenseTableViewHeight()
            
            coverArray = model.coverImg
            collectionView.setupCollectionViewWith(coverArray:coverArray, itemWidth: itemWidth, targetViewController: self, delegate: self, type: .EditDesignerInfo)
            resetCoverCollectionViewHeight()
        }
    }
    
    private func setupTextField() {
        nickNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        realNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        idNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        jobTitleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkSaveButtonEnable()
    }
    
    private func resetLicenseTableViewHeight() {
        licenseViewHeight.constant = 17.0 + 10.0 + licenseCellHeight * CGFloat(licenseArray.count)
    }
    
    private func resetCoverCollectionViewHeight() {
        let cellCount = (coverArray.count < 5) ? coverArray.count + 1 : coverArray.count
        let line = Int(ceil(CGFloat(cellCount) / 2))
        coverViewHeight.constant = 17.0 + 8.0 + itemWidth * CGFloat(line)
    }
    
    private func calculateTextViewHeight(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: screenWidth - 25.0 - 20.0 - 10.0 * 2, height: CGFloat.greatestFiniteMagnitude))
        let increaseHeight = size.height - textView.frame.size.height
        myIntroductionViewHeight.constant += increaseHeight
        if myIntroductionViewHeight.constant > 150.0 {
            myIntroductionViewHeight.constant = 150.0
        }
        if myIntroductionViewHeight.constant < 70.0 {
            myIntroductionViewHeight.constant = 70.0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
        if nickNameTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_002") + LocalizedString("Lang_RT_019")
        }
        
        if realNameTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_003") + LocalizedString("Lang_RT_019")
        }
        
        if idNumberTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_004") + LocalizedString("Lang_RT_019")
        }
        
        if myIntroductionTextView.text?.count == 0 {
            return LocalizedString("Lang_RT_020") + LocalizedString("Lang_RT_019")
        }
        
        if jobTitleTextField.text?.count == 0 {
            return LocalizedString("Lang_RT_008") + LocalizedString("Lang_RT_019")
        }
        
        if selectCityRow == -1 {
            return LocalizedString("Lang_GE_007") + LocalizedString("Lang_HM_021")
        }
        
        if selectAreaRow == -1 {
            return LocalizedString("Lang_GE_007") + LocalizedString("Lang_HM_022")
        }
        
        if !maleButton.isSelected && !femaleButton.isSelected {
            return LocalizedString("Lang_GE_007") + LocalizedString("Lang_RT_021")
        }
        
        for model in licenseArray {
            if (model.name?.count == 0 && (model.tempImgId != nil || model.licenseImgId != nil)) ||
                (model.name?.count != 0 && (model.tempImgId == nil && model.licenseImgId == nil)) {
                return LocalizedString("Lang_RT_022")
            }
        }
        
        if coverArray.count == 0 {
            return LocalizedString("Lang_RT_047")
        }
        
        return nil
    }
    
    private func checkSaveButtonEnable() {
        self.saveButton.isEnabled = false
        let sex = (maleButton.isSelected) ? "m" : "f"
        if designerInfoModel?.headerImg?.tempImgId != nil ||
            nickNameTextField.text != designerInfoModel?.nickName ||
            realNameTextField.text != designerInfoModel?.realName ||
            idNumberTextField.text != designerInfoModel?.identityNo ||
            myIntroductionTextView.text != designerInfoModel?.characterization ||
            jobTitleTextField.text != designerInfoModel?.position ||
            zcId != designerInfoModel?.zcId ||
            addressTextField.text != designerInfoModel?.address ||
            sex != designerInfoModel?.sex ||
            Int(slider.value) != designerInfoModel?.experience ||
            licenseArray.count != designerInfoModel?.licenseImg?.count ||
            coverArray.count != designerInfoModel?.coverImg.count {
            self.saveButton.isEnabled = true
            return
        }
        
        for i in 0..<licenseArray.count {
            let newModel = licenseArray[i]
            let oldModel = designerInfoModel?.licenseImg?[i]
            if newModel.name != oldModel?.name ||
                newModel.tempImgId != nil ||
                (newModel.name == oldModel?.name &&
                    (newModel.tempImgId != oldModel?.tempImgId || newModel.licenseImgId != oldModel?.licenseImgId)) {
                self.saveButton.isEnabled = true
                return
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
    
    @IBAction private func genderButtonPress(_ sender: IBInspectableButton) {
        maleButton.isSelected = false
        femaleButton.isSelected = false
        maleButton.backgroundColor = color_EEE9FE
        femaleButton.backgroundColor = color_EEE9FE
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = (sender.isSelected) ? color_1A1C69 : color_EEE9FE
        checkSaveButtonEnable()
    }
    
    @IBAction private func sliderValueChange(_ sender: UISlider) {
        qualificationLabel.text = String(Int(sender.value)) + LocalizedString("Lang_RT_015")
        if sender.value == 25 {
            qualificationLabel.text = String(Int(sender.value)) + LocalizedString("Lang_RT_015") + "+"
        }
        checkSaveButtonEnable()
    }
    
    @IBAction private func increaseLicenseButtonPress(_ sender: UIButton) {
        licenseArray.append(LicenseImg(licenseImgId: nil, name: "", imgUrl: nil, tempImgId: nil, act: "add", imageLocalIdentifier: nil))
        licenseTableView.reloadDataWithLicenseArray(licenseArray)
        resetLicenseTableViewHeight()
        checkSaveButtonEnable()
    }
    
    @IBAction private func previewButtonPress(_ sender: UIButton) {
        guard let dId = designerInfoModel?.dId else { return }
        
        let previewModel = DesignerDetailModel(ouId: 0, dId: dId, isRes: false, isTop: false, isFav: false, nickName: nickNameTextField.text ?? "", cityName: cityLabel.text ?? "", areaName: areaLabel.text ?? "", experience: Int(slider.value), position: jobTitleTextField.text ?? "", characterization: myIntroductionTextView.text, langName: "", evaluationAve: 0, evaluationTotal: 0, favTotal: 0, headerImgUrl: designerInfoModel?.headerImg?.imgUrl, licenseImg: licenseArray, coverImg: coverArray, cautionTotal: 0, missTotal: 0, svcPlace: nil, paymentType: nil, svcCategory: nil, works: nil, customer: nil, openHour: nil)
        let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerDetailViewController.self)) as! DesignerDetailViewController
        vc.setupVCWith(previewModel: previewModel)
        let naviVC = UINavigationController(rootViewController: vc)
        naviVC.isNavigationBarHidden = true
        self.present(naviVC, animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonPress(_ sender: UIButton) {
        if !checkIsUploadingWithErrorBody(LocalizedString("Lang_AC_060")) {
            
            if let errorBody = checkField() {
                SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_008"), body: errorBody)
                return
            }
            apiSetDesignerInfo()
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
    
    private func apiTempImg(imageString: String?) {
        SystemManager.apiTempImage(imageType: "jpeg", image: imageString, fbImgUrl: nil, googleImgUrl: nil, tempImgId: nil, mId: nil, ouId: nil, licenseImgId: nil, coverImgId: nil, act: "new", success: { (model) in
            if model?.syscode == 200 {
                self.designerInfoModel?.headerImg = HeaderImg(imgUrl: model?.data?.imgUrl, headerImgId: nil, tempImgId: model?.data?.tempImgId, act: "add")
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
    
    private func apiSetDesignerInfo() {
        if SystemManager.isNetworkReachable() {
            
            if let model = designerInfoModel {
                self.showLoading()
                
                var coverImg = coverArray.filter({ return $0.coverImgId == nil })
                coverImg.append(contentsOf: deleteCoverArray)
                
                licenseArray = licenseArray.filter({ return $0.act != nil })
                licenseArray.append(contentsOf: deleteLicenseArray)
                
                //智障邏輯，等待API修改
                var shouldDeleteLicenseIndexArray = [Int]()
                for i in 0..<licenseArray.count {
                    let model = licenseArray[i]
                    if model.tempImgId != nil && model.licenseImgId != nil {
                        licenseArray[i].act = "add"
                        shouldDeleteLicenseIndexArray.append(i)
                    }
                }
                
                for index in shouldDeleteLicenseIndexArray {
                    var model = licenseArray[index]
                    model.act = "del"
                    licenseArray.append(model)
                }
                
                let sex = (maleButton.isSelected) ? "m" : "f"
                let experience = Int(slider.value)
                let address = (addressTextField.text?.count == 0) ? "" : addressTextField.text!
                
                OperatingManager.apiSetDesignerInfo(editType: "E", nickName: nickNameTextField.text!, realName: realNameTextField.text!, identityNo: idNumberTextField.text!, sex: sex, zcId: zcId, address: address, experience: experience, position: jobTitleTextField.text!, characterization: myIntroductionTextView.text!, licenseImg: licenseArray, coverImg: coverImg, headerImg: model.headerImg, success: { [unowned self] (model) in
                    
                    if model?.syscode == 200 {
                        SystemManager.showAlertWith(alertTitle: model?.data?.msg, alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: {
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        self.hideLoading()
                        self.apiDesignerEditInfo()
                    } else {
                        self.endLoadingWith(model: model)
                    }
                    }, failure: { (error) in
                        SystemManager.showErrorAlert(error: error)
                })
            }
        }
    }
    
    private func apiDesignerEditInfo() {
        if SystemManager.isNetworkReachable(showBanner: false) {
            PushManager.apiDesignerEditInfo(success: nil, failure: nil)
        }
    }
}

extension DesignerInfoViewController: UITextViewDelegate {
    
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

extension DesignerInfoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let totalString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if let totalString = totalString {
            if textField == realNameTextField || textField == idNumberTextField {
                let label = (textField == realNameTextField) ? realNameTipLabel : idNumberTipLabel
                label?.isHidden = (totalString.count > 0)
            }
            
            let maxTextCount = (textField == jobTitleTextField) ? 15 : 10
            if totalString.count > maxTextCount {
                return false
            }
        }
        return true
    }
}

extension DesignerInfoViewController: MultipleSelectImageViewControllerDelegate {
    
    func didSelectAssets(_ assets: [MultipleAsset]) {
        if SystemManager.isNetworkReachable() {
            if let asset = assets.first {
                asset.fetchOriginalImage(completeBlock: { [unowned self] (image, info) in
                    if let image = image {
                        self.headshot = asset
                        
                        self.showLoading()
                        image.resize(CGSize(width: 1024, height: 1024), completion: { (newImage) in
                            self.apiTempImg(imageString: newImage?.transformToBase64String(format: .jpeg(0.5)))
                        })
                    }
                })
            }
        }
    }
    
    func didCancel() {}
}

extension DesignerInfoViewController: LicenseTableViewDelegate {
    
    func updateLicenseData(with licenseArray: [LicenseImg]) {
        self.licenseArray = licenseArray
        resetLicenseTableViewHeight()
        checkSaveButtonEnable()
    }
    
    func deleteLicense(at index: Int) {
        if licenseArray[index].licenseImgId != nil {
            licenseArray[index].act = "del"
            deleteLicenseArray.append(licenseArray[index])
        }
        licenseArray.remove(at: index)
        resetLicenseTableViewHeight()
        checkSaveButtonEnable()
    }
}

extension DesignerInfoViewController: UploadPhotoCollectionViewDelegate {
    
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

