//
//  UploadPhotoCollectionView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Photos

enum UploadPhotoType {
    // 五個頁面會使用這此CollectionView,分別為：註冊、設計師個人資料、場地資料、消費者預約設計師、意見回饋
    case Register, EditDesignerInfo, EditProviderInfo, ReserveDesigner, Feedback
}

protocol UploadPhotoCollectionViewDelegate: class {
    func updatePhotoData(with coverArray: [CoverImg])
    func deletePhoto(at index: Int)
}

class UploadPhotoCollectionView: UICollectionView {

    var isUploading = false // 給外面的viewcontroller判斷是否正在上傳中
    
    private var coverArray = [CoverImg]()
    private var uploadFailIndexArray = [Int]()
    private var itemWidth: CGFloat = 0.0
    private weak var targetVC: BaseViewController?
    private weak var uploadPhotoCollectionViewDelegate: UploadPhotoCollectionViewDelegate?
    
    private var maxCount = 0
    private var type: UploadPhotoType = .Register {
        didSet {
            switch type {
            case .ReserveDesigner:
                maxCount = 4
                break
            case .Feedback:
                maxCount = Int.max
                break
            case .Register, .EditDesignerInfo, .EditProviderInfo:
                maxCount = 5
                break
            }
        }
    }
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.registerCell()
    }
    
    // MARK: Method
    func setupCollectionViewWith(coverArray: [CoverImg], itemWidth: CGFloat, targetViewController: BaseViewController, delegate: UploadPhotoCollectionViewDelegate, type: UploadPhotoType) {
        self.coverArray = coverArray
        self.type = type
        self.uploadPhotoCollectionViewDelegate = delegate
        self.targetVC = targetViewController
        self.itemWidth = itemWidth
        self.checkImageCount()
        self.reloadData()
    }
    
    private func registerCell() {
        self.register(UINib(nibName: "UploadPhotoCell", bundle: nil), forCellWithReuseIdentifier: String(describing: UploadPhotoCell.self))
    }
    
    private func checkImageCount() {
        if coverArray.count == 0 {
            coverArray.insert(CoverImg(coverImgId: nil, imgUrl: nil, tempImgId: -99, act: nil, imageLocalIdentifier: nil), at: 0)
        } else {
            if let fitstCover = coverArray.first, fitstCover.tempImgId != -99, coverArray.count < maxCount {
                coverArray.insert(CoverImg(coverImgId: nil, imgUrl: nil, tempImgId: -99, act: nil, imageLocalIdentifier: nil), at: 0)
            }
        }
    }
    
    private func checkIsUploadingWithErrorBody(_ body: String) -> Bool {
        if isUploading {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_GE_008"), body: body)
            return true
        }
        return false
    }
    
    private func shouldRecallAPI(imageStringArray: [String?], index: Int,  coverArrayIndex: Int) {
        if index < imageStringArray.count - 1 {
            if self.type == .ReserveDesigner {
                self.apiOrderPhotoTempImage(imageStringArray: imageStringArray, index: index + 1, coverArrayIndex: coverArrayIndex + 1)
            } else if self.type == .Feedback {
                self.apiFeedbackTempImage(imageStringArray: imageStringArray, index: index + 1, coverArrayIndex: coverArrayIndex + 1)
            } else {
                self.apiTempImage(imageStringArray: imageStringArray, index: index + 1, coverArrayIndex: coverArrayIndex + 1)
            }
        } else {
            // 將上傳失敗的照片刪除
            if self.uploadFailIndexArray.count != 0 {
                self.coverArray = self.coverArray.enumerated().filter{ !self.uploadFailIndexArray.contains($0.offset) }.map{ $0.element }
                self.checkImageCount()
                
                self.reloadSections(IndexSet(integer: 0))
                self.uploadPhotoCollectionViewDelegate?.updatePhotoData(with: self.coverArray.filter{ $0.tempImgId != -99 })
                SystemManager.showWarningBanner(title: LocalizedString("Lang_GE_028"), body: LocalizedString("Lang_RT_026"))
            }
            self.isUploading = false
        }
    }
    
    private func handleUploadPhotoSuccess(model: BaseModel<TempImageModel>?, imageStringArray: [String?], index: Int, coverArrayIndex: Int) {
        if model?.syscode == 200 {
            if let url = model?.data?.imgUrl, let id = model?.data?.tempImgId {
                self.coverArray[coverArrayIndex].imgUrl = url
                self.coverArray[coverArrayIndex].tempImgId = id
            }
            self.reloadItems(at: [IndexPath(item: coverArrayIndex, section: 0)])
            self.uploadPhotoCollectionViewDelegate?.updatePhotoData(with: self.coverArray.filter{ $0.tempImgId != -99 })
        } else if model?.syscode == 501 {
            // 登出
            self.targetVC?.endLoadingWith(model: model)
            return
        } else {
            self.uploadFailIndexArray.append(coverArrayIndex)
        }
        
        self.shouldRecallAPI(imageStringArray: imageStringArray, index: index,  coverArrayIndex: coverArrayIndex)
    }
    
    private func handleUploadPhotoFail(error: Error? = nil) {
        SystemManager.showErrorAlert(error: error)
        self.coverArray.removeAll()
        self.uploadFailIndexArray.removeAll()
        self.checkImageCount()
        self.reloadSections(IndexSet(integer: 0))
        self.uploadPhotoCollectionViewDelegate?.updatePhotoData(with: self.coverArray.filter{ $0.tempImgId != -99 })
        self.isUploading = false
    }
    
    // MARK: API
    private func apiTempImage(imageStringArray: [String?], index: Int = 0, coverArrayIndex: Int = 0) {
        
        SystemManager.apiTempImage(imageType: "jpeg", image: imageStringArray[index], fbImgUrl: nil, googleImgUrl: nil, tempImgId: nil, mId: nil, ouId: nil, licenseImgId: nil, coverImgId: nil, act: "new", success: { [weak self] (model) in
            guard let strongSelf = self else { return }
            strongSelf.handleUploadPhotoSuccess(model: model, imageStringArray: imageStringArray, index: index, coverArrayIndex: coverArrayIndex)
            }, failure: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.handleUploadPhotoFail(error: error)
        })
    }
    
    private func apiOrderPhotoTempImage(imageStringArray: [String?], index: Int = 0, coverArrayIndex: Int = 0) {
        SystemManager.apiOrderPhotoTempImage(image: imageStringArray[index], rpId: nil, oepId: nil, act: "new", success: { [weak self] (model) in
            guard let strongSelf = self else { return }
            if let temp = model?.data?.first {
                let b = BaseModel(syscode: model?.syscode ?? 0, sysmsg: model?.sysmsg ?? "", data: temp)
                strongSelf.handleUploadPhotoSuccess(model: b, imageStringArray: imageStringArray, index: index, coverArrayIndex: coverArrayIndex)
            } else {
                strongSelf.handleUploadPhotoFail()
            }
            }, failure: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.handleUploadPhotoFail(error: error)
        })
    }
    
    private func apiFeedbackTempImage(imageStringArray: [String?], index: Int = 0, coverArrayIndex: Int = 0) {
        guard let imageString = imageStringArray[index] else { return }
        SystemManager.apiUploadFeedbackPhoto(image: imageString, success: { [weak self] (model) in
            guard let strongSelf = self else { return }
            strongSelf.handleUploadPhotoSuccess(model: model, imageStringArray: imageStringArray, index: index, coverArrayIndex: coverArrayIndex)
            }, failure: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.handleUploadPhotoFail(error: error)
        })
    }
}

