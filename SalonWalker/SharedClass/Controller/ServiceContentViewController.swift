//
//  ServiceContentViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/5/17.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class ServiceContentViewController: BaseViewController {

    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var svgView: UIView!
    @IBOutlet private weak var serviceItemView: ServiceItemCollectionView!
    @IBOutlet private weak var hairTypeViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var photoCollectionView: UICollectionView!
    @IBOutlet private weak var photoViewHeight: NSLayoutConstraint!
    
    private var photoImgUrl = [String]()
    private var svcContentModel: SvcContentModel?
    
    private var photoCellWidth: CGFloat = (screenWidth - 20 * 2) / 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Method
    func setupVCWithModel(_ model: SvcContentModel) {
        self.svcContentModel = model
    }
    
    private func initialize() {
        if let model = svcContentModel {
            // 服務內容
            self.serviceItemView.setupCollectionViewWith(dataArray: model.svcCategory)
            
            // 理髮長度(髮型)
            if let hairType = model.hairStyle {
                if hairType.style > 0, hairType.style < 5 {
                    self.svgView.addSublayer(layers: SVGLayer.getSVGLayersWith(sideLength: 100, sliderPercentage: CGFloat(hairType.growth) / 100, hairStyle: HairStyle(rawValue: hairType.style) ?? .Bob, gender: (hairType.sex == "m") ? .Male : .Female, color: color_2F10A0))
                } else {
                    self.hairTypeViewHeight.constant = 0
                }
            } else {
                self.hairTypeViewHeight.constant = 0
            }
            
            // 範例照片
            if let photoImgUrl = model.photoImgUrl, photoImgUrl.count > 0 {
                self.photoImgUrl = photoImgUrl
                self.photoCollectionView.reloadData()
                self.photoViewHeight.constant = ceil(CGFloat(photoImgUrl.count) / 2) * photoCellWidth + CGFloat(20 + 15 + 10 * 2)
            } else {
                self.photoViewHeight.constant = 0
            }
        }
    }
}

extension ServiceContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoImgUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layoutIfNeeded()
        cell.contentView.removeAllSubviews()
        if let url = svcContentModel?.photoImgUrl?[indexPath.item] {
            var frame = cell.contentView.bounds
            frame.size.width -= 10
            frame.size.height -= 10
            frame.origin.x += 5
            frame.origin.y += 5
            let imageView = UIImageView(frame: frame)
            imageView.setImage(with: url)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.contentView.addSubview(imageView)
        }
        return cell
    }
}

extension ServiceContentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: photoCellWidth, height: photoCellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShowImageViewController.self)) as! ShowImageViewController
        vc.setupVCWith(photoImgUrl: photoImgUrl, index: indexPath.row, naviTitle: LocalizedString("Lang_AC_039"))
        self.present(vc, animated: true, completion: nil)
    }
}

