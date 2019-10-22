//
//  UploadPhotoViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

class UploadPhotoViewController: BaseViewController {

    @IBOutlet private weak var provideLabel: UILabel!
    @IBOutlet private weak var collectionView: UploadPhotoCollectionView!
    @IBOutlet private weak var sendButton: IBInspectableButton!
    
    private var designerInfoModel: DesignerInfoModel?
    private var providerInfoModel: ProviderInfoModel?
    private var coverArray: [CoverImg] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        checkSendButtonStatus()
    }
    
    // MARK: Methods
    func setupVCWithModel<T: Codable>(_ model: T) {
        if model is DesignerInfoModel {
            designerInfoModel = model as? DesignerInfoModel
        }
        if model is ProviderInfoModel {
            providerInfoModel = model as? ProviderInfoModel
        }
    }
    
    private func setupUI() {
        self.provideLabel.isHidden = (UserManager.sharedInstance.userIdentity == .designer) ? false : true
    }
    
    private func setupCollectionView() {
        let collectionViewMargin: CGFloat = 50.0
        let width = (screenWidth - collectionViewMargin * 2) / 2
        collectionView.setupCollectionViewWith(coverArray: coverArray, itemWidth: width, targetViewController: self, delegate: self, type: .Register)
    }
    
    private func checkSendButtonStatus() {
        if coverArray.count == 0 {
            self.sendButton.backgroundColor = color_AAAAAA
            self.sendButton.isUserInteractionEnabled = false
        } else {
            self.sendButton.backgroundColor = color_1A1C69
            self.sendButton.isUserInteractionEnabled = true
        }
    }
    
    private func checkIsUploadingWithErrorBody(_ body: String) -> Bool {
        if collectionView.isUploading {
            SystemManager.showWarningBanner(title: "", body: body)
            return true
        }
        return false
    }
    
    // MARK: Event Handler
    @IBAction private func sendVerifyButtonPress(_ sender: UIButton) {
        if !checkIsUploadingWithErrorBody(LocalizedString("Lang_RT_023")) {
            if UserManager.sharedInstance.userIdentity == .designer {
                apiSetDesignerInfo()
            } else {
                apiSetProviderInfo()
            }
        }
    }
    
    // MARK: API
    private func apiSetDesignerInfo() {
        if SystemManager.isNetworkReachable() {
            
            if let model = designerInfoModel {
                self.showLoading()
                
                OperatingManager.apiSetDesignerInfo(editType: "R", nickName: model.nickName, realName: model.realName, identityNo: model.identityNo, sex: model.sex, zcId: model.zcId, address: model.address, experience: model.experience, position: model.position, characterization: model.characterization, licenseImg: model.licenseImg, coverImg: coverArray, headerImg: model.headerImg, success: { [unowned self] (model) in
                    
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
    
    private func apiSetProviderInfo() {
        if SystemManager.isNetworkReachable() {
           
            if let model = providerInfoModel {
                self.showLoading()
                
                OperatingManager.apiSetProviderInfo(editType:"R", nickName: model.nickName, telArea: model.telArea, tel: model.tel, uniformNumber: model.uniformNumber, zcId: model.zcId, address: model.address, areaSize: model.areaSize, characterization: model.characterization, contactInformation: model.contactInformation, equipment: model.equipment, coverImg: coverArray, headerImg: model.headerImg, success: { [unowned self] (model) in
                    
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

extension UploadPhotoViewController: UploadPhotoCollectionViewDelegate {
    
    func updatePhotoData(with coverArray: [CoverImg]) {
        self.coverArray = coverArray
        self.checkSendButtonStatus()
    }
    
    func deletePhoto(at index: Int) {
        self.coverArray.remove(at: index)
        self.checkSendButtonStatus()
    }
}
