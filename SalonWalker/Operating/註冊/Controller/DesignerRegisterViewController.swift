 //
//  RegisterViewController_Designer.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/5.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class DesignerRegisterViewController: BaseViewController {

    // MARK: Property
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
    
    private var headshot: MultipleAsset?
    private var headshotId: Int?
    private var selectCityRow: Int = -1
    private var selectAreaRow: Int = -1
    private var zcId: Int = -1
    private var licenseArray = [LicenseImg]()
    
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
        nickNameTextField.text = UserManager.sharedInstance.nickName
        calculateTextViewHeight(myIntroductionTextView)
        licenseTableView.setupTableViewWith(licenseArray: licenseArray, targetViewController: self, delegate: self)
        resetLicenseTableViewHeight()
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
    
    private func resetLicenseTableViewHeight() {
        licenseViewHeight.constant = 17.0 + 10.0 + licenseCellHeight * CGFloat(licenseArray.count)
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
            if (model.tempImgId == nil && model.name?.count != 0) ||
                (model.tempImgId != nil && model.name?.count == 0) {
                return LocalizedString("Lang_RT_022")
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
    
    @IBAction private func uploadCoverPhotoButtonPress(_ sender: UIButton) {
        if let errorBody = checkField() {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_008"), body: errorBody)
            return
        }
        
        let sex = (maleButton.isSelected) ? "m" : "f"
        let experience = Int(slider.value)
        let address = (addressTextField.text?.count == 0) ? "" : addressTextField.text!
        var headerImg: HeaderImg?
        if let headshotId = headshotId {
            headerImg = HeaderImg(imgUrl: nil, headerImgId: nil, tempImgId: headshotId, act: "add")
        }
        let model = DesignerInfoModel(ouId: UserManager.sharedInstance.ouId!, dId: nil, email: "", internationalPrefix: "", phone: "", nickName: nickNameTextField.text!, realName: realNameTextField.text!, identityNo: idNumberTextField.text!, sex: sex, zcId: zcId, cityName: nil, areaName: nil, address: address, experience: experience, position: jobTitleTextField.text!, characterization: myIntroductionTextView.text!, licenseImg: licenseArray, coverImg: [], headerImg: headerImg, slId: 0, cautionTotal: 0, missTotal: 0, cautionDetail: nil, missDetail: nil, reminder: true, notice: true, status: 0, penalty: nil, pushTotal: 0)
        let vc = UIStoryboard.init(name: "Register", bundle: nil).instantiateViewController(withIdentifier: String(describing: UploadPhotoViewController.self)) as! UploadPhotoViewController
        vc.setupVCWithModel(model)
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction private func genderButtonPress(_ sender: IBInspectableButton) {
        maleButton.isSelected = false
        femaleButton.isSelected = false
        maleButton.backgroundColor = color_EEE9FE
        femaleButton.backgroundColor = color_EEE9FE
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = (sender.isSelected) ? color_1A1C69 : color_EEE9FE
    }
    
    @IBAction private func sliderValueChange(_ sender: UISlider) {
        qualificationLabel.text = String(Int(sender.value)) + LocalizedString("Lang_RT_015")
        if sender.value == 25 {
            qualificationLabel.text = String(Int(sender.value)) + LocalizedString("Lang_RT_015") + "+"
        }
    }
    
    @IBAction private func increaseLicenseButtonPress(_ sender: UIButton) {
        licenseArray.append(LicenseImg(licenseImgId: nil, name: "", imgUrl: nil, tempImgId: nil, act: "add", imageLocalIdentifier: nil))
        licenseTableView.reloadDataWithLicenseArray(licenseArray)
        resetLicenseTableViewHeight()
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

extension DesignerRegisterViewController: UITextViewDelegate {
    
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

extension DesignerRegisterViewController: UITextFieldDelegate {

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

 extension DesignerRegisterViewController: LicenseTableViewDelegate {
    
    func updateLicenseData(with licenseArray: [LicenseImg]) {
        self.licenseArray = licenseArray
        resetLicenseTableViewHeight()
    }
    
    func deleteLicense(at index: Int) {
        licenseArray.remove(at: index)
        resetLicenseTableViewHeight()
    }
}
 
 extension DesignerRegisterViewController: MultipleSelectImageViewControllerDelegate {
    
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

