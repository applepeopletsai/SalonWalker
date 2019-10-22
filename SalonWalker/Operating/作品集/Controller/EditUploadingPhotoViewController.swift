//
//  EditUploadingPhotoViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/24.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

class EditUploadingPhotoViewController: BaseViewController {
    
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet private weak var navigationRightButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private var dwaId: Int?
    private var ppaId: Int?
    private var albumName: String?
    private var albumDescr: String?
    private var combineArray = [MediaModel]()
    private var showsWorksType: ShowWorksType = .Personal
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        navigationRightButton.setTitle(LocalizedString("Lang_PF_005"), for: .normal)
        navigationTitleLabel.text = "\(LocalizedString("Lang_GE_058"))（\(combineArray.count)\(LocalizedString("Lang_RT_043"))）"
        tableView.reloadData()
    }
    
    // 合併從上傳相片、相簿進到這的setup function
    func setupPhotoList(photoType: ShowWorksType, dwaId: Int? = nil, ppaId: Int? = nil, photoArray:[MediaModel]?, albumName: String?, albumDescr: String?) {
        showsWorksType = photoType
        combineArray.removeAll()
        
        if let dwaId = dwaId {
            self.dwaId = dwaId
        }
        if let ppaId = ppaId {
            self.ppaId = ppaId
        }
        if let photoArray = photoArray {
            combineArray = photoArray
        }
        if let albumName = albumName {
            self.albumName = albumName
        }
        if let albumDescr = albumDescr {
            self.albumDescr = albumDescr
        }
    }
    
    // MARK: Event Handler
    @IBAction private func naviBackButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func uploadingPhotos(_ sender: UIButton) {
        if let dwaId = dwaId, let albumName = albumName {
            apiEditWorksAlbums(dwaId: dwaId, name: albumName, albumsDesc: albumDescr)
            let oldArray = combineArray.filter{ $0.imageLocalIdentifier != nil && $0.dwapId != nil && $0.photoDesc != nil}.map{ ["dwapId":$0.dwapId!, "photoDesc":$0.photoDesc!] }
            // 如果有編輯舊照片的說明描述，先打W013，完成後再打W012上傳新的照片
            if oldArray.count > 0 {
                apiEditAlbumsPhoto(dwaId: dwaId, albumsPhoto: oldArray)
            } else {
                uploadAssets()
            }
        } else if let ppaId = ppaId, let albumName = albumName {
            apiEditPlacesAlbums(ppaId: ppaId, name: albumName, albumsDesc: albumDescr)
            let oldArray = combineArray.filter{ $0.imageLocalIdentifier != nil && $0.ppapId != nil && $0.photoDesc != nil}.map{ ["ppapId":$0.ppapId!, "photoDesc":$0.photoDesc!] }
            if oldArray.count > 0 {
                apiEditPlacesAlbumsPhoto(ppaId: ppaId, albumsPhoto: oldArray)
            } else {
                uploadAssets()
            }
        } else {
            uploadAssets()
        }
    }
    
    // MARK: Method
    private func isBackToAlbumDetailVC() {
        for controller in self.navigationController?.viewControllers ?? [] {
            if controller.isKind(of: AlbumDetailViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showDeleteAlert (image: UIImage?, action: @escaping actionClosure) {
        PresentationTool.showTwoButtonAlertWith(image: image, message: LocalizedString("Lang_PF_010"), leftButtonTitle: LocalizedString("Lang_GE_060"), leftButtonAction: nil, rightButtonTitle: LocalizedString("Lang_GE_059"), rightButtonAction: action)
    }
    
    private func prepareBeforeGoAPI(images: [UIImage], comments: [String]) {
        if let albumName = self.albumName, albumName.count > 0 {
            if self.dwaId != nil || self.ppaId != nil {
                if self.showsWorksType == .Store {
                    if let ppaId = self.ppaId {
                        self.apiUploadPlacesAlbumsPhoto(ppaId: ppaId, images: images, comments:comments)
                    }
                } else {
                    if let dwaId = self.dwaId {
                        self.apiUploadAlbumsPhoto(dwaId: dwaId, images: images, comments:comments)
                    }
                }
            } else {
                if self.showsWorksType == .Store {
                    self.apiAddPlacesAlbums(name: albumName, desc: self.albumDescr, images: images)
                } else {
                    self.apiAddWorksAlbums(name: albumName, desc: self.albumDescr, images: images)
                }
            }
        } else {
            if self.showsWorksType == .Store {
                self.apiUploadPlacesPhoto(images: images, comments: comments)
            } else {
                self.apiUploadPhoto(images: images, comments: comments)
            }
        }
    }
    
    private func uploadAssets() {

        let comments = combineArray.filter{ $0.imageLocalIdentifier != nil }.map{ $0.photoDesc ?? ""}
        if comments.count == 0 { return }
        
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            var images = [UIImage]()
            
            var totalAmount = 0.0
            for item in combineArray {
                if let localIdentifier = item.imageLocalIdentifier, localIdentifier.count != 0 {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                    if let asset = assets.firstObject {
                        MultipleAsset(originalAsset: asset).fetchOriginalImage { (image, info) in
                            if let info = info, let image = image {
                                let path: URL = info["PHImageFileURLKey"] as! URL
                                let amountSize = path.getFileSize()
                                totalAmount = totalAmount + amountSize
                                images.append(image)
                                if images.count == comments.count {
                                    self.hideLoading()
                                    if totalAmount > 50.0 { SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_PF_026"), body: "")
                                    } else {
                                        self.prepareBeforeGoAPI(images: images, comments: comments)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: API - Designer
    // W005 新增相簿(設計師)
    private func apiAddWorksAlbums(name: String, desc: String?, images: [UIImage]) {
        if SystemManager.isNetworkReachable() {
           self.showLoading()
            WorksManager.apiAddWorksAlbums(photoType: showsWorksType.rawValue, name: name, albumsDesc: desc, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let dwaId = model?.data?.dwaId {
                        self.apiUploadAlbumsPhoto(dwaId: dwaId, images: images, comments: self.combineArray.map{ $0.photoDesc ?? "" })
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W006 編輯相簿名稱/說明(設計師)
    private func apiEditWorksAlbums(dwaId: Int, name: String, albumsDesc: String?) {
        WorksManager.apiEditWorksAlbums(dwaId: dwaId, name: name, albumsDesc: albumsDesc, success: nil, failure: nil)
    }
    
    // W009 上傳相片(設計師)
    private func apiUploadPhoto(images: [UIImage], comments: [String]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiUploadPhoto(photoType: showsWorksType.rawValue, uploadFile: images, photoDesc: comments, success:{ [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
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
    
    // W012 上傳相簿相片(設計師)
    private func apiUploadAlbumsPhoto(dwaId: Int, images: [UIImage], comments: [String]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiUploadAlbumsPhoto(dwaId: dwaId, uploadFile: images, photoDesc: comments, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W013 編輯相簿相片說明(設計師)
    private func apiEditAlbumsPhoto(dwaId: Int, albumsPhoto: [[String: Any]]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiEditAlbumsPhoto(dwaId: dwaId, albumsPhoto: albumsPhoto, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    let newPhotoCount = self.combineArray.filter{ $0.imageLocalIdentifier != nil }.count
                    if newPhotoCount == 0 {
                        SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                        self.isBackToAlbumDetailVC()
                    } else {
                        self.uploadAssets()
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W014 刪除相簿相片(設計師)
    private func apiDelAlbumsPhoto(dwaId: Int, dwapId: [Int], indexPath: IndexPath) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiDelAlbumsPhoto(dwaId: dwaId, dwapId: dwapId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.combineArray.remove(at: indexPath.row - 1)
                    self.initialize()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // MARK: API - Store
    // P005 新增相簿(場地)
    private func apiAddPlacesAlbums(name: String, desc: String?, images: [UIImage]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            PlacesPhotoManager.apiAddPlacesAlbums(name: name, albumsDesc: desc, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let ppaId = model?.data?.ppaId {
                        self.apiUploadPlacesAlbumsPhoto(ppaId: ppaId, images: images, comments: self.combineArray.map{ $0.photoDesc ?? "" })
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P006 編輯相簿說明(場地)
    private func apiEditPlacesAlbums(ppaId: Int, name: String, albumsDesc: String?) {
        PlacesPhotoManager.apiEditPlacesAlbums(ppaId: ppaId, name: name, albumsDesc: albumsDesc, success: nil, failure: nil)
    }
    
    // P009 上傳相片(場地)
    private func apiUploadPlacesPhoto(images: [UIImage], comments: [String]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiUploadPhoto(uploadFile: images, photoDesc: comments, success:{ [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
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
    
    // P012 上傳相簿相片(場地)
    private func apiUploadPlacesAlbumsPhoto(ppaId: Int, images: [UIImage], comments: [String]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiUploadAlbumsPhoto(ppaId: ppaId, uploadFile: images, photoDesc: comments, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P013 編輯相簿相片說明(場地)
    private func apiEditPlacesAlbumsPhoto(ppaId: Int, albumsPhoto: [[String: Any]]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiEditAlbumsPhoto(ppaId: ppaId, albumsPhoto: albumsPhoto, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    let newPhotoCount = self.combineArray.filter{ $0.imageLocalIdentifier != nil }.count
                    if (newPhotoCount == 0) {
                        SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
                        self.isBackToAlbumDetailVC()
                    } else {
                        self.uploadAssets()
                    }
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P014 刪除相簿相片(場地)
    private func apiDelPlacesAlbumsPhoto(ppaId: Int, ppapId: [Int], indexPath: IndexPath) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiDelAlbumsPhoto(ppaId: ppaId, ppapId: ppapId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.combineArray.remove(at: indexPath.row - 1)
                    self.initialize()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension EditUploadingPhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combineArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: EditUploadingMorePhotoCell = tableView.dequeueReusableCell(withIdentifier: "EditUploadingMorePhotoCell", for: indexPath) as! EditUploadingMorePhotoCell
            return cell
        } else {
            let cell: EditUploadingPhotoCell = tableView.dequeueReusableCell(withIdentifier: "EditUploadingPhotoCell", for: indexPath) as! EditUploadingPhotoCell
            cell.setupEditingWith(model: combineArray[indexPath.row - 1], indexPath: indexPath, delegate: self)
            return cell
        }
    }
}

extension EditUploadingPhotoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var selectAssets = [MultipleAsset]()
            
            for item in combineArray {
                if let localIdentifier = item.imageLocalIdentifier, localIdentifier.count != 0 {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                    if let asset = assets.firstObject {
                        selectAssets.append(MultipleAsset(originalAsset: asset))
                    }
                }
            }
            
            PresentationTool.showImagePickerWith(selectAssets: selectAssets, maxSelectCount: 0, showVideo: false, target: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50.0
        } else {
            return screenWidth + 80
        }
    }
}

extension EditUploadingPhotoViewController: EditUploadingPhotoCellDelegate {
    func addUploadingPhotoComment(comment: String, indexPath: IndexPath) {
        combineArray[indexPath.row - 1].photoDesc = comment
    }
    
    func deleteUploadingPhoto(indexPath: IndexPath) {
        let model = combineArray[indexPath.row - 1]
        if let localIdentifier = model.imageLocalIdentifier, localIdentifier.count != 0 {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            if let asset = assets.firstObject {
                MultipleAsset(originalAsset: asset).fetchOriginalImage { (image, info) in
                    if let image = image {
                        self.showDeleteAlert(image: image, action: {
                            self.combineArray.remove(at: indexPath.row - 1)
                            self.initialize()
                        })
                    }
                }
            }
        } else if let imageUrl = model.photoUrl, let url = URL(string: imageUrl) {
            let action = {
                if let dwaId = self.dwaId, let dwapId = model.dwapId {
                    self.apiDelAlbumsPhoto(dwaId: dwaId, dwapId: [dwapId], indexPath: indexPath)
                }
                if let ppaId = self.ppaId, let ppapId = model.ppapId {
                    self.apiDelPlacesAlbumsPhoto(ppaId: ppaId, ppapId: [ppapId], indexPath: indexPath)
                }
            }
            
            let resource = ImageResource(downloadURL: url, cacheKey: imageUrl)
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { [weak self] (image, error, cache, url) in
                self?.showDeleteAlert(image: image, action: action)
            }
        }
    }
}

extension EditUploadingPhotoViewController: MultipleSelectImageViewControllerDelegate {
    func didSelectAssets(_ assets: [MultipleAsset]) {
//        var addArray = [MultipleAsset]()
//        var reduceArray = [MultipleAsset]()
        
        combineArray = combineArray.filter{ photo in
            assets.contains{ (model) -> Bool in
                if let coverLocalIdentifier = photo.imageLocalIdentifier {
                    return coverLocalIdentifier == model.localIdentifier
                } else {
                    return photo.dwpId != nil || photo.dwapId != nil || photo.pppId != nil || photo.ppapId != nil
                }
            }
        }
        
        var shouldAddAssets = [MultipleAsset]()
        if combineArray.count == 0 {
            shouldAddAssets = assets
        } else {
            // 篩選：新選取的照片
            let sameImageIndex = assets.enumerated().filter { asset in
                combineArray.contains { model -> Bool in
                    return asset.element.localIdentifier == (model.imageLocalIdentifier ?? "")
                }
                }.map{ $0.offset }
            
            shouldAddAssets = assets.enumerated().filter{ !sameImageIndex.contains($0.offset) }.map{ $0.element }
        }
        
        for asset in shouldAddAssets {
            let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: nil, tempComment: nil, imageLocalIdentifier: asset.localIdentifier)
            self.combineArray.insert(model, at: 0)
        }

//
//        for asset in assets {
//            var duplicate = false
//            for data in waitingDelArray {
//                if data.localIdentifier == asset.localIdentifier {
//                    duplicate = true
//                }
//            }
//            if !duplicate {
//                // 這張asset是新增的
//                addArray.append(asset)
//            }
//        }
//
//        for data in waitingDelArray {
//            var duplicate = false
//            for asset in assets {
//                if asset.localIdentifier == data.localIdentifier {
//                    duplicate = true
//                }
//            }
//            if !duplicate {
//                // 這張data是被刪掉的
//                reduceArray.append(data)
//            }
//        }
        
//        for asset in reduceArray {
//            for index in 0 ..< combineArray.count {
//                let data = combineArray[index]
//                if data.imageLocalIdentifier == asset.localIdentifier {
//                    commentArray.remove(at: index)
//                }
//            }
//            combineArray = combineArray.filter{ $0.imageLocalIdentifier != asset.localIdentifier }
//        }
        
//        for asset in addArray {
//            let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: nil, tempComment: nil, imageLocalIdentifier: asset.localIdentifier)
//            self.combineArray.insert(model, at: 0)
//            self.commentArray.insert("", at: 0)
//        }
        initialize()
    }
    
    func didCancel() { }
}
