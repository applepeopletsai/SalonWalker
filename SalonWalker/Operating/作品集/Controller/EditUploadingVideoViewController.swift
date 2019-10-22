//
//  EditUploadingVideoViewController.swift
//  SalonWalker
//
//  Created by Cooper on 2018/9/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

struct VideoDetailModel {
    var avURLAsset: AVURLAsset
    var fileSize: Float
    var localIdentifier: String
    var comment: String
}

class EditUploadingVideoViewController: BaseViewController {

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet private weak var navigationRightButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private let MaxUploadFileSize: Float = 50.0
    private var tempArray = [MultipleAsset]()
    private var videoArray = [VideoDetailModel]()
    private var showsWorksType: ShowWorksType = .Personal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVideoDetailFrom(inputs: tempArray)
        initialize()
    }
    
    private func initialize() {
        navigationRightButton.setTitle(LocalizedString("Lang_PF_005"), for: .normal)
        navigationTitleLabel.text = "\(LocalizedString("Lang_GE_058"))（\(videoArray.count)\(LocalizedString("Lang_RT_043"))）"
        tableView.reloadData()
    }
    
    func setupAllUploadingVideo(photoType: ShowWorksType, imageArray: [MultipleAsset]) {
        showsWorksType = photoType
        tempArray = imageArray
    }

    // MARK: Event Handler
    @IBAction func naviBackButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func uploadingVideos(_ sender: UIButton) {
        if videoArray.count > 0 {
            uploadAssets()
        }
    }
    
    // MARK: Method
    private func addVideoDetailFrom(inputs: [MultipleAsset]) {
        if inputs.count > 0 {
            self.showLoading()
            var images = [VideoDetailModel]()
            for input in inputs {
                input.fetchAVAsset { (asset, info) in
                    if let video = asset as? AVURLAsset, let size = asset?.calculateFileSize() {
                        let fileSize = size / 1000.0 / 1000.0
                        let data = VideoDetailModel(avURLAsset: video, fileSize: fileSize, localIdentifier: input.localIdentifier, comment: "")
                        images.append(data)
                        if images.count == inputs.count {
                            DispatchQueue.main.async {
                                self.hideLoading()
                                self.videoArray.append(contentsOf: images)
                                self.initialize()
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.hideLoading()
                            SystemManager.showWarningBanner(title: LocalizedString("Lang_GE_009"), body: "")
                        }
                    }
                }
            }
        }
    }
    
    private func setupDeleteAlert(action: @escaping actionClosure) {
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_PF_025"), alertMessage: LocalizedString("Lang_PF_011"), leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_056"), leftHandler: nil, rightHandler: action)
    }
    
    private func uploadAssets() {
        if SystemManager.isNetworkReachable() {
            var images = [AVURLAsset]()
            var comments = [String]()
            var videoSize: Float = 0.0
            for asset in videoArray {
                videoSize += asset.fileSize
                images.append(asset.avURLAsset)
                comments.append(asset.comment)
            }
            if videoSize >= MaxUploadFileSize {
                hideLoading()
                SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_PF_026"), body: "")
            } else {
                DispatchQueue.main.async {
                    if self.showsWorksType == .Store {
                        self.apiUploadPlacesVideo(uploadFile: images, videoDesc: comments)
                    } else {
                        self.apiUploadVideo(uploadFile: images, videoDesc: comments)
                    }
                }
            }
        }
    }
    
    // MARK: API - Designer
    // W010
    private func apiUploadVideo(uploadFile: [AVURLAsset], videoDesc: [String]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading(text: LocalizedString("Lang_PF_029"))
            WorksManager.apiUploadVideo(videoType: showsWorksType.rawValue, uploadFile: uploadFile, videoDesc: videoDesc, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
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
    
    // W016
    private func apiDelVideo(dwvId: Int) {
        showLoading()
        let ints = [dwvId]
        WorksManager.apiDelVideo(dwvId: ints, success: { [unowned self] (model) in
            if model?.syscode == 200 {
                self.hideLoading()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
                self.initialize()
            } else {
                self.endLoadingWith(model: model)
            }
        }) { (error) in
            SystemManager.showErrorAlert(error: error)
        }
    }
    
    // MARK: API - Store
    // P010
    private func apiUploadPlacesVideo(uploadFile: [AVURLAsset], videoDesc: [String]) {
        if SystemManager.isNetworkReachable() {
            self.showLoading(text: LocalizedString("Lang_PF_029"))
            PlacesPhotoManager.apiUploadVideo(uploadFile: uploadFile, videoDesc: videoDesc, success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    SystemManager.showSuccessBanner(title: LocalizedString("Lang_PF_005") + LocalizedString("Lang_GE_006"), body: "")
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
    
    // P016
    private func apiDelPlacesVideo(ppvId: Int) {
        if SystemManager.isNetworkReachable() {
            showLoading()
            PlacesPhotoManager.apiDelVideo(ppvId: [ppvId], success: { [unowned self] (model) in
                if model?.syscode == 200 {
                    self.hideLoading()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshPortfolioAPIs"), object: nil, userInfo: nil)
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

extension EditUploadingVideoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: EditUploadingMoreVideoCell = tableView.dequeueReusableCell(withIdentifier: "EditUploadingMoreVideoCell", for: indexPath) as! EditUploadingMoreVideoCell
            return cell
        } else {
            let cell: EditUploadingVideoCell = tableView.dequeueReusableCell(withIdentifier: "EditUploadingVideoCell", for: indexPath) as! EditUploadingVideoCell
            cell.setupEditingModelVideo(video: videoArray[indexPath.row - 1], indexPath: indexPath, delegate: self)
            return cell
        }
    }
}

extension EditUploadingVideoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            var images = [MultipleAsset]()
            for data in videoArray {
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [data.localIdentifier], options: nil)
                if let asset = assets.firstObject {
                    images.append(MultipleAsset(originalAsset: asset))
                }
            }
            PresentationTool.showPortfolioImagePickerWith(selectAssets: images, target: self, disPlayType: .Video)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60.0
        } else {
            return screenWidth + 80
        }
    }
}

extension EditUploadingVideoViewController: EditUploadingVideoCellDelegate {
    func addUploadingVideoComment(comment: String, indexPath: IndexPath) {
        videoArray[indexPath.row - 1].comment = comment
    }
    
    func deleteUploadingVideo(indexPath: IndexPath) {
        setupDeleteAlert {
            DispatchQueue.main.async {
                self.videoArray.remove(at: indexPath.row - 1)
                self.initialize()
            }
        }
    }
}

extension EditUploadingVideoViewController: PortfolioImagePickerViewControllerDelegate {
    
    func didSelectAssets(assets: [MultipleAsset], displayType: DisplayCabinetType, uploadPortfolioType: UploadPortfolioType) {
        
        videoArray = videoArray.filter{ photo in
            assets.contains{ (model) -> Bool in
                return photo.localIdentifier == model.localIdentifier
            }
        }
        
        var shouldAddAssets = [MultipleAsset]()
        if videoArray.count == 0 {
            shouldAddAssets = assets
        } else {
            // 篩選：新選取的照片
            let sameImageIndex = assets.enumerated().filter { asset in
                videoArray.contains { model -> Bool in
                    return asset.element.localIdentifier == model.localIdentifier
                }
                }.map{ $0.offset }
            
            shouldAddAssets = assets.enumerated().filter{ !sameImageIndex.contains($0.offset) }.map{ $0.element }
        }
        
        self.addVideoDetailFrom(inputs: shouldAddAssets)
    }
    
    func didCancel() {}
}
