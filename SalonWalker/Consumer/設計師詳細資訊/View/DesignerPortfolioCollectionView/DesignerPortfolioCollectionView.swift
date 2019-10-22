//
//  DesignerPortfolioCollectionView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

enum PortfolioType: String {
    case Personal = "P", WorkShop = "C"
}

class DesignerPortfolioCollectionView: UICollectionView {

    private var photoArray = [MediaModel]()
    private var albumArray = [MediaModel]()
    private var videoArray = [MediaModel]()
    
    private var itemWidth: CGFloat = 0.0
    private var currentPage_photo: Int = 1
    private var currentPage_album: Int = 1
    private var currentPage_video: Int = 1
    private var totalPage_photo: Int = 1
    private var totalPage_album: Int = 1
    private var totalPage_video: Int = 1
    private var ouId = 0
    private var displayCabinetType: DisplayCabinetType = .Photo
    private var portfolioType: PortfolioType = .Personal
    private weak var targetVC: BaseViewController?
    
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
    
    // MARK: Method
    func setupCollectionViewWith(ouId: Int, itemWidth: CGFloat, displayCabinetType: DisplayCabinetType, portfolioType: PortfolioType, targetViewController: BaseViewController) {
        self.ouId = ouId
        self.itemWidth = itemWidth
        self.displayCabinetType = displayCabinetType
        self.portfolioType = portfolioType
        self.targetVC = targetViewController
    }
    
    func callAPI() {
        switch displayCabinetType {
        case .Photo:
            if photoArray.count == 0 {
                apiGetPhotoList()
            }
            break
        case .Album:
            if albumArray.count == 0 {
                apiGetAlbumsList()
            }
            break
        case .Video:
            if videoArray.count == 0 {
                apiGetVideoList()
            }
            break
        }
    }
    
    func changeDisplayCabinetType(type: DisplayCabinetType) {
        if self.displayCabinetType == type { return }
        self.displayCabinetType = type
        
        for cell in self.visibleCells {
            (cell as! ShowWorksPhotoCell).didEndDisplaying()
        }
        
        switch type {
        case .Photo:
            if self.photoArray.count == 0 {
                apiGetPhotoList()
            } else {
                self.reloadData()
            }
            break
        case .Album:
            if self.albumArray.count == 0 {
                apiGetAlbumsList()
            } else {
                self.reloadData()
            }
            break
        case .Video:
            if self.videoArray.count == 0 {
                apiGetVideoList()
            } else {
                self.reloadData()
            }
            break
        }
    }
    
    func cleanData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [ weak self] in
            for cell in self?.visibleCells ?? [] {
                (cell as! ShowWorksPhotoCell).didEndDisplaying()
            }
            self?.photoArray.removeAll()
            self?.albumArray.removeAll()
            self?.videoArray.removeAll()
            self?.currentPage_photo = 1
            self?.currentPage_album = 1
            self?.currentPage_video = 1
            self?.reloadData()
        }
    }
    
    // MARK: API
    // W001
    private func apiGetPhotoList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading() }
            
            WorksManager.apiGetWorksPhotoList(photoType: portfolioType.rawValue, page: currentPage_photo, pMax: 50, ouId: ouId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta?.totalPage {
                        self.totalPage_photo = totalPage
                    }
                    if let photoArray = model?.data?.photoList {
                        if self.currentPage_photo == 1 {
                            self.photoArray = photoArray
                        } else {
                            self.photoArray.append(contentsOf: photoArray)
                        }
                    } else {
                        self.photoArray = []
                    }
                    self.reloadData()
                    self.targetVC?.hideLoading()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W002
    private func apiGetVideoList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading() }
            
            WorksManager.apiGetWorksVideoList(photoType: portfolioType.rawValue, page: currentPage_photo, pMax: 50, ouId: ouId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta?.totalPage {
                        self.totalPage_video = totalPage
                    }
                    if let videoArray = model?.data?.videoList {
                        if self.currentPage_video == 1 {
                            self.videoArray = videoArray
                        } else {
                            self.videoArray.append(contentsOf: videoArray)
                        }
                    } else {
                        self.videoArray = []
                    }
                    self.reloadData()
                    self.targetVC?.hideLoading()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W003
    private func apiGetAlbumsList(showLoading: Bool = true) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading() }
            
            WorksManager.apiGetWorksAlbumsList(photoType: portfolioType.rawValue, page: currentPage_album, pMax: 50, ouId: ouId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta?.totalPage {
                        self.totalPage_album = totalPage
                    }
                    if let albumArray = model?.data?.albumsList {
                        if self.currentPage_album == 1 {
                            self.albumArray = albumArray
                        } else {
                            self.albumArray.append(contentsOf: albumArray)
                        }
                    } else {
                        self.albumArray = []
                    }
                    self.reloadData()
                    self.targetVC?.hideLoading()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension DesignerPortfolioCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch displayCabinetType {
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

extension DesignerPortfolioCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: PhotosDetailViewController.self)) as! PhotosDetailViewController
        switch displayCabinetType {
        case .Photo:
            let modelArray = photoArray.map{
                return PhotoDetailModel(url: $0.photoUrl ?? "", des: $0.photoDesc ?? "", dwpId: $0.dwpId, pppId: nil, dwvId: nil, ppvId: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil)
            }
            vc.setupVCWith(models: modelArray, index: indexPath.item, vcType: .ByConsumer, viewType: .Photo, date: nil)
            break
        case .Album:
            guard let dwaId = albumArray[indexPath.item].dwaId else { return }
            vc.setupVCWith(ouId: ouId, dwaId: dwaId)
            break
        case .Video:
            let modelArray = videoArray.map{
                return PhotoDetailModel(url: $0.videoUrl ?? "", des: $0.videoDesc ?? "", dwpId: nil, pppId: nil, dwvId: $0.dwvId, ppvId: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil)
            }
            vc.setupVCWith(models: modelArray, index: indexPath.item, vcType: .ByConsumer, viewType: .Video, date: nil)
            break
        }
        self.targetVC?.present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var dataArray = [MediaModel]()
  
        switch displayCabinetType {
        case .Photo:
            dataArray = photoArray
            if indexPath.item == photoArray.count - 3 && currentPage_photo < totalPage_photo {
                currentPage_photo += 1
                apiGetPhotoList(showLoading: false)
            }
            break
        case .Album:
            dataArray = albumArray
            if indexPath.item == albumArray.count - 3 && currentPage_album < totalPage_album {
                currentPage_album += 1
                apiGetAlbumsList(showLoading: false)
            }
            break
        case .Video:
            dataArray = videoArray
            if indexPath.item == videoArray.count - 3 && currentPage_video < totalPage_video {
                currentPage_video += 1
                apiGetVideoList(showLoading: false)
            }
            break
        }
        if dataArray.count > 0, indexPath.item < dataArray.count {
            (cell as! ShowWorksPhotoCell).setupCellWith(model: dataArray[indexPath.item], type: displayCabinetType)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ShowWorksPhotoCell).didEndDisplaying()
    }
}

extension DesignerPortfolioCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight = (displayCabinetType == .Album) ? itemWidth + 24 : itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

extension DesignerPortfolioCollectionView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        switch displayCabinetType {
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
        case .Video: break
        }
    }
}



