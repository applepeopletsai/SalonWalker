//
//  FashionTrendViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/3/23.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class FashionTrendViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var refreshControl_ = UIRefreshControl()
    private var fashionSelectedArticleModel: FashionSelectedArticleModel?
    private var articleArray: [ArticleModel] = []
    private var bottomInset: CGFloat = 10
    private var tableViewCellHeight: CGFloat = screenHeight / 667 * 190
    
    private let dispatchGroup = DispatchGroup()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addMaskView()
        setupFashionTrendTableView()
        setupScrollView()
    }
    
    // MARK: Method
    func callAPI(refresh: Bool = false) {
        if SystemManager.isNetworkReachable() {
            if self.fashionSelectedArticleModel == nil || refresh || self.refreshControl_.isRefreshing {
                self.showLoading()
                dispatchGroup.enter()
                apiFashionSelectedArticles()
            }
            
            if self.articleArray.count == 0 || refresh || self.refreshControl_.isRefreshing {
                self.showLoading()
                dispatchGroup.enter()
                apiFashionArticles()
            }
            
            dispatchGroup.notify(queue: .main, execute: { [unowned self] in
                self.hideLoading()
                self.removeMaskView()
                self.refreshControl_.endRefreshing()
            })
        }
    }
    
    private func setupFashionTrendTableView() {
        tableViewHeight.constant = (tableViewCellHeight) * CGFloat(tableView.numberOfRows(inSection: 0))
    }
    
    private func setupScrollView() {
        scrollView.contentSize = CGSize(width: screenWidth , height: screenHeight / 3 * 2 + tableViewHeight.constant)
        self.refreshControl_.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.scrollView.addSubview(refreshControl_)
    }
    
    @objc func refreshData() {
        self.callAPI(refresh: true)
    }
    
    private func openWebViewVC(at indexPath: IndexPath) {
        var model: ArticleModel?
        switch indexPath.item {
        case 1:
            model = self.fashionSelectedArticleModel?.type1
            break
        case 2:
            model = self.fashionSelectedArticleModel?.type2
            break
        case 4:
            model = self.fashionSelectedArticleModel?.type3
            break
        default: break
        }
        guard let articleId = model?.seArticlesId else { return }
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WebViewController.self)) as! WebViewController
        vc.setupWebVCWith(seArticlesId: articleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openFashTrendDetailVC(with type: FashionTrendType) {
        var array = [ArticleModel]()
        if type == .tips {
            array = self.fashionSelectedArticleModel?.tips ?? []
        } else if type == .tools {
            array = self.fashionSelectedArticleModel?.tools ?? []
        }
        if array.count == 0 { return }
        let vc = UIStoryboard(name: kStory_HomePage, bundle: nil).instantiateViewController(withIdentifier: String(describing: FashionTrendDetailViewController.self)) as! FashionTrendDetailViewController
        vc.setupVCWith(articleArray: array, type: type)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: API
    private func apiFashionSelectedArticles() {
        HomeManager.apiFashionSelectedArticles(success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                if let articles = model?.data {
                    self.fashionSelectedArticleModel = articles
                    self.collectionView.reloadData()
                }
            } else {
                self.endLoadingWith(model: model)
            }
            self.dispatchGroup.leave()
            }, failure: { [unowned self] (error) in
                SystemManager.showErrorAlert(error: error)
                self.dispatchGroup.leave()
        })
    }
    
    private func apiFashionArticles() {
        HomeManager.apiFashionArticle(success: { [unowned self] (model) in
            
            if model?.syscode == 200 {
                if let articles = model?.data?.magazineArticles {
                    self.articleArray = articles
                    self.tableView.reloadData()
                }
            } else {
                self.endLoadingWith(model: model)
            }
            self.dispatchGroup.leave()
            }, failure: { [unowned self] (error) in
                SystemManager.showErrorAlert(error: error)
                self.dispatchGroup.leave()
        })
    }
}

extension FashionTrendViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var model: ArticleModel?
        var type: FashionTrendType = .general
        var identifier = ""
        switch indexPath.item {
        case 0,3:
            model = (indexPath.item == 0) ?  self.fashionSelectedArticleModel?.tips?.first : self.fashionSelectedArticleModel?.tools?.first
            type = (indexPath.item == 0) ? .tips : .tools
            identifier = "FashionTrendCollectionCell_Tip"
            break
        case 1,2,4:
            switch indexPath.item {
            case 1:
                model = self.fashionSelectedArticleModel?.type1
                break
            case 2:
                model = self.fashionSelectedArticleModel?.type2
                break
            case 4:
                model = self.fashionSelectedArticleModel?.type3
                break
            default: break
            }
            if model?.frame == "circle" {
                identifier = "FashionTrendCollectionCell_Circle"
            } else {
                identifier = "FashionTrendCollectionCell_Rectangle"
            }
        default: break
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FashionTrendCollectionCell
        cell.setupCellWith(model: model, fashionTrendType: type)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0,3:
            openFashTrendDetailVC(with: (indexPath.item == 0) ? .tips : .tools)
            break
        case 1,2,4:
            openWebViewVC(at: indexPath)
            break
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width - 0.0001
        let height = collectionView.frame.size.height
        let itemWdith: CGFloat = (indexPath.item == 1) ? width / 3 * 2 : width / 3 * 1
        let itemHeight: CGFloat = (height - bottomInset) / 2
        return CGSize(width: itemWdith, height: itemHeight)
    }
}

extension FashionTrendViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FashionTrendTableViewCell", for: indexPath) as! FashionTrendTableViewCell
        cell.setupWithCell(dataArray: articleArray, index: indexPath.row, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
}

extension FashionTrendViewController: FashionTrendTableViewCellDelegate {
    
    func didSelectItemWithIndex(_ index: Int) {
        let vc = UIStoryboard(name: "Shared", bundle: nil).instantiateViewController(withIdentifier: String(describing: WebViewController.self)) as! WebViewController
        vc.setupWebVCWith(maArticleId: articleArray[index].maArticleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func watchMoreButtonPressWithIndex(_ index: Int) {
        let vc = UIStoryboard(name: kStory_HomePage, bundle: nil).instantiateViewController(withIdentifier: "FashionTrendDetailViewController") as! FashionTrendDetailViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
