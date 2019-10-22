//
//  DesignerPortfolioViewController.swift
//  SalonWalker
//
//  Created by Daniel on 2018/9/14.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class DesignerPortfolioViewController: BaseViewController {

    @IBOutlet private weak var collectionView: DesignerPortfolioCollectionView!
    @IBOutlet private var displayCabinetButtons: [UIButton]!
    
    private var ouId = 0
    private var displayCabinetType: DisplayCabinetType = .Photo
    private var portfolioType: PortfolioType = .Personal
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    // MARK: Method
    func setupVCWith(portfolioType: PortfolioType, ouId: Int) {
        self.portfolioType = portfolioType
        self.ouId = ouId
    }
    
    func callAPI() {
        collectionView.callAPI()
    }
    
    func cleanData() {
        collectionView.cleanData()
    }
    
    private func initialize() {
        let itemWidth = ((screenWidth - 5 * 2) / 3) - 1
        collectionView.setupCollectionViewWith(ouId: ouId, itemWidth: itemWidth, displayCabinetType: displayCabinetType, portfolioType: portfolioType, targetViewController: self)
    }
    
    // MARK: Event Handler
    @IBAction private func displayCabinetTypeButtonPress(_ sender: UIButton) {
        displayCabinetButtons.forEach {
            $0.isSelected = ($0.tag == sender.tag)
            $0.backgroundColor = ($0.tag == sender.tag) ? color_1A1C69 : color_EEE9FE
        }
        displayCabinetType = [.Photo, .Album, .Video][sender.tag]
        collectionView.changeDisplayCabinetType(type: displayCabinetType)
    }
    
}
