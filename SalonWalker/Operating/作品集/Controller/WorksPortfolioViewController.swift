//
//  WorksPortfolioViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

enum ShowWorksType: String {
    case Personal = "P" //個人作品
    case WorkShop = "C" //本站顧客
    case Store = ""     //場地端
}

protocol WorksPortfolioViewControllerDelegate: class {
    func navigationRightBarButtonTitleChangeTo(text: String)
}

class WorksPortfolioViewController: BaseViewController {

    @IBOutlet private weak var topButtonsView: UIView!
    @IBOutlet private var displayCabinetButtons: [IBInspectableButton]!
    @IBOutlet private weak var collectionView: ShowWorksPhotoCollectionView!
    
    @IBOutlet private weak var photoButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var albumButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var videoButtonWidthConstraint: NSLayoutConstraint!
    
    private weak var delegate: WorksPortfolioViewControllerDelegate?
    private var width: CGFloat = 0.0
    private var worksType: ShowWorksType = .Personal
    private var displayType: DisplayCabinetType = .Photo
    private var editMode: EditModeStatus = .Normal
    private var userSelectedArray: [MediaModel] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        setupUI()
        setupCollectionView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Initialize
    private func setupObserver() {
        let operationQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, queue: operationQueue) { (notif) in
            var type: DisplayCabinetType?
            if let userInfo = notif.userInfo, let data = userInfo["DisplayCabinetType"] as? DisplayCabinetType {
                type = data
            }
            self.collectionView.reflashData(type)
        }
    }
    
    private func setupUI() {
        width = (screenWidth - 10 * 3) / 3 - 1
        
        displayCabinetButtons.forEach {
            setButtonCornerRadius($0)
            if let text = $0.title(for: .normal) {
                [photoButtonWidthConstraint, albumButtonWidthConstraint, videoButtonWidthConstraint][$0.tag].constant = self.getButtonWidth(text, $0.frame.size.height, ($0.titleLabel?.font)!)
            }
        }
    }

    private func setButtonCornerRadius(_ button: IBInspectableButton) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.size.height / 2
    }
    
    private func getButtonWidth(_ input: String?, _ height: CGFloat, _ font: UIFont!) -> CGFloat {
        if let inputString = input {
            return inputString.width(withConstrainedHeight: height, font: font) + 40
        } else {
            return 0
        }
    }
    
    private func setupCollectionView() {
        collectionView.setupCollectionViewWith(itemWidth: width, worksType: worksType, delegate: self, baseVC: self)
    }
    
    // MARK: Event Handler
    @IBAction private func DisplayCabinetHandler(_ sender: IBInspectableButton) {
        displayCabinetButtons.forEach {
            $0.isSelected = (sender.tag == $0.tag)
            let array: [DisplayCabinetType] = [.Photo, .Album, .Video]
            if displayType != array[sender.tag] {
                displayType = array[sender.tag]
                collectionView.updateDesignerCollectionViewData(type: displayType)
            }
        }
    }
    
    // MARK: Method
    func setupPortfolio(type: ShowWorksType, delegate: WorksPortfolioViewControllerDelegate) {
        worksType = type
        self.delegate = delegate
    }
    
    func changeCollectionType(mode: EditModeStatus) {
        editMode = mode
        if mode == .Normal {
            if worksType == .Store {
                apiPlacesTempPhotos()
            } else {
                apiWorkTempPhotos()
            }
        }
        collectionView.changeEditingModelWith(editMode: mode)
    }
    
    func recoveryAPI() {
        collectionView.updateDesignerCollectionViewData(type: self.displayType)
    }
    
    func cleanData() {
        collectionView.cleanData()
    }
    
    private func actionAfterDelete(_ input: DisplayCabinetType) {
        for cell in collectionView.visibleCells {
            (cell as! ShowWorksPhotoCell).resetCheckedButtonSelectStatus()
        }
        self.userSelectedArray.removeAll()
        self.collectionView.reflashData(input)
    }
    
    // 場地的刪除
    private func apiPlacesTempPhotos() {
        var dwpArray: [Int] = []
        var dwaArray: [Int] = []
        var dwvArray: [Int] = []
        
        for obj in userSelectedArray {
            if let pppId = obj.pppId {
                dwpArray.append(pppId)
            }
            if let ppaId = obj.ppaId {
                dwaArray.append(ppaId)
            }
            if let ppvId = obj.ppvId {
                dwvArray.append(ppvId)
            }
        }
        if dwpArray.count > 0 {
            apiDelPlacesPhoto(array: dwpArray)
        }
        if dwaArray.count > 0 {
            apiDelPlacesAlbum(array: dwaArray)
        }
        if dwvArray.count > 0 {
            apiDelPlacesVideo(array: dwvArray)
        }
    }
    
    // 設計師的刪除
    private func apiWorkTempPhotos() {
        var dwpArray: [Int] = []
        var dwaArray: [Int] = []
        var dwvArray: [Int] = []
        
        for obj in userSelectedArray {
            if let dwpId = obj.dwpId {
                dwpArray.append(dwpId)
            }
            if let dwaId = obj.dwaId {
                dwaArray.append(dwaId)
            }
            if let dwvId = obj.dwvId {
                dwvArray.append(dwvId)
            }
        }
        if dwpArray.count > 0 {
            apiDelPhoto(array: dwpArray)
        }
        if dwaArray.count > 0 {
            apiDelAlbum(array: dwaArray)
        }
        if dwvArray.count > 0 {
            apiDelVideo(array: dwvArray)
        }
    }
    
    // MARK: API - Designer
    // W015
    private func apiDelPhoto(array: [Int]) {
        SystemManager.showLoading()
        WorksManager.apiDelPhoto(dwpId: array, success: { [unowned self] (model) in
            SystemManager.hideLoading()
            if model?.syscode == 200 {
                self.actionAfterDelete(.Photo)
            } else {
                if let errMsg = model?.sysmsg {
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: errMsg)
                }
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    // W007
    private func apiDelAlbum(array: [Int]) {
        SystemManager.showLoading()
        WorksManager.apiDelWorksAlbums(dwaId: array, success: { [unowned self] (model) in
            SystemManager.hideLoading()
            if model?.syscode == 200 {
                self.actionAfterDelete(.Album)
            } else {
                if let errMsg = model?.sysmsg {
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: errMsg)
                }
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    // W016
    private func apiDelVideo(array: [Int]) {
        SystemManager.showLoading()
        WorksManager.apiDelVideo(dwvId: array, success: { [unowned self] (model) in
            SystemManager.hideLoading()
            if model?.syscode == 200 {
                self.actionAfterDelete(.Video)
            } else {
                if let errMsg = model?.sysmsg {
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: errMsg)
                }
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }

    // MARK: API - Store
    // P015
    private func apiDelPlacesPhoto(array: [Int]) {
        SystemManager.showLoading()
        PlacesPhotoManager.apiDelPhoto(pppId: array, success: { [unowned self] (model) in
            if model?.syscode == 200 {
                self.actionAfterDelete(.Photo)
            } else {
                if let errMsg = model?.sysmsg {
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: errMsg)
                }
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    // P007
    private func apiDelPlacesAlbum(array: [Int]) {
        SystemManager.showLoading()
        PlacesPhotoManager.apiDelPlacesAlbums(ppaId: array, success: { [unowned self] (model) in
            if model?.syscode == 200 {
                self.actionAfterDelete(.Album)
            } else {
                if let errMsg = model?.sysmsg {
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: errMsg)
                }
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    // P016
    private func apiDelPlacesVideo(array: [Int]) {
        SystemManager.showLoading()
        PlacesPhotoManager.apiDelVideo(ppvId: array, success: { [unowned self] (model) in
            if model?.syscode == 200 {
                self.actionAfterDelete(.Video)
            } else {
                if let errMsg = model?.sysmsg {
                    SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_009"), body: errMsg)
                }
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
}

extension WorksPortfolioViewController: ShowWorksPhotoCollectionViewDelegate {
    func addImageToEditingList(_ model: MediaModel) {
        if userSelectedArray.filter({$0 == model}).count == 0 {
            userSelectedArray.append(model)
        } else {
            userSelectedArray.remove(at: userSelectedArray.index(of: model)!)
        }
        if editMode == .Editing {
            if userSelectedArray.count > 0 {
                self.delegate?.navigationRightBarButtonTitleChangeTo(text: LocalizedString("Lang_GE_059"))
            }
            else {
                self.delegate?.navigationRightBarButtonTitleChangeTo(text: LocalizedString("Lang_GE_060"))
            }
        }
    }
}