extension UploadPhotoCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coverArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UploadPhotoCell.self), for: indexPath) as! UploadPhotoCell
        cell.setupCellWith(model: coverArray[indexPath.item], indexPath: indexPath, target: self)
        return cell
    }
}

extension UploadPhotoCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension UploadPhotoCollectionView: UploadPhotoCellDelegate {
    func addButtonPress() {
        if !checkIsUploadingWithErrorBody(LocalizedString("Lang_RT_024")) {
            
            var maxSelectCount = maxCount
            var selectAssets = [MultipleAsset]()
            maxSelectCount = maxCount - coverArray.filter({ $0.coverImgId != nil }).count
            coverArray.filter{ $0.imageLocalIdentifier != nil }.forEach {
                let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [$0.imageLocalIdentifier ?? ""], options: nil)
                if let phAsset = phAssets.firstObject {
                    let asset = MultipleAsset(originalAsset: phAsset)
                    selectAssets.append(asset)
                }
            }
            PresentationTool.showImagePickerWith(selectAssets: selectAssets, maxSelectCount: maxSelectCount, showVideo: false, target: self)
        }
    }
    
    func deleteImageWith(_ indexPath: IndexPath) {
        if !checkIsUploadingWithErrorBody(LocalizedString("Lang_RT_025")) {
            if let firstImg = coverArray.first {
                let index = (firstImg.tempImgId == -99) ? indexPath.item - 1 : indexPath.item
                uploadPhotoCollectionViewDelegate?.deletePhoto(at: index)
            }
            coverArray.remove(at: indexPath.item)
            checkImageCount()
            reloadData()
        }
    }
}

