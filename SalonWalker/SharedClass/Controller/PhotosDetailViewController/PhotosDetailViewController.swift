//
//  PhotosDetailViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/13.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import DKPhotoGallery
import Kingfisher

enum PhotosDetailVCType {
    case ByConsumer         // 消費者查看設計師作品集
    case ByOperating        // 業者上傳
}

struct PhotoDetailModel {
    var url: String
    var des: String
    var dwpId: Int?
    var pppId: Int?
    var dwvId: Int?
    var ppvId: Int?
    var dwaId: Int?
    var ppaId: Int?
    var dwapId: Int?
    var ppapId: Int?
}

class PhotosDetailViewController: BaseViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var optionButton: IBInspectableButton!
    
    private var photoArray = [PhotoDetailModel]()
    private var currentIndex = 0
    private var vcType: PhotosDetailVCType = .ByConsumer
    private var viewType: DisplayCabinetType = .Photo
    private var date: String?
    private weak var target: BaseViewController?
    
    // 點擊相簿進來，需打W004或P004取得該相簿的照片
    private var ouId: Int?
    private var dwaId: Int?
    private var ppaId: Int?
    private var currentPage = 1
    private var totalPage = 1
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        addDismissGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        scrollToCurrentIndex()
    }
    
    // MARK: Method
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(models: [PhotoDetailModel], index: Int, vcType: PhotosDetailVCType, viewType: DisplayCabinetType, date: String? = nil, dwaId: Int? = nil, ppaId: Int? = nil, target: BaseViewController? = nil) {
        self.photoArray = models
        self.currentIndex = index
        self.vcType = vcType
        self.viewType = viewType
        self.date = date
        self.dwaId = dwaId
        self.ppaId = ppaId
        self.target = target
    }
    
    /// 點擊相簿看照片(消費者)
    func setupVCWith(ouId: Int?, dwaId: Int? = nil, ppaId: Int? = nil) {
        self.ouId = ouId
        self.dwaId = dwaId
        self.ppaId = ppaId
        self.viewType = .Album
        self.vcType = .ByConsumer
    }
    
    private func initialize() {
        dateLabel.text = date
        if vcType == .ByConsumer {
            optionButton.setTitle(nil, for: .normal)
            optionButton.setImage(UIImage(named: "ic_share"), for: .normal)
        } else {
            optionButton.setTitle("...", for: .normal)
            optionButton.setImage(nil, for: .normal)
        }
    }
    
    private func callAPI() {
        if viewType == .Album && photoArray.count == 0 {
            // 設計師
            apiGetWorksAlbumsPhotoList()
            // 場地
            apiGetPlacesAlbumsPhotoList()
        }
    }
    
    private func scrollToCurrentIndex() {
        if currentIndex != -1, photoArray.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: false)
            self.currentIndex = -1
        }
    }
    
    private func collectionViewCurrentItemIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)
    }
    
    private func shareWithModel(_ model: PhotoDetailModel) {
        if let url = URL(string: model.url) {
            if viewType == .Video {
                let asset = AVAsset(url: url)
                SystemManager.goingToShareInfoAbout(video: asset)
            } else {
                self.showLoading()
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { [weak self] (image, error, _, _) in
                    self?.hideLoading()
                    if error != nil {
                        SystemManager.showErrorMessageBanner(title: error?.localizedDescription ?? LocalizedString("Lang_GE_010"), body: "")
                    } else {
                        if let image = image {
                            SystemManager.goingToShareInfoAbout(images: [image])
                        } else {
                            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_010"), body: "")
                        }
                    }
                })
            }
        } else {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_010"), body: "")
        }
    }
    
    // MARK: EventHandler
    @IBAction private func dismissButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func optionButtonPress(_ sender: UIButton) {
        guard let indexPath = collectionViewCurrentItemIndexPath() else { return }
        let model = self.photoArray[indexPath.item]
        if vcType == .ByConsumer {
            self.shareWithModel(model)
        } else {
            #if SALONMAKER
            let deletePhotoAction = {
                if let dwaId = self.dwaId, let dwapId = model.dwapId {
                    self.apiDelAlbumsPhoto(dwaId: dwaId, deleteId: dwapId)
                }
                if let dwpId = model.dwpId {
                    self.apiDelPhoto(deleteId: dwpId)
                }
                if let dwvId = model.dwvId {
                    self.apiDelVideo(deleteId: dwvId)
                }
                if let ppaId = self.ppaId, let ppapId = model.ppapId {
                    self.apiDelPlacesAlbumsPhoto(ppaId: ppaId, deleteId: ppapId)
                }
                if let pppId = model.pppId {
                    self.apiDelPlacesPhoto(deleteId: pppId)
                }
                if let ppvId = model.ppvId {
                    self.apiDelPlacesVideo(deleteId: ppvId)
                }
            }
            let setFrontCoverAction = {
                if let dwaId = self.dwaId, let dwapId = model.dwapId {
                    self.apiSetAlbumsCover(dwaId: dwaId, dwapId: dwapId)
                }
                if let ppaId = self.ppaId, let ppapId = model.ppapId {
                    self.apiSetPlacesAlbumsCover(ppaId: ppaId, ppapId: ppapId)
                }
            }
            let editDescriptionAction = {
                // 進到下一頁
                let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditPhotoDescriptionViewController.self)) as! EditPhotoDescriptionViewController
                
                if let dwaId = self.dwaId, let dwapId = model.dwapId {
                    vc.setupEditPhotoDescriptionWith(dwaId: dwaId, dwapId: dwapId, inputUrl: model.url, inputDesc: model.des)
                }
                if let ppaId = self.ppaId, let ppapId = model.ppapId {
                    vc.setupEditPhotoDescriptionWith(ppaId: ppaId, ppapId: ppapId, inputUrl: model.url, inputDesc: model.des)
                }
                if let dwpId = model.dwpId {
                    vc.setupEditPhotoDescriptionWith(dwpId: dwpId, inputUrl: model.url, inputDesc: model.des)
                }
                if let dwvId = model.dwvId {
                    vc.setupEditPhotoDescriptionWith(dwvId: dwvId, inputUrl: model.url, inputDesc: model.des)
                }
                if let pppId = model.pppId {
                    vc.setupEditPhotoDescriptionWith(pppId: pppId, inputUrl: model.url, inputDesc: model.des)
                }
                if let ppvId = model.ppvId {
                    vc.setupEditPhotoDescriptionWith(ppvId: ppvId, inputUrl: model.url, inputDesc: model.des)
                }
                
                self.dismiss(animated: true, completion: {
                    self.target?.navigationController?.pushViewController(vc, animated: true)
                })
            }
            let sharedPhotoAction = {
                self.shareWithModel(model)
            }
            if dwaId != nil || ppaId != nil {
                SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_012"), LocalizedString("Lang_PF_023"), LocalizedString("Lang_PF_021"), LocalizedString("Lang_PF_016")], style: [.destructive, .default, .default, .default], actions: [deletePhotoAction, setFrontCoverAction, editDescriptionAction, sharedPhotoAction])
            } else if model.dwvId != nil || model.ppvId != nil {
                SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_014"), LocalizedString("Lang_PF_022"), LocalizedString("Lang_PF_018")], style: [.destructive, .default, .default], actions: [deletePhotoAction, editDescriptionAction, sharedPhotoAction])
            } else {
                SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_012"), LocalizedString("Lang_PF_021"), LocalizedString("Lang_PF_016")], style: [.destructive, .default, .default], actions: [deletePhotoAction, editDescriptionAction, sharedPhotoAction])
            }
            #endif
        }
    }
    
    // MARK: API
    // W004
    private func apiGetWorksAlbumsPhotoList(showLoading: Bool = true) {
        guard let dwaId = dwaId else { return }
        if SystemManager.isNetworkReachable() {
            if showLoading { self.showLoading() }
            
            WorksManager.apiGetWorksAlbumsPhotoList(dwaId: dwaId, page: currentPage, pMax: 50, ouId: ouId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.dateLabel.text = model?.data?.createDate
                    
                    if let totalPage = model?.data?.meta?.totalPage {
                        self.totalPage = totalPage
                    }
                    
                    if let albumsPhoto = model?.data?.albumsPhoto {
                        let photos = albumsPhoto.map{
                            return PhotoDetailModel(url: $0.photoUrl, des: $0.photoDesc ?? "", dwpId: nil, pppId: nil, dwvId: nil, ppvId: nil, dwaId: self.dwaId, ppaId: nil, dwapId: $0.dwapId, ppapId: nil)
                        }
                        if self.currentPage == 1 {
                            self.photoArray = photos
                        } else {
                            self.photoArray.append(contentsOf: photos)
                        }
                        self.collectionView.reloadData()
                    }
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W008
    private func apiSetAlbumsCover(dwaId: Int, dwapId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiSetAlbumsCover(dwaId: dwaId, dwapId: dwapId, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W014
    private func apiDelAlbumsPhoto(dwaId: Int, deleteId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            
            WorksManager.apiDelAlbumsPhoto(dwaId: dwaId, dwapId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W015
    private func apiDelPhoto(deleteId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiDelPhoto(dwpId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // W016
    private func apiDelVideo(deleteId: Int) {
        if SystemManager.isNetworkReachable() {
           self.hideLoading()
            WorksManager.apiDelVideo(dwvId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P004
    private func apiGetPlacesAlbumsPhotoList(showLoading: Bool = true) {
        guard let ppaId = ppaId else { return }
        if SystemManager.isNetworkReachable() {
            if showLoading { self.showLoading() }
            
            PlacesPhotoManager.apiGetPlacesAlbumsPhotoList(ppaId: ppaId, page: currentPage, ouId: ouId, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.dateLabel.text = model?.data?.createDate
                    
                    if let totalPage = model?.data?.meta?.totalPage {
                        self.totalPage = totalPage
                    }
                    if let albumPhoto = model?.data?.albumsPhoto {
                        let photos = albumPhoto.map{
                            return PhotoDetailModel(url: $0.photoUrl, des: $0.photoDesc ?? "", dwpId: nil, pppId: nil, dwvId: nil, ppvId: nil, dwaId: nil, ppaId: self.ppaId, dwapId: nil, ppapId: $0.ppapId)
                        }
                        
                        if self.currentPage == 1 {
                            self.photoArray = photos
                        } else {
                            self.photoArray.append(contentsOf: photos)
                        }
                    }
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P008
    private func apiSetPlacesAlbumsCover(ppaId: Int, ppapId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiSetAlbumsCover(ppaId: ppaId, ppapId: ppapId, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshAPIWP004Only"), object: nil, userInfo: nil)
                } else {
                    self?.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P014
    private func apiDelPlacesAlbumsPhoto(ppaId: Int, deleteId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiDelAlbumsPhoto(ppaId: ppaId, ppapId: [deleteId], success: { [unowned self] (model) in
                self.hideLoading()
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P015
    private func apiDelPlacesPhoto(deleteId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiDelPhoto(pppId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // P016
    private func apiDelPlacesVideo(deleteId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiDelVideo(ppvId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
}

extension PhotosDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotosDetailCell.self), for: indexPath) as! PhotosDetailCell
        return cell
    }
}

extension PhotosDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewType == .Album, currentPage < totalPage, indexPath.item == photoArray.count - 3 {
            currentPage += 1
            apiGetWorksAlbumsPhotoList(showLoading: false)
            apiGetPlacesAlbumsPhotoList(showLoading: false)
        }
        
        if photoArray.count > 0, indexPath.item < photoArray.count {
            (cell as! PhotosDetailCell).setupCellWith(model: photoArray[indexPath.item], type: viewType)
        }
    }
}

extension PhotosDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension PhotosDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap{
            URL(string: photoArray[$0.item].url)
        }
        ImagePrefetcher(urls: urls).start()
    }
}
