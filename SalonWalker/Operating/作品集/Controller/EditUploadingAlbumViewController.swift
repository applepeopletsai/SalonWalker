//
//  EditUploadingAlbumViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/27.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

class EditUploadingAlbumViewController: BaseViewController {
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var navigationRightButton: IBInspectableButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var albumPhotos = [MediaModel]()
    private var showsWorksType: ShowWorksType = .Personal
    private var descrDict = [String: String]()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        navigationRightButton.setTitle(LocalizedString("Lang_PF_005"), for: .normal)
        navigationTitleLabel.text = "\(LocalizedString("Lang_PF_006"))（\(albumPhotos.count)\(LocalizedString("Lang_RT_043"))）"
        if let title = descrDict["title"] {
            if title.count > 0 {
                navigationRightButton.isEnabled = true
            }
        }
        collectionView.register(EUAAddCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        collectionView.reloadData()
    }
    
    // 合併入口method
    func setupEditUploadingToAlbum(photoType: ShowWorksType, imagesArray: [MediaModel], dwaId: Int? = nil, ppaId: Int? = nil, albumName: String? = nil, albumDesc: String? = nil) {
        showsWorksType = photoType
        albumPhotos = imagesArray
        if let dwaId = dwaId {
            descrDict["dwaId"] = "\(dwaId)"
        }
        if let ppaId = ppaId {
            descrDict["ppaId"] = "\(ppaId)"
        }
        if let title = albumName {
            descrDict["title"] = title
        }
        if let comment = albumDesc {
            descrDict["comment"] = comment
        }
    }
    
    // MARK: Event Handler
    @IBAction private func naviBackButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func uploadingPhotos(_ sender: UIButton) {
        if let name = descrDict["title"] {
            if descrDict["ppaId"] != nil || descrDict["dwaId"] != nil {
                //W006 編輯相簿名稱 / 說明 (設計師)
                if let dwaId = descrDict["dwaId"], let dwaIdInt = Int(dwaId) {
                    apiEditWorksAlbums(dwaId: dwaIdInt, name: name, albumsDesc: descrDict["comment"])
                } else if let ppaId = descrDict["ppaId"], let ppaIdInt = Int(ppaId) {
                    apiEditPlacesAlbums(ppaId: ppaIdInt, name: name, albumsDesc: descrDict["comment"])
                } else {
                    //W012 的上傳相簿照片
                    uploadAssets()
                }
            } else {
                //W005 的建立相簿
                if showsWorksType == .Store {
                    apiAddPlacesAlbums(name: name, desc: descrDict["comment"])
                } else {
                    apiAddWorksAlbums(photoType: showsWorksType.rawValue, name: name, description: descrDict["comment"])
                }
            }
        } else {
            SystemManager.showAlertWith(alertTitle: nil, alertMessage: LocalizedString("Lang_PF_020"), buttonTitle: LocalizedString("Lang_GE_056"), handler: nil)
        }
    }
    
    // MARK: Method
    private func checkIfNeedUploadAssets() -> Int {
        var needUploadCount = 0
        for item in albumPhotos {
            if let _ = item.imageLocalIdentifier {
                needUploadCount = needUploadCount + 1
            }
        }
        
        return needUploadCount
    }
    
    private func figureOutBeforeGoAPI(images: [UIImage]) {
        if let dwaId = self.descrDict["dwaId"], let dwaIdInt = Int(dwaId) {
            self.apiUploadAlbumsPhoto(dwaId: dwaIdInt, modelArray: images)
        }
        if let ppaId = self.descrDict["ppaId"], let ppaIdInt = Int(ppaId) {
            self.apiUploadPlacesAlbumsPhoto(ppaId: ppaIdInt, modelArray: images)
        }
    }
    
