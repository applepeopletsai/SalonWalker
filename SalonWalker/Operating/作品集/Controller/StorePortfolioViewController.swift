//
//  StorePortfolioViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/22.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class StorePortfolioViewController: BaseViewController {
    
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var editPhotoButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var topMenuView: TopMenuView!
    @IBOutlet private weak var topMenuViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet private weak var contentScrollView: UIScrollView!
    
    private var pageMenuControl = ScrollPageMenuControl()
    private var editMode: EditModeStatus = .Normal
    private var showWork: ShowWorksType = .Personal
    private var editListArray: [MediaModel] = [MediaModel]()
    
    private let personalPortfolioVC = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: WorksPortfolioViewController.self)) as! WorksPortfolioViewController
    private let worksPortfolioVC = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: WorksPortfolioViewController.self)) as! WorksPortfolioViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        if UserManager.sharedInstance.userIdentity == .designer {
            designerInitialization()
        } else {
            storeInitialization()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageMenuControl.resizeFrame()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Initialize
    private func setupObserver() {
        let operationQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GoToEditingUploadingViewController"), object: nil, queue: operationQueue) { (notif) in
            if let assets = notif.userInfo?["assets"] as? [MultipleAsset], let rawType = notif.userInfo?["type"] as? UploadPortfolioType, let photoType = notif.userInfo?["photoType"] as? ShowWorksType {
                if rawType == .Photo {
                    let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditUploadingPhotoViewController.self)) as! EditUploadingPhotoViewController
                    self.showLoading()
                    var array = [MediaModel]()
                    for asset in assets {
                        let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: nil, tempComment: nil, imageLocalIdentifier: asset.localIdentifier)
                        array.append(model)
                        if array.count == assets.count {
                            vc.setupPhotoList(photoType: photoType, photoArray: array, albumName: nil, albumDescr: nil)
                            self.hideLoading()
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                } else if rawType == .Album {
                    let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditUploadingAlbumViewController.self)) as! EditUploadingAlbumViewController
                    var array = [MediaModel]()
                    for asset in assets {
                        let model = MediaModel(meta: nil, dwpId: nil, pppId: nil, photoUrl: nil, photoDesc: nil, dwvId: nil, ppvId: nil, videoImage: nil, videoUrl: nil, videoDesc: nil, dwaId: nil, ppaId: nil, dwapId: nil, ppapId: nil, name: nil, coverUrl: nil, albumsDesc: nil, createDate: nil, isCover: nil, albumsPhoto: nil, selected: nil, imgUrl: nil, tempImgId: nil, tempComment: nil, imageLocalIdentifier: asset.localIdentifier)
                        array.append(model)
                        if array.count == assets.count {
                            vc.setupEditUploadingToAlbum(photoType: photoType, imagesArray: array)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                } else if rawType == .Video {
                    let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: EditUploadingVideoViewController.self)) as! EditUploadingVideoViewController
                    vc.setupAllUploadingVideo(photoType: photoType, imageArray: assets)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GoToPhotoDetailViewController"), object: nil, queue: operationQueue) { (notif) in
            if let modelArray = notif.userInfo?["modelArray"] as? [PhotoDetailModel], let index = notif.userInfo?["index"] as? Int, let type = notif.userInfo?["type"] as? DisplayCabinetType {
                let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: PhotosDetailViewController.self)) as! PhotosDetailViewController
                vc.setupVCWith(models: modelArray, index: index, vcType: .ByOperating, viewType: type, date: nil, target: self)
                self.navigationController?.present(vc, animated: true)
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "GoToAlbumDetailViewController"), object: nil, queue: operationQueue) { (notif) in
            if let showType = notif.userInfo!["showType"] {
                let vc = UIStoryboard(name: kStory_StorePortfolio, bundle: nil).instantiateViewController(withIdentifier: String(describing: AlbumDetailViewController.self)) as! AlbumDetailViewController
                if let dwaId = notif.userInfo!["dwaId"] {
                    vc.setupAlbumDetailFrom(workType: showType as! ShowWorksType, albumId: dwaId as! Int)
                }
                if let ppaId = notif.userInfo!["ppaId"] {
                    vc.setupAlbumDetailFrom(workType: showType as! ShowWorksType, albumId: ppaId as! Int)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func storeInitialization() {
        titleLabel.text = LocalizedString("Lang_PF_028")
        topMenuViewConstraintHeight.constant = 0
        personalPortfolioVC.setupPortfolio(type: .Store, delegate: self)
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: contentScrollView, titles: [LocalizedString("Lang_DD_009")], childVCs: [personalPortfolioVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    private func designerInitialization() {
        topMenuViewConstraintHeight.constant = 44
        personalPortfolioVC.setupPortfolio(type: .Personal, delegate: self)
        worksPortfolioVC.setupPortfolio(type: .WorkShop, delegate: self)
        pageMenuControl.setupPageViewWith(topView: topMenuView, scrollView: contentScrollView, titles: [LocalizedString("Lang_DD_009"),LocalizedString("Lang_DD_010")], childVCs: [personalPortfolioVC,worksPortfolioVC], baseVC: self, delegate: self, showBorder: true)
    }
    
    // MARK: Event Handler
    @IBAction func editModeChangeButtonPress(_ sender: UIButton) {
        switch editMode {
        case .Normal:
            editMode = .Editing
            sender.setTitle(LocalizedString("Lang_GE_060"), for: .normal)
        case .Editing:
            editMode = .Normal
            sender.setTitle(LocalizedString("Lang_GE_058"), for: .normal)
        }
        switch showWork {
        case .Personal, .Store:
            personalPortfolioVC.changeCollectionType(mode: editMode)
        case .WorkShop:
            worksPortfolioVC.changeCollectionType(mode: editMode)
        }
    }
    
    override func networkDidRecover() {
        callAPI()
    }
    
    private func callAPI() {
        if UserManager.sharedInstance.userIdentity == .designer {
            switch pageMenuControl.getCurrentPage() {
            case 0:
                worksPortfolioVC.cleanData()
                personalPortfolioVC.recoveryAPI()
            case 1:
                personalPortfolioVC.cleanData()
                worksPortfolioVC.recoveryAPI()
            default: break
            }
        } else {
             personalPortfolioVC.recoveryAPI()
        }
    }
}

extension StorePortfolioViewController: ScrollPageMenuControlDelegate {
    func didSelectetPageAt(_ pageIndex: Int) {
        pageMenuControl.changeCurrentPage(pageIndex)
        if UserManager.sharedInstance.userIdentity == .designer {
            showWork = [.Personal, .WorkShop][pageIndex]
        } else {
            showWork = .Store
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.callAPI()
        }
    }
}

extension StorePortfolioViewController: WorksPortfolioViewControllerDelegate {
    func navigationRightBarButtonTitleChangeTo(text: String) {
        editPhotoButton.setTitle(text, for: .normal)
    }
}
