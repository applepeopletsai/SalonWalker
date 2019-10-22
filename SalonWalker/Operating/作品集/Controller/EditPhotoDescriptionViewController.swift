//
//  EditPhotoDescriptionViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/31.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import DKPhotoGallery

class EditPhotoDescriptionViewController: BaseViewController {

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var navigationTitleLabel: IBInspectableLabel!
    @IBOutlet private weak var navigationRightButton: IBInspectableButton!
    @IBOutlet private weak var mainView: DKPlayerView!
    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var textView: IBInspectableTextView!
    
    private var dwpId: Int?
    private var dwaId: Int?
    private var dwapId: Int?
    private var dwvId: Int?
    private var pppId: Int?
    private var ppaId: Int?
    private var ppapId: Int?
    private var ppvId: Int?
    private var inputUrl: String = ""
    private var inputDesc: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        mainView.isHidden = true
        mainImageView.isHidden = true
        mainView.closeBlock = nil
        if dwpId != nil || dwapId != nil || pppId != nil  || ppapId != nil{
            mainImageView.isHidden = false
            mainImageView.setImage(with: inputUrl)
            navigationTitleLabel.text = LocalizedString("Lang_PF_021")
            textView.placeholderLocalizedKey = "Lang_PF_003"
        } else if dwvId != nil || ppvId != nil {
            mainView.isHidden = false
            let asset = AVAsset(url: URL(string: inputUrl)!)
            mainView.asset = asset
            navigationTitleLabel.text = LocalizedString("Lang_PF_022")
            textView.placeholderLocalizedKey = "Lang_PF_004"
        }
        textView.text = inputDesc
    }
    
    func setupEditPhotoDescriptionWith(dwpId: Int? = nil, dwaId: Int? = nil, dwapId: Int? = nil, dwvId: Int? = nil, pppId: Int? = nil, ppaId: Int? = nil, ppapId: Int? = nil, ppvId: Int? = nil, inputUrl: String, inputDesc: String) {
        self.dwpId = dwpId
        self.dwaId = dwaId
        self.dwapId = dwapId
        self.dwvId = dwvId
        self.pppId = pppId
        self.ppaId = ppaId
        self.ppapId = ppapId
        self.ppvId = ppvId
        self.inputUrl = inputUrl
        self.inputDesc = inputDesc
    }
    
    // MARK: EventHandler
    @IBAction private func naviBackButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func naviStoreButtonPress(_ sender: IBInspectableButton) {
        if dwpId != nil || dwvId != nil {
            apiEditPhoto(dwpId: dwpId, dwvId: dwvId, dpDesc: textView.text)
        }
        if let dwaId = dwaId, let dwapId = dwapId {
            let model = ["dwapId": dwapId, "photoDesc": textView.text] as [String : Any]
            apiEditAlbumsPhoto(dwaId: dwaId, albumsPhoto: [model])
        }
        if pppId != nil || ppvId != nil {
            apiEditPlacesPhoto(pppId: pppId, ppvId: ppvId, ppDesc: textView.text)
        }
        if let ppaId = ppaId, let ppapId = ppapId {
            let model = ["ppapId": ppapId, "photoDesc": textView.text] as [String: Any]
            apiEditPlacesAlbumsPhoto(ppaId: ppaId, albumsPhoto: [model])
        }
    }
    
    // MARK: API - Designer
    // W011
    private func apiEditPhoto(dwpId: Int?, dwvId: Int?, dpDesc: String) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiEditPhoto(dwpId: dwpId, dwvId: dwvId, dpDesc: dpDesc, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_GE_021"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W013
    private func apiEditAlbumsPhoto(dwaId: Int, albumsPhoto: [[String: Any]]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiEditAlbumsPhoto(dwaId: dwaId, albumsPhoto: albumsPhoto, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_GE_021"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }

    // MARK: API - Store
    // P011
    private func apiEditPlacesPhoto(pppId: Int?, ppvId: Int?, ppDesc: String) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiEditPhoto(pppId: pppId, ppvId: ppvId, ppDesc: ppDesc, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_GE_021"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P013
    private func apiEditPlacesAlbumsPhoto(ppaId: Int, albumsPhoto: [[String: Any]]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiEditAlbumsPhoto(ppaId: ppaId, albumsPhoto: albumsPhoto, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_GE_021"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension EditPhotoDescriptionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespaces)
        if inputString == self.inputDesc {
            navigationRightButton.isEnabled = false
        } else {
            navigationRightButton.isEnabled = true
        }
        return true
    }
}
