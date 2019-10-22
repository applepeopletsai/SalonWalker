//
//  NearByCollectionViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/9.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

protocol NearByCollectionViewControllerDelegate: class {
    func collectionViewDidScroll(_ collectionView: UICollectionView)
    func collectionViewWillDispalyCellAt(_ indexPath: IndexPath)
    func changeFavStatusAt(_ indexPath: IndexPath)
}

class NearByCollectionViewController: BaseViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let verticalSectionInset: CGFloat = 5
    private let horizontalSectionInset: CGFloat = 15
    private var designerListArray: [DesignerListModel] = []
    
    weak var delegate: NearByCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func reloadData(_ designerListArray: [DesignerListModel]) {
        self.designerListArray = designerListArray
        self.collectionView.reloadData()
    }
    
    func scrollToIndexPath(_ indexPath: IndexPath) {
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: API
    private func apiEditFavDesignerListAt(_ indexPath: IndexPath) {
        if SystemManager.isNetworkReachable() {
            
            self.showLoading()
            let ouId = self.designerListArray[indexPath.row].ouId
            let act = (self.designerListArray[indexPath.row].isFav) ? "del" : "add"
            let cell = self.collectionView.cellForItem(at: indexPath) as! NearByCollectionViewCell
            HomeManager.apiEditFavDesignerList(ouId: ouId, act: act, success: { (model) in
                
                if model?.syscode == 200 {
                    self.designerListArray[indexPath.row].isFav = !self.designerListArray[indexPath.row].isFav
                    cell.changeViewAnimation(isFav: self.designerListArray[indexPath.row].isFav)
                    self.delegate?.changeFavStatusAt(indexPath)
                    self.hideLoading()
                } else {
                    self.endLoadingWith(model: model)
                }
            }, failure: { (error) in
                SystemManager.showErrorAlert(error: error)
            })
        }
    }
}

extension NearByCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.designerListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: NearByCollectionViewCell.self), for: indexPath) as! NearByCollectionViewCell
        cell.layoutIfNeeded()
        cell.setupCellWith(model: self.designerListArray[indexPath.row], indexPath: indexPath, delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - horizontalSectionInset * 2, height: collectionView.bounds.size.height - verticalSectionInset * 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return horizontalSectionInset * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: horizontalSectionInset, bottom: verticalSectionInset, right: horizontalSectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.delegate?.collectionViewWillDispalyCellAt(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: kStory_DesignerDetail, bundle: nil).instantiateViewController(withIdentifier: String(describing: DesignerDetailViewController.self)) as! DesignerDetailViewController
        vc.setupVCWith(dId: designerListArray[indexPath.row].dId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.collectionViewDidScroll(collectionView)
    }
}

extension NearByCollectionViewController: NearByCollectionViewCellDelegate {
    
    func reservationButtonPressAt(_ indexPath: IndexPath) {
        let m = designerListArray[indexPath.row]
        let model = DesignerDetailModel(ouId: m.ouId, dId: m.dId, isRes: m.isRes, isTop: m.isTop, isFav: m.isFav, nickName: m.nickName, cityName: m.cityName ?? "", areaName: m.areaName ?? "", experience: m.experience, position: "", characterization: "", langName: m.langName ?? "", evaluationAve: m.evaluationAve, evaluationTotal: m.evaluationTotal, favTotal: 0, headerImgUrl: m.headerImgUrl, licenseImg: nil, coverImg: [], cautionTotal: 0, missTotal: 0, svcPlace: nil, paymentType: nil, svcCategory: nil, works: nil, customer: nil, openHour: nil)
        let vc = UIStoryboard(name: kStory_ReserveDesigner, bundle: nil).instantiateViewController(withIdentifier: String(describing:ReserveDesignerViewController.self)) as! ReserveDesignerViewController
        vc.setupVCWith(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func favoriteButtonPressAt(_ indexPath: IndexPath) {
        apiEditFavDesignerListAt(indexPath)
    }
}
