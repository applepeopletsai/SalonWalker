//
//  AlbumDetailViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/29.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Kingfisher

class AlbumDetailViewController: BaseViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navigationTitleLabel: IBInspectableLabel!
    @IBOutlet weak var navigationRightButton: IBInspectableButton!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descrTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var listModel: MediaModel?
    private var editStatus: EditModeStatus = .Normal
    private var workType: ShowWorksType = .Personal
    private var albumId: Int = 0
    private var currentPage = 1
    private var totalPage = 1
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotification() {
        let operationQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, queue: operationQueue) { (_) in
            if self.workType == .Store {
                self.apiGetPlacesAlbumsPhotoList(ppaId: self.albumId)
            } else {
                self.apiGetWorksAlbumsPhotoList(dwaId: self.albumId)
            }
        }
    }
    
    private func setupUI() {
        titleLabel.text = listModel?.name ?? ""
        dateLabel.text = listModel?.createDate ?? ""
        descrTextView.text = listModel?.albumsDesc ?? ""
        if let array = listModel?.albumsPhoto {
            _ = array.map{ model in
                if model.isCover == true {
                    coverImageView.setImage(with: model.photoUrl)
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    private func preSetBeforeActionSheet() {
        let deletePhotoAction = {
            if self.editStatus == .Normal {
                self.editStatus = .Editing
                self.navigationRightButton.setTitle(LocalizedString("Lang_GE_059"), for: .normal)
            }
            self.collectionView.reloadData()
        }
        let deleteAlbumAction = {
            SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_PF_013"), alertMessage: LocalizedString("Lang_PF_019"), leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_059"), leftHandler: nil, rightHandler: {
                if self.workType == .Store {
                    self.apiDelPlacesAlbums()
                } else {
                    self.apiDelWorksAlbums()
                }
            })
        }
        let editAlbumAction = {
            let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditUploadingAlbumViewController.self)) as! EditUploadingAlbumViewController
            if let assetArray = self.listModel?.albumsPhoto {
                var array = [MediaModel]()
                for item in assetArray {
                    let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: item.photoUrl, photoDesc: item.photoDesc, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: item.dwapId, ppapId: item.ppapId, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: item.isCover, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: nil, tempComment: nil, imageLocalIdentifier: nil)
                    array.append(model)
                    if array.count == assetArray.count {
                        if self.workType == .Store {
                            vc.setupEditUploadingToAlbum(photoType: self.workType, imagesArray: array, ppaId: self.albumId, albumName: self.listModel?.name, albumDesc: self.listModel?.albumsDesc)
                        } else {
                            vc.setupEditUploadingToAlbum(photoType: self.workType, imagesArray: array, dwaId: self.albumId, albumName: self.listModel?.name, albumDesc: self.listModel?.albumsDesc)
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
        let sharedAlbumAction = {
            if let array = self.listModel?.albumsPhoto {
                var images = [UIImage]()
                array.forEach{ item in
                    let ir = ImageResource(downloadURL: URL(string: item.photoUrl)!)
                    KingfisherManager.shared.retrieveImage(with: ir, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                        if let image = image {
                            images.append(image)
                            if images.count == array.count {
                                SystemManager.goingToShareInfoAbout(images: images)
                            }
                        }
                    })
                }
            }
            
        }
        SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_012"), LocalizedString("Lang_PF_013"), LocalizedString("Lang_PF_015"), LocalizedString("Lang_PF_017")], style: [.destructive, .destructive, .default, .default], actions: [deletePhotoAction, deleteAlbumAction, editAlbumAction, sharedAlbumAction])
    }
    
    func setupAlbumDetailFrom(workType: ShowWorksType, albumId: Int) {
        self.workType = workType
        self.albumId = albumId
        if workType == .Store {
            self.apiGetPlacesAlbumsPhotoList(ppaId: albumId)
        } else {
            self.apiGetWorksAlbumsPhotoList(dwaId: albumId)
        }
    }
    
    // MARK: Event Handler
    @IBAction private func naviBackButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func editPhotoActionPress(_ sender: IBInspectableButton) {
        if editStatus == .Normal {
            preSetBeforeActionSheet()
        } else if editStatus == .Editing {
            if let array = listModel?.albumsPhoto {
                var deleteList = [Int]()
                for item in array.filter({ $0.selected == true }) {
                    if let dwapId = item.dwapId {
                        deleteList.append(dwapId)
                    }
                    if let ppapId = item.ppapId {
                        deleteList.append(ppapId)
                    }
                }
                if deleteList.count > 0 {
                    if self.workType == .Store {
                        self.apiDelPlacesAlbumsPhoto(ppaId: albumId, ppapId: deleteList)
                    } else {
                        self.apiDelAlbumsPhoto(dwaId: albumId, dwapId:deleteList)
                    }
                } else {
                    self.editStatus = .Normal
                    self.navigationRightButton.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: API - Deisnger
    // W004
    private func apiGetWorksAlbumsPhotoList(dwaId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiGetWorksAlbumsPhotoList(dwaId: dwaId, page: currentPage, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    if let data = model?.data {
                        if self?.currentPage == 1 {
                            if let meta = model?.data?.meta {
                                self?.totalPage = meta.totalPage
                            }
                            self?.listModel = data
                            if let array = data.albumsPhoto {
                                self?.listModel?.albumsPhoto = array.map { model in
                                    var item = model
                                    item.selected = false as Bool
                                    return item
                                }
                            }
                        } else {
                            if let array = data.albumsPhoto {
                                self?.listModel?.albumsPhoto?.append(contentsOf: array.map { model in
                                    var item = model
                                    item.selected = false as Bool
                                    return item
                                })
                            }
                        }
                        self?.setupUI()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W007
    private func apiDelWorksAlbums() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiDelWorksAlbums(dwaId: [albumId], success: { (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let msg = model?.data?.msg {
                        SystemManager.showSuccessBanner(title: msg, body: "")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    }
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W014
    private func apiDelAlbumsPhoto(dwaId: Int, dwapId: [Int]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiDelAlbumsPhoto(dwaId: dwaId, dwapId: dwapId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    if let array = self.listModel?.albumsPhoto {
                        self.listModel?.albumsPhoto = array.filter({ $0.selected == false })
                    }
                    self.editStatus = .Normal
                    self.navigationRightButton.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
                    self.collectionView.reloadData()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // MARK: API - Store
    // P004
    private func apiGetPlacesAlbumsPhotoList(ppaId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiGetPlacesAlbumsPhotoList(ppaId: ppaId, page: currentPage, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    if let data = model?.data {
                        if self?.currentPage == 1 {
                            if let meta = model?.data?.meta {
                                self?.totalPage = meta.totalPage
                            }
                            self?.listModel = data
                            if let array = data.albumsPhoto {
                                self?.listModel?.albumsPhoto = array.map { model in
                                    var item = model
                                    item.selected = false as Bool
                                    return item
                                }
                            }
                        } else {
                            if let array = data.albumsPhoto {
                                self?.listModel?.albumsPhoto?.append(contentsOf: array.map { model in
                                    var item = model
                                    item.selected = false as Bool
                                    return item
                                })
                            }
                        }
                        self?.setupUI()
                    }
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P007
    private func apiDelPlacesAlbums() {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiDelPlacesAlbums(ppaId: [albumId], success: { (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    if let msg = model?.data?.msg {
                        SystemManager.showSuccessBanner(title: msg, body: "")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    }
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P014
    private func apiDelPlacesAlbumsPhoto(ppaId: Int, ppapId: [Int]) {
        if SystemManager.isNetworkReachable() {
          
            showLoading()
            PlacesPhotoManager.apiDelAlbumsPhoto(ppaId: ppaId, ppapId: ppapId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    if let array = self.listModel?.albumsPhoto {
                        self.listModel?.albumsPhoto = array.filter({ $0.selected == false })
                    }
                    self.editStatus = .Normal
                    self.navigationRightButton.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
                    self.collectionView.reloadData()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension AlbumDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let array = listModel?.albumsPhoto {
            return array.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlbumDetailCell.self), for: indexPath) as! AlbumDetailCell
        cell.setupAlbumDetailCellWith(model: (listModel?.albumsPhoto![indexPath.item])!, status: editStatus)
        return cell
    }
}

extension AlbumDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editStatus == .Editing {
            if let array = listModel?.albumsPhoto {
                listModel?.albumsPhoto![indexPath.item].selected = !(array[indexPath.item].selected)!
            }
            collectionView.reloadData()
        } else if editStatus == .Normal {
            guard let albumsPhoto = listModel?.albumsPhoto else { return }
            
            let models = albumsPhoto.map{ (model) -> PhotoDetailModel in
                return PhotoDetailModel(url: model.photoUrl, des: model.photoDesc ?? "", dwpId: nil, pppId: nil, dwvId: nil, ppvId: nil, dwaId: nil, ppaId: nil, dwapId: model.dwapId, ppapId: model.ppapId)
            }
            let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: PhotosDetailViewController.self)) as! PhotosDetailViewController
            
            if workType == .Store {
                vc.setupVCWith(models: models, index: indexPath.item, vcType: .ByOperating, viewType: .Album, date: listModel?.createDate, ppaId: albumId, target: self)
            } else {
                vc.setupVCWith(models: models, index: indexPath.item, vcType: .ByOperating, viewType: .Album, date: listModel?.createDate, dwaId: albumId, target: self)
            }
            self.present(vc, animated: true, completion: nil)
//            if let dateString = listModel?.createDate, let photoModel = listModel?.albumsPhoto![indexPath.item] {
//                let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: PhotoDetailViewController.self)) as! PhotoDetailViewController
//                if workType == .Store {
//                    vc.setupPhotoDetailWith(ppaId: albumId, date: dateString, photoModel: photoModel, target: self)
//                } else {
//                    vc.setupPhotoDetailWith(dwaId: albumId, date: dateString, photoModel: photoModel, target: self)
//                }
//                self.navigationController?.present(vc, animated: true, completion: nil)
//            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let array = listModel?.albumsPhoto else { return }
        if indexPath.item > array.count - 3 && currentPage < totalPage {
            currentPage += 1
            if self.workType == .Store {
                self.apiGetPlacesAlbumsPhotoList(ppaId: self.albumId)
            } else {
                self.apiGetWorksAlbumsPhotoList(dwaId: self.albumId)
            }
        }
    }
}

extension AlbumDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (screenWidth - 2 * 2) / 3 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