extension UploadPhotoCollectionView: MultipleSelectImageViewControllerDelegate {
    func didSelectAssets(_ assets: [MultipleAsset]) {
        
        if SystemManager.isNetworkReachable() {
            uploadFailIndexArray.removeAll()
            
            // 在新增模式中，使用者選完照片後會直接打API取得該照片ID，所以如果再次選到相同照片，則不須重打PAI
            // 在編輯模式中，使用者選取照片後，要保留原先就有的照片(cover.coverImgId != nil)
            coverArray = coverArray.filter{ cover in
                assets.contains{ (model) -> Bool in
                    if let coverLocalIdentifier = cover.imageLocalIdentifier {
                        return coverLocalIdentifier == model.localIdentifier
                    }
                    return cover.coverImgId != nil
                }
            }
            
            var newAssets = [MultipleAsset]()
            if coverArray.count == 0 {
                newAssets = assets
            } else {
                // 篩選：新選取的照片才需要打API
                let sameImageIndex = assets.enumerated().filter { asset in
                    coverArray.contains { model -> Bool in
                        return asset.element.localIdentifier == (model.imageLocalIdentifier ?? "")
                        }
                    }.map{ $0.offset }
                newAssets = assets.enumerated().filter{ !sameImageIndex.contains($0.offset) }.map{ $0.element }
            }
            
            let coverArrayIndex = (coverArray.count + newAssets.count == maxCount) ? coverArray.count : coverArray.count + 1
            var imageStringArray = [String?]()
            
            newAssets.forEach { (asset) in
                coverArray.append(CoverImg(coverImgId: nil, imgUrl: nil, tempImgId: -1, act: "add", imageLocalIdentifier: asset.localIdentifier))
                
                asset.fetchOriginalImage(completeBlock: { (image, info) in
                    imageStringArray.append(image?.transformToBase64String(format: .jpeg(0.5)))
                    
                    if imageStringArray.count == newAssets.count {
                        self.checkImageCount()
                        self.reloadData()
                        self.isUploading = true
                        
                        if self.type == .ReserveDesigner {
                            self.apiOrderPhotoTempImage(imageStringArray: imageStringArray, coverArrayIndex: coverArrayIndex)
                        } else if self.type == .Feedback {
                            self.apiFeedbackTempImage(imageStringArray: imageStringArray, coverArrayIndex: coverArrayIndex)
                        } else {
                            self.apiTempImage(imageStringArray: imageStringArray, coverArrayIndex: coverArrayIndex)
                        }
                    }
                })
            }
        }
    }
    
    func didCancel() {
        self.checkImageCount()
    }
}