    private func uploadAssets() {
        if checkIfNeedUploadAssets() == 0 { return }
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            var images = [UIImage]()
            var totalAmount = 0.0
            for item in albumPhotos {
                if let localIdentifier = item.imageLocalIdentifier, localIdentifier.count != 0 {
                    let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                    if let asset = assets.firstObject {
                        MultipleAsset(originalAsset: asset).fetchOriginalImage { (image, info) in
                            if let info = info, let image = image {
                                let path: URL = info["PHImageFileURLKey"] as! URL
                                let amountSize = path.getFileSize()
                                totalAmount = totalAmount + amountSize
                                print("== each Size == \(amountSize)")
                                images.append(image)
                                if images.count == self.checkIfNeedUploadAssets() {
                                    self.hideLoading()
                                    if totalAmount > 50.0 {
                                        SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_PF_026"), body: "")
                                    } else {
                                        self.figureOutBeforeGoAPI(images: images)
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
    // W005
    private func apiAddWorksAlbums(photoType: String, name: String, description: String?) {
        if SystemManager.isNetworkReachable() {
            showLoading()
            WorksManager.apiAddWorksAlbums(photoType: photoType, name: name, albumsDesc: description, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    if let dwaId = model?.data?.dwaId {
                        self?.descrDict["dwaId"] = "\(dwaId)"
                        self?.uploadAssets()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W006
    private func apiEditWorksAlbums(dwaId: Int, name: String, albumsDesc: String?) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiEditWorksAlbums(dwaId: dwaId, name: name, albumsDesc: albumsDesc, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    if self?.checkIfNeedUploadAssets() == 0 {
                        SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_027"), body: "")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.uploadAssets()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W012
    private func apiUploadAlbumsPhoto(dwaId: Int, modelArray: [UIImage]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiUploadAlbumsPhoto(dwaId: dwaId, uploadFile: modelArray, photoDesc: albumPhotos.map{ $0.photoDesc ?? ""}, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: ["DisplayCabinetType": DisplayCabinetType.Album])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // MARK: API - Store
    // P005
    private func apiAddPlacesAlbums(name: String, desc: String?) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiAddPlacesAlbums(name: name, albumsDesc: desc, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    if let ppaId = model?.data?.ppaId {
                        self?.descrDict["ppaId"] = "\(ppaId)"
                        self?.uploadAssets()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P006
    private func apiEditPlacesAlbums(ppaId: Int, name: String, albumsDesc: String?) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiEditPlacesAlbums(ppaId: ppaId, name: name, albumsDesc: albumsDesc, success: { [weak self] (model) in
                
                if model?.syscode == 200 {
                    self?.hideLoading()
                    if self?.checkIfNeedUploadAssets() == 0 {
                        SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_027"), body: "")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.uploadAssets()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P012
    private func apiUploadPlacesAlbumsPhoto(ppaId: Int, modelArray: [UIImage]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiUploadAlbumsPhoto(ppaId: ppaId, uploadFile: modelArray, photoDesc: albumPhotos.map{ $0.photoDesc ?? ""}, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension EditUploadingAlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumPhotos.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EUATitleCell.self), for: indexPath) as! EUATitleCell
            var title = ""
            if let name = descrDict["title"] {
                title = name
            }
            cell.setupEUATitleDelegate(title: title, delegate: self)
            return cell
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EUACommentCell.self), for: indexPath) as! EUACommentCell
            cell.setupEUACommentDelegate(comment: descrDict["comment"], delegate: self)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EUAImageCell.self), for: indexPath) as! EUAImageCell
            cell.setupEUAImage(photo: albumPhotos[indexPath.item - 2])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return addPhotoFooter(kind: kind, indexPath: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
    
    @objc private func addPhoto() {
        var selectAssets = [MultipleAsset]()
        for item in albumPhotos {
            if let localIdentifier = item.imageLocalIdentifier, localIdentifier.count != 0 {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                if let asset = assets.firstObject {
                    selectAssets.append(MultipleAsset(originalAsset: asset))
                }
            }
        }
        PresentationTool.showImagePickerWith(selectAssets: selectAssets, maxSelectCount: 0, showVideo: false, target: self)
    }
    
    private func addPhotoFooter(kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        footer.removeAllSubviews()
        let view = IBInspectableView(frame: CGRect(x: 10, y: 10, width: screenWidth - 20, height: 60 - 20))
        view.borderWidth = 1
        view.borderColor = .lightGray
        let imageView = UIImageView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 20, width: 20, height: 20))
        imageView.image = UIImage(named: "brn_upload_addmore")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        let label = UILabel(frame: CGRect(x: view.frame.midX - 15, y: view.frame.midY - 25, width: 100, height: 30))
        label.text = LocalizedString("Lang_PF_009")
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(label)
        footer.addSubview(view)
        footer.removeAllGestureRecognizer()
        let ges = UITapGestureRecognizer(target: self, action: #selector(addPhoto))
        ges.numberOfTapsRequired = 1
        footer.addGestureRecognizer(ges)
        return footer
    }
}

extension EditUploadingAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item > 1 {
            if let albumName = descrDict["title"] {
                let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditUploadingPhotoViewController.self)) as! EditUploadingPhotoViewController
                if showsWorksType == .Store {
                    var storeAlbumId: Int? = nil
                    if let ppaId = self.descrDict["ppaId"], let ppaIdInt = Int(ppaId) {
                        storeAlbumId = ppaIdInt
                    }
                    vc.setupPhotoList(photoType: showsWorksType, ppaId: storeAlbumId, photoArray: albumPhotos, albumName: albumName, albumDescr: nil)
                } else {
                    var designerAlbumId: Int? = nil
                    if let dwaId = self.descrDict["dwaId"], let dwaIdInt = Int(dwaId) {
                        designerAlbumId = dwaIdInt
                    }
                    vc.setupPhotoList(photoType: showsWorksType, dwaId: designerAlbumId, photoArray: albumPhotos, albumName: albumName, albumDescr: nil)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                SystemManager.showAlertWith(alertTitle: nil, alertMessage: LocalizedString("Lang_PF_024"), buttonTitle: LocalizedString("Lang_GE_056"), handler: nil)
            }
        }
    }
}

extension EditUploadingAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: screenWidth, height: 50)
        } else if indexPath.item == 1 {
            return CGSize(width: screenWidth, height: 100)
        } else if indexPath.item == 2 {
            return CGSize(width: screenWidth, height: screenWidth / 375 * 175)
        } else {
            let width = screenWidth / 3 - 0.1
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 60)
    }
}

extension EditUploadingAlbumViewController: EUATitleCellDelegate {
    func addEUATitle(title: String) {
        descrDict["title"] = title
        if let text = descrDict["title"], text.count > 0 {
            navigationRightButton.isEnabled = true
        } else {
            navigationRightButton.isEnabled = false
        }
    }
}

extension EditUploadingAlbumViewController: EUACommentCellDelegate {
    func addEUAComment(comment: String) {
        descrDict["comment"] = comment
    }
}

extension EditUploadingAlbumViewController: MultipleSelectImageViewControllerDelegate {
    func didSelectAssets(_ assets: [MultipleAsset]) {
        
        albumPhotos = albumPhotos.filter{ photo in
            assets.contains{ (model) -> Bool in
                if let coverLocalIdentifier = photo.imageLocalIdentifier {
                    return coverLocalIdentifier == model.localIdentifier
                } else {
                    return photo.dwpId != nil || photo.dwapId != nil || photo.pppId != nil || photo.ppapId != nil
                }
            }
        }
        
        var shouldAddAssets = [MultipleAsset]()
        if albumPhotos.count == 0 {
            shouldAddAssets = assets
        } else {
            // 篩選：新選取的照片
            let sameImageIndex = assets.enumerated().filter { asset in
                albumPhotos.contains { model -> Bool in
                    return asset.element.localIdentifier == (model.imageLocalIdentifier ?? "")
                }
                }.map{ $0.offset }
            
            shouldAddAssets = assets.enumerated().filter{ !sameImageIndex.contains($0.offset) }.map{ $0.element }
        }
        
        for asset in shouldAddAssets {
            let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: nil, tempComment: nil, imageLocalIdentifier: asset.localIdentifier)
            albumPhotos.insert(model, at: 0)
        }
        initialize()
    }
    
    func didCancel() {}
}
