//
//  ShowWorksPhotoCollectionView.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/16.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

protocol ShowWorksPhotoCollectionViewDelegate: class {
    func addImageToEditingList(_ model: MediaModel)
}

class ShowWorksPhotoCollectionView: UICollectionView {
    
    private var photoArray = [MediaModel]()
    private var albumArray = [MediaModel]()
    private var videoArray = [MediaModel]()
    private var selectedAssets = [MultipleAsset]()
    private var displayCab: DisplayCabinetType = .Photo
    private var worksType: ShowWorksType = .Personal
    private var editMode: EditModeStatus = .Normal
    
    private weak var CVdelegate: ShowWorksPhotoCollectionViewDelegate?
    private weak var targetVC: BaseViewController?
    private var itemWidth: CGFloat = 0.0
    private var currentPage_photo = 1
    private var totalPage_photo = 1
    private var currentPage_album = 1
    private var totalPage_album = 1
    private var currentPage_video = 1
    private var totalPage_video = 1

    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        self.registerCell()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: "ShowWorksPhotoCell", bundle: nil), forCellWithReuseIdentifier: String(describing: ShowWorksPhotoCell.self))
    }
    
    private func willLoadingDataToCollectionView() {
        SystemManager.hideLoading()
        reloadData()
    }
    
    // MARK: Method
    func reflashData(_ type: DisplayCabinetType? = nil) {
        var displayCabinet: DisplayCabinetType = displayCab
        if let type = type {
            displayCabinet = type
        }
        if self.worksType == .Store {
            switch displayCabinet {
            case .Photo:
                currentPage_photo = 1
                apiGetPlacesPhotoList()
            case .Album:
                currentPage_album = 1
                apiGetPlacesAlbumsList()
            case .Video:
                currentPage_video = 1
                apiGetPlacesVideoList()
            }
        } else {
            switch displayCabinet {
            case .Photo:
                currentPage_photo = 1
                apiGetPhotoList()
            case .Album:
                currentPage_album = 1
                apiGetAlbumsList()
            case .Video:
                currentPage_video = 1
                apiGetVideoList()
            }
        }
    }
    
    func cleanData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [ weak self] in
            for cell in self?.visibleCells ?? [] {
                (cell as! ShowWorksPhotoCell).didEndDisplaying()
            }
            let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: -99, tempComment: nil, imageLocalIdentifier: nil)
            self?.photoArray = [model]
            self?.albumArray = [model]
            self?.videoArray = [model]
            self?.currentPage_photo = 1
            self?.currentPage_album = 1
            self?.currentPage_video = 1
            self?.reloadData()
        }
    }
    
    func setupCollectionViewWith(itemWidth: CGFloat, worksType: ShowWorksType, delegate: ShowWorksPhotoCollectionViewDelegate, baseVC: BaseViewController?) {
        self.worksType = worksType
        self.CVdelegate = delegate
        self.itemWidth = itemWidth
        self.targetVC = baseVC
    }
    
    func changeEditingModelWith(editMode: EditModeStatus) {
        self.editMode = editMode
        for cell in self.visibleCells {
            (cell as! ShowWorksPhotoCell).changeButtonHiddenStatus(editMode == .Normal)
        }
    }
    
    func updateDesignerCollectionViewData(type: DisplayCabinetType = .Photo, forceReload: Bool = false) {
        if SystemManager.isNetworkReachable() {
            for cell in self.visibleCells {
                (cell as! ShowWorksPhotoCell).didEndDisplaying()
            }
            SystemManager.showLoading()
            displayCab = type
            if self.worksType == .Store {
                switch type {
                case .Photo:
                    if forceReload || photoArray.count <= 1 {
                        apiGetPlacesPhotoList()
                    } else {
                        willLoadingDataToCollectionView()
                    }
                case .Album:
                    if forceReload || albumArray.count <= 1 {
                        apiGetPlacesAlbumsList()
                    } else {
                        willLoadingDataToCollectionView()
                    }
                case .Video:
                    if forceReload || videoArray.count <= 1 {
                        apiGetPlacesVideoList()
                    } else {
                        willLoadingDataToCollectionView()
                    }
                }
            } else {
                switch type {
                case .Photo:
                    if forceReload || photoArray.count <= 1 {
                        apiGetPhotoList()
                    } else {
                        willLoadingDataToCollectionView()
                    }
                case .Album:
                    if forceReload || albumArray.count <= 1 {
                        apiGetAlbumsList()
                    } else {
                        willLoadingDataToCollectionView()
                    }
                case .Video:
                    if forceReload || videoArray.count <= 1 {
                        apiGetVideoList()
                    } else {
                        willLoadingDataToCollectionView()
                    }
                }
            }
        }
    }
    
    private func fullfillArray(array: [MediaModel]) -> [MediaModel] {
        let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: -99, tempComment: nil, imageLocalIdentifier: nil)
        var apiArray = array;
        apiArray.insert(model, at: 0)
        return apiArray
    }
    
    // MARK: API - Designer
    // W001
    private func apiGetPhotoList() {
        WorksManager.apiGetWorksPhotoList(photoType: worksType.rawValue, page: currentPage_photo, success: { [weak self] (model) in
            guard let weakSelf = self else { return }
            if model?.syscode == 200 {
                if let meta = model?.data?.meta {
                    weakSelf.totalPage_photo = meta.totalPage
                }
                if weakSelf.currentPage_photo == 1 {
                    weakSelf.photoArray.removeAll()
                    if let modelArray = model?.data?.photoList {
                        weakSelf.photoArray = weakSelf.fullfillArray(array: modelArray)
                    } else {
                        weakSelf.photoArray = weakSelf.fullfillArray(array: weakSelf.photoArray)
                    }
                } else {
                    if let modelArray = model?.data?.photoList {
                        weakSelf.photoArray.append(contentsOf: modelArray)
                    }
                }
                weakSelf.willLoadingDataToCollectionView()
            } else {
                weakSelf.targetVC?.endLoadingWith(model: model)
            }
            
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
    // W002
    private func apiGetVideoList() {
        
        WorksManager.apiGetWorksVideoList(photoType: worksType.rawValue, page: currentPage_video, success: { [weak self] (model) in
            guard let weakSelf = self else { return }
            if model?.syscode == 200 {
                if let meta = model?.data?.meta {
                    weakSelf.totalPage_video = meta.totalPage
                }
                if weakSelf.currentPage_video == 1 {
                    weakSelf.videoArray.removeAll()
                    if let modelArray = model?.data?.videoList {
                        weakSelf.videoArray = weakSelf.fullfillArray(array: modelArray)
                    } else {
                        weakSelf.videoArray = weakSelf.fullfillArray(array: weakSelf.videoArray)
                    }
                } else {
                    if let modelArray = model?.data?.photoList {
                        weakSelf.videoArray.append(contentsOf: modelArray)
                    }
                }
                weakSelf.willLoadingDataToCollectionView()
            } else {
                weakSelf.targetVC?.endLoadingWith(model: model)
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
    // W003
    private func apiGetAlbumsList() {
        WorksManager.apiGetWorksAlbumsList(photoType: worksType.rawValue, page: currentPage_album, success: { [weak self] (model) in
            guard let weakSelf = self else { return }
            if model?.syscode == 200 {
                if let meta = model?.data?.meta {
                    weakSelf.totalPage_album = meta.totalPage
                }
                if weakSelf.currentPage_album == 1 {
                    weakSelf.albumArray.removeAll()
                    if let modelArray = model?.data?.albumsList {
                        weakSelf.albumArray = weakSelf.fullfillArray(array: modelArray)
                    } else {
                        weakSelf.albumArray = weakSelf.fullfillArray(array: weakSelf.albumArray)
                    }
                } else {
                    if let modelArray = model?.data?.photoList {
                        weakSelf.albumArray.append(contentsOf: modelArray)
                    }
                }
                weakSelf.willLoadingDataToCollectionView()
            } else {
                weakSelf.targetVC?.endLoadingWith(model: model)
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
    // MARK: API - Store
    // P001
    private func apiGetPlacesPhotoList() {
        PlacesPhotoManager.apiGetPlacesPhotoList(page: currentPage_photo, success: { [weak self] (model) in
            guard let weakSelf = self else { return }
            if model?.syscode == 200 {
                if let meta = model?.data?.meta {
                    weakSelf.totalPage_photo = meta.totalPage
                }
                if weakSelf.currentPage_photo == 1 {
                    weakSelf.photoArray.removeAll()
                    if let modelArray = model?.data?.photoList {
                        weakSelf.photoArray = weakSelf.fullfillArray(array: modelArray)
                    } else {
                        weakSelf.photoArray = weakSelf.fullfillArray(array: weakSelf.photoArray)
                    }
                } else {
                    if let modelArray = model?.data?.photoList {
                        weakSelf.photoArray.append(contentsOf: modelArray)
                    }
                }
                weakSelf.willLoadingDataToCollectionView()
            } else {
                weakSelf.targetVC?.endLoadingWith(model: model)
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
    // P002
    private func apiGetPlacesVideoList() {
        PlacesPhotoManager.apiGetPlacesVideoList(page: currentPage_video, success: { [weak self] (model) in
            guard let weakSelf = self else { return }
            if model?.syscode == 200 {
                if let meta = model?.data?.meta {
                    weakSelf.totalPage_video = meta.totalPage
                }
                if weakSelf.currentPage_video == 1 {
                    weakSelf.videoArray.removeAll()
                    if let modelArray = model?.data?.videoList {
                        weakSelf.videoArray = weakSelf.fullfillArray(array: modelArray)
                    } else {
                        weakSelf.videoArray = weakSelf.fullfillArray(array: weakSelf.videoArray)
                    }
                } else {
                    if let modelArray = model?.data?.photoList {
                        weakSelf.videoArray.append(contentsOf: modelArray)
                    }
                }
                weakSelf.willLoadingDataToCollectionView()
            } else {
                weakSelf.targetVC?.endLoadingWith(model: model)
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
    // P003
    private func apiGetPlacesAlbumsList() {
        PlacesPhotoManager.apiGetPlacesAlbumsList(page: currentPage_album, success: { [weak self] (model) in
            guard let weakSelf = self else { return }
            if model?.syscode == 200 {
                if let meta = model?.data?.meta {
                    weakSelf.totalPage_album = meta.totalPage
                }
                if weakSelf.currentPage_video == 1 {
                    weakSelf.albumArray.removeAll()
                    if let modelArray = model?.data?.albumsList {
                        weakSelf.albumArray = weakSelf.fullfillArray(array: modelArray)
                    } else {
                        weakSelf.albumArray = weakSelf.fullfillArray(array: weakSelf.albumArray)
                    }
                } else {
                    if let modelArray = model?.data?.photoList {
                        weakSelf.albumArray.append(contentsOf: modelArray)
                    }
                }
                weakSelf.willLoadingDataToCollectionView()
            } else {
                weakSelf.targetVC?.endLoadingWith(model: model)
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
}

extension ShowWorksPhotoCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch displayCab {
        case .Photo:
            return photoArray.count
        case .Album:
            return albumArray.count
        case .Video:
            return videoArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ShowWorksPhotoCell.self), for: indexPath) as! ShowWorksPhotoCell
        return cell
    }
}

extension ShowWorksPhotoCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode == .Editing {
            switch displayCab {
            case .Photo:
                photoArray[indexPath.item].selected = !photoArray[indexPath.item].selected!
                self.CVdelegate?.addImageToEditingList(photoArray[indexPath.item])
            case .Album:
                albumArray[indexPath.item].selected = !albumArray[indexPath.item].selected!
                self.CVdelegate?.addImageToEditingList(albumArray[indexPath.item])
            case .Video:
                videoArray[indexPath.item].selected = !videoArray[indexPath.item].selected!
                self.CVdelegate?.addImageToEditingList(videoArray[indexPath.item])
            }
            collectionView.reloadData()
        } else {
            if displayCab == .Album {
                if let dwaId = albumArray[indexPath.item].dwaId {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToAlbumDetailViewController"), object: nil, userInfo: ["dwaId": dwaId, "showType": worksType])
                }
                if let ppaId = albumArray[indexPath.item].ppaId {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToAlbumDetailViewController"), object: nil, userInfo: ["ppaId": ppaId, "showType": worksType])
                }
            } else if displayCab == .Photo {
                let photoModelArray = photoArray.filter{ $0.tempImgId != -99 }.map{ (model) -> PhotoDetailModel in
                    return PhotoDetailModel(url: model.photoUrl ?? "", des: model.photoDesc ?? "", dwpId: model.dwpId, pppId: model.pppId, dwvId: nil, ppvId: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToPhotoDetailViewController"), object: nil, userInfo: ["modelArray":photoModelArray, "index":indexPath.item - 1, "type": displayCab]) // index 0 為"+"按鈕
            } else if displayCab == .Video {
                let videoModelArray = videoArray.filter{ $0.tempImgId != -99 }.map{ (model) -> PhotoDetailModel in
                    return PhotoDetailModel(url: model.videoUrl ?? "", des: model.videoDesc ?? "", dwpId: nil, pppId: nil, dwvId: model.dwvId, ppvId: model.ppvId, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToPhotoDetailViewController"), object: nil, userInfo: ["modelArray":videoModelArray, "index":indexPath.item - 1, "type": displayCab]) // index 0 為"+"按鈕
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var dataArray = [MediaModel]()
        
        switch displayCab {
        case .Photo:
            dataArray = photoArray
            if indexPath.item == photoArray.count - 3 && currentPage_photo < totalPage_photo {
                currentPage_photo += 1
                updateDesignerCollectionViewData(type: .Photo, forceReload: true)
            }
        case .Album:
            dataArray = albumArray
            if indexPath.item == albumArray.count - 3 && currentPage_album < totalPage_album {
                currentPage_album += 1
                updateDesignerCollectionViewData(type: .Album, forceReload: true)
            }
        case .Video:
            dataArray = videoArray
            if indexPath.item == videoArray.count - 3 && currentPage_video < totalPage_video {
                currentPage_video += 1
                updateDesignerCollectionViewData(type: .Video, forceReload: true)
            }
        }
        if dataArray.count > 0, indexPath.item < dataArray.count {
            (cell as! ShowWorksPhotoCell).setupCellWith(model: dataArray[indexPath.item], type: displayCab, mode:editMode, indexPath: indexPath, target: self)
        }
    }
}

extension ShowWorksPhotoCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var customHeight = itemWidth
        if displayCab == .Album {
            customHeight += 24
        }
        return CGSize(width: itemWidth, height: customHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
    }
}

extension ShowWorksPhotoCollectionView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        switch displayCab {
        case .Photo:
            let urls = indexPaths.compactMap{
                URL(string: photoArray[$0.item].photoUrl ?? "")
            }
            ImagePrefetcher(urls: urls).start()
            break
        case .Album:
            let urls = indexPaths.compactMap{
                URL(string: albumArray[$0.item].coverUrl ?? "")
            }
            ImagePrefetcher(urls: urls).start()
            break
        case .Video:
            let urls = indexPaths.compactMap{
                URL(string: videoArray[$0.item].videoUrl ?? "")
            }
            ImagePrefetcher(urls: urls).start()
            break
        }
    }
}

extension ShowWorksPhotoCollectionView: ShowWorksPhotoCellDelegate {
    func addButtonPress() {
        PresentationTool.showPortfolioImagePickerWith(selectAssets: selectedAssets, target: self, disPlayType: displayCab)
    }
}

extension ShowWorksPhotoCollectionView: PortfolioImagePickerViewControllerDelegate {
    func didSelectAssets(assets: [MultipleAsset], displayType: DisplayCabinetType, uploadPortfolioType: UploadPortfolioType) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToEditingUploadingViewController"), object: nil, userInfo: ["assets":assets, "type":uploadPortfolioType, "photoType":worksType])
    }
    
    func didCancel() {}
}
