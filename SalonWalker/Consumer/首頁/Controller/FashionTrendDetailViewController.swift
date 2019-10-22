//
//  FashionTrendDetailViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/3/26.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class FashionTrendDetailViewController: BaseViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private var articleArray: [ArticleModel] = []
    private var type: FashionTrendType = .general
    
    private var currentPage: Int = 1
    private var totalPage: Int = 1
    
    private let minimumLineSpacing : CGFloat = 10
    private let minimumInterItemSpacing : CGFloat = 10
    private let sectionInset : CGFloat = 10
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callAPI()
    }
    
    // MARK: Methods
    override func networkDidRecover() {
        callAPI()
    }
    
    func setupVCWith(articleArray: [ArticleModel], type: FashionTrendType) {
        self.articleArray = articleArray
        self.type = type
    }
    
    private func callAPI() {
        if articleArray.count == 0 {
            apiFashionArticlesWithShowLoading(true)
        }
    }
    
    private func setupTitle() {
        switch type {
        case .general:
            self.titleLabel.text = LocalizedString("Lang_HM_019")
            break
        case .tips:
            self.titleLabel.text = "TIPS"
            break
        case .tools:
            self.titleLabel.text = "TOOLS"
            break
        }
    }
    
    //MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FashionTrendDetailCollectionViewCell", for: indexPath) as! FashionTrendDetailCollectionViewCell
        cell.setupCellWith(model: self.articleArray[indexPath.item])
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (screenWidth - sectionInset * 2 - minimumLineSpacing) / 2
        let cellHeight = cellWidth / 173 * 185  // 173 和 185 的比例是 invision 給的
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInterItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == articleArray.count - 3 && currentPage < totalPage {
            currentPage += 1
            apiFashionArticlesWithShowLoading(false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WebViewController.self)) as! WebViewController
        vc.setupWebVCWith(seArticlesId: articleArray[indexPath.item].seArticlesId, maArticleId: articleArray[indexPath.item].maArticleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API
    private func apiFashionArticlesWithShowLoading(_ showLoading: Bool) {
        if SystemManager.isNetworkReachable() {
           
            if showLoading { self.showLoading() }
            
            HomeManager.apiFashionArticle(page: currentPage, pMax: 30, success: { [unowned self] (model) in
                
                if model?.syscode == 200 {
                    if let totalPage = model?.data?.meta.totalPage {
                        self.totalPage = totalPage
                    }
                    
                    if let articles = model?.data?.magazineArticles {
                        if self.currentPage == 1 {
                            self.articleArray = articles
                        } else {
                            self.articleArray.append(contentsOf: articles)
                        }
                    }
                    self.collectionView.reloadData()
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
