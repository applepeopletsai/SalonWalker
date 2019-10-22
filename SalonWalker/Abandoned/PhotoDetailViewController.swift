//
//  PhotoDetailViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/8/31.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import DKPhotoGallery

class PhotoDetailViewController: BaseViewController {
    
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var optionButton: UIButton!
    @IBOutlet private weak var createDateLabel: UILabel!
    @IBOutlet private weak var mainView: DKPlayerView!
    @IBOutlet private weak var mainImageView: UIImageView!
    @IBOutlet private weak var originDescription: UILabel!
    
    private var dwpId: Int?
    private var dwaId: Int?
    private var dwvId: Int?
    private var pppId: Int?
    private var ppaId: Int?
    private var ppvId: Int?
    private var dateString: String = ""
    private var photo: MediaModel?
    private var photoModel: AlbumPhotoModel?
    private var target: BaseViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        mainView.isHidden = true
        mainView.closeBlock = nil
        mainImageView.isHidden = true
        createDateLabel.text = dateString
        if let desc = photoModel?.photoDesc {
            originDescription.text = desc
        }
        if let imageUrl = photoModel?.photoUrl {
            mainImageView.isHidden = false
            mainImageView.setImage(with: imageUrl)
        }
        if let desc = photo?.photoDesc {
            originDescription.text = desc
        }
        if let desc = photo?.videoDesc {
            originDescription.text = desc
        }
        if let imageUrl = photo?.photoUrl {
            mainImageView.isHidden = false
            mainImageView.setImage(with: imageUrl)
        }
        if let videoUrl = photo?.videoUrl {
            mainView.isHidden = false
            let asset = AVAsset(url: URL(string: videoUrl)!)
            mainView.asset = asset
        }
    }
    
    // 從作品集首頁的相片、影片過來
    func setupPhotoDetailFromHome(dwpId: Int? = nil, dwvId: Int? = nil, pppId: Int? = nil, ppvId: Int? = nil, date: String, photo: MediaModel, target: BaseViewController) {
        self.dwpId = dwpId
        self.dwvId = dwvId
        self.pppId = pppId
        self.ppvId = ppvId
        dateString = date
        self.photo = photo
        self.target = target
    }
    
    // 從相簿詳細頁過來
    func setupPhotoDetailWith(dwaId: Int? = nil, ppaId: Int? = nil, date: String, photoModel: AlbumPhotoModel, target: AlbumDetailViewController) {
        self.dwaId = dwaId
        self.ppaId = ppaId
        dateString = date
        self.photoModel = photoModel
        self.target = target
    }
    
    // MARK: EventHandler
    @IBAction func dismissButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func optionButtonPress(_ sender: UIButton) {
        let deletePhotoAction = {
            if let dwaId = self.dwaId, let dwapId = self.photoModel?.dwapId {
                self.apiDelAlbumsPhoto(dwaId: dwaId, deleteId: dwapId)
            }
            if let dwpId = self.dwpId {
                self.apiDelPhoto(deleteId: dwpId)
            }
            if let dwvId = self.dwvId {
                self.apiDelVideo(deleteId: dwvId)
            }
            if let ppaId = self.ppaId, let ppapId = self.photoModel?.ppapId {
                self.apiDelPlacesAlbumsPhoto(ppaId: ppaId, deleteId: ppapId)
            }
            if let pppId = self.pppId {
                self.apiDelPlacesPhoto(deleteId: pppId)
            }
            if let ppvId = self.ppvId {
                self.apiDelPlacesVideo(deleteId: ppvId)
            }
        }
        let setFrontCoverAction = {
            if let dwaId = self.dwaId, let dwapId = self.photoModel?.dwapId {
                self.apiSetAlbumsCover(dwaId: dwaId, dwapId: dwapId)
            }
            if let ppaId = self.ppaId, let ppapId = self.photoModel?.ppapId {
                self.apiSetPlacesAlbumsCover(ppaId: ppaId, ppapId: ppapId)
            }
        }
        let editDescriptionAction = {
            // 進到下一頁
            let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditPhotoDescriptionViewController.self)) as! EditPhotoDescriptionViewController
            if let dwaId = self.dwaId, let dwapId = self.photoModel?.dwapId, let model = self.photoModel {
                vc.setupEditPhotoDescriptionWith(dwaId: dwaId, dwapId: dwapId, inputUrl: model.photoUrl, inputDesc: model.photoDesc!)
            }
            if let ppaId = self.ppaId, let ppapId = self.photoModel?.ppapId, let model = self.photoModel {
                vc.setupEditPhotoDescriptionWith(ppaId: ppaId, ppapId: ppapId, inputUrl: model.photoUrl, inputDesc: model.photoDesc!)
            }
            if let photo = self.photo {
                if let dwpId = self.dwpId {
                    vc.setupEditPhotoDescriptionWith(dwpId: dwpId, inputUrl: photo.photoUrl!, inputDesc: photo.photoDesc!)
                }
                if let dwvId = self.dwvId {
                    vc.setupEditPhotoDescriptionWith(dwvId: dwvId, inputUrl: photo.videoUrl!,inputDesc: photo.videoDesc!)
                }
                if let pppId = self.pppId {
                    vc.setupEditPhotoDescriptionWith(pppId: pppId, inputUrl: photo.photoUrl!, inputDesc: photo.photoDesc!)
                }
                if let ppvId = self.ppvId {
                    vc.setupEditPhotoDescriptionWith(ppvId: ppvId, inputUrl: photo.videoUrl!, inputDesc: photo.videoDesc!)
                }
            }
            self.dismiss(animated: true, completion: nil)
            self.target?.navigationController?.pushViewController(vc, animated: true)
        }
        let sharedPhotoAction = {
            // image to share
            if let photo = self.photo {
                if  let inputUrl = photo.photoUrl {
                    let imageView = UIImageView()
                    imageView.setImage(with: inputUrl)
                    if let image = imageView.image {
                        SystemManager.goingToShareInfoAbout(images: [image])
                    }
                }
                if let inputUrl = photo.videoUrl {
                    let asset = AVAsset(url: URL(string: inputUrl)!)
                    SystemManager.goingToShareInfoAbout(video: asset)
                }
            }
        }
        if dwaId != nil || ppaId != nil {
            SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_012"), LocalizedString("Lang_PF_023"), LocalizedString("Lang_PF_021"), LocalizedString("Lang_PF_016")], style: [.destructive, .default, .default, .default], actions: [deletePhotoAction, setFrontCoverAction, editDescriptionAction, sharedPhotoAction])
        } else if dwvId != nil || ppvId != nil {
            SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_014"), LocalizedString("Lang_PF_022"), LocalizedString("Lang_PF_018")], style: [.destructive, .default, .default], actions: [deletePhotoAction, editDescriptionAction, sharedPhotoAction])
        } else {
            SystemManager.showAlertSheetCustomActionWith(title: nil, message: nil, buttonTitles: [LocalizedString("Lang_PF_012"), LocalizedString("Lang_PF_021"), LocalizedString("Lang_PF_016")], style: [.destructive, .default, .default], actions: [deletePhotoAction, editDescriptionAction, sharedPhotoAction])
        }
    }
    
    // MARK: API - Designer
    // W008
    private func apiSetAlbumsCover(dwaId: Int, dwapId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            WorksManager.apiSetAlbumsCover(dwaId: dwaId, dwapId: dwapId, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: ["DisplayCabinetType": DisplayCabinetType.Photo])
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
            WorksManager.apiDelVideo(dwvId: [deleteId], success: { [unowned self] (model) in
                self.hideLoading()
                if model?.syscode == 200 {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: ["DisplayCabinetType": DisplayCabinetType.Video])
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.endLoadingWith(model: model)
                }
            }) { (error) in
                SystemManager.showErrorAlert(error: error)
            }
        }
    }
    
    // MARK: API - Store
    // P008
    private func apiSetPlacesAlbumsCover(ppaId: Int, ppapId: Int) {
        if SystemManager.isNetworkReachable() {
            self.showLoading()
            PlacesPhotoManager.apiSetAlbumsCover(ppaId: ppaId, ppapId: ppapId, success: { [weak self] (model) in
                if model?.syscode == 200 {
                    self?.hideLoading()
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
            PlacesPhotoManager.apiDelAlbumsPhoto(ppaId: ppaId, ppapId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: ["DisplayCabinetType": DisplayCabinetType.Album])
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
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: ["DisplayCabinetType": DisplayCabinetType.Photo])
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
            PlacesPhotoManager.apiDelVideo(ppvId: [deleteId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: ["DisplayCabinetType": DisplayCabinetType.Video])
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
