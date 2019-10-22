//
//  RefPhotoCollectionView.swift
//  SalonWalker
//
//  Created by Daniel on 2018/8/10.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol RefPhotoCollectionViewDelegate: class {
    func updateSelectRefPhotoArray(_ refPhotoIdArray: [RefPhotoModel.RefPhoto])
}

class RefPhotoCollectionView: UICollectionView {

    private var itemWidth: CGFloat = 0.0
    private var refPhotoArray_f = [RefPhotoModel.RefPhoto]()
    private var refPhotoArray_m = [RefPhotoModel.RefPhoto]()
    private var selectRefPhotoArray = [RefPhotoModel.RefPhoto]()
    private var currentPage_f: Int = 1
    private var currentPage_m: Int = 1
    private var totalPage: Int = 1
    private var sex: String = "f"
    
    private weak var targetVC: BaseViewController?
    private weak var refPhotoCollectionViewDelegate: RefPhotoCollectionViewDelegate?
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
        
        registerCell()
    }
    
    // MARK: Method
    func setupCollectionViewWith(selectRefPhotoArray: [RefPhotoModel.RefPhoto], itemWidth: CGFloat, targetViewController: BaseViewController, delegate: RefPhotoCollectionViewDelegate) {
        self.selectRefPhotoArray = selectRefPhotoArray
        self.itemWidth = itemWidth
        self.targetVC = targetViewController
        self.refPhotoCollectionViewDelegate = delegate
        self.apiGetRefPhoto(showLoading: true)
    }
    
    func changeGender(sex: String) {
        if self.sex != sex {
            self.sex = sex
            
            if refPhotoArray_m.count == 0 {
                apiGetRefPhoto(showLoading: true)
            } else {
                self.reloadData()
            }
        }
    }
    
    private func registerCell() {
        self.register(UINib(nibName: "RefPhotoCell", bundle: nil), forCellWithReuseIdentifier: String(describing: RefPhotoCell.self))
    }
    
    // MARK: API
    private func apiGetRefPhoto(showLoading: Bool) {
        if SystemManager.isNetworkReachable() {
            if showLoading { self.targetVC?.showLoading()  }
            
            let page = (self.sex == "f") ? currentPage_f : currentPage_m
            ReservationManager.apiGetRefPhoto(sex: self.sex, page: page, success: { (model) in
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta.totalPage {
                        self.totalPage = totalPage
                    }
                    if let photo = model?.data?.refPhoto {
                        if self.sex == "f" {
                            if self.currentPage_f == 1 {
                                self.refPhotoArray_f = photo
                            } else {
                                self.refPhotoArray_f.append(contentsOf: photo)
                            }
                            for i in 0..<self.refPhotoArray_f.count {
                                self.refPhotoArray_f[i].select = self.selectRefPhotoArray.contains{ $0.rpId == self.refPhotoArray_f[i].rpId }
                            }
                        } else {
                            if self.currentPage_m == 1 {
                                self.refPhotoArray_m = photo
                            } else {
                                self.refPhotoArray_m.append(contentsOf: photo)
                            }
                            for i in 0..<self.refPhotoArray_m.count {
                                self.refPhotoArray_m[i].select = self.selectRefPhotoArray.contains{ $0.rpId == self.refPhotoArray_m[i].rpId }
                            }
                        }
                        self.reloadData()
                    }
                    self.targetVC?.hideLoading()
                } else {
                    self.targetVC?.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension RefPhotoCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.sex == "f") ? refPhotoArray_f.count : refPhotoArray_m.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RefPhotoCell.self), for: indexPath) as! RefPhotoCell
        let array = (self.sex == "f") ? refPhotoArray_f : refPhotoArray_m
        cell.setupCellWithModel(array[indexPath.item])
        return cell
    }
}

extension RefPhotoCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var array = (self.sex == "f") ? refPhotoArray_f : refPhotoArray_m
        if (!array[indexPath.item].select! && selectRefPhotoArray.count >= 4) {
            SystemManager.showErrorMessageBanner(title: LocalizedString("Lang_RV_010"), body: "")
            return
        }
        
        if self.sex == "f" {
            refPhotoArray_f[indexPath.item].select = !refPhotoArray_f[indexPath.item].select!
        } else {
            refPhotoArray_m[indexPath.item].select = !refPhotoArray_m[indexPath.item].select!
        }
        array[indexPath.item].select = !array[indexPath.item].select!
        if array[indexPath.item].select! {
            selectRefPhotoArray.append(array[indexPath.item])
        } else {
            selectRefPhotoArray = selectRefPhotoArray.filter{ $0.rpId != array[indexPath.item].rpId }
        }
        self.reloadData()
        self.refPhotoCollectionViewDelegate?.updateSelectRefPhotoArray(selectRefPhotoArray)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let array = (self.sex == "f") ? refPhotoArray_f : refPhotoArray_m
        let currentPage = (self.sex == "f") ? currentPage_f : currentPage_m
        if indexPath.item == array.count - 2 && currentPage < totalPage  {
            apiGetRefPhoto(showLoading: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
