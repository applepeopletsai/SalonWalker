//
//  StoreCollectionViewController.swift
//  TabBar_practice
//
//  Created by Skywind on 2018/3/8.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import Cosmos
class StoreListViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    //MARK: ----------IBOutlet----------
    //collectionView 實體
    @IBOutlet weak var storeListCollectionView: UICollectionView!
    
    //MARK: ----------自己宣告的變數----------
    //評價人數
    var evaluationPeopleCount: Int  = 156
    //店家照片
    var storeImageArray = [UIImage]()
    //店名
    var storeNameArray = ["魔髮部屋．忠孝店",
                          "魔髮部屋．市府店",
                          "魔髮部屋．新竹店",
                          "魔髮部屋．台中店",
                          "魔髮部屋．台南店",
                          "魔髮部屋．高雄店"]
    //地址
    var storeAreaArray = ["台北市．信義區",
                          "台北市．中山區",
                          "台北市．大安區",
                          "台北市．松山區",
                          "新竹市．東區",
                          "新竹縣．新埔鄉"]
    //平日_剪髮價格
    var weekdayPrice: Int = 700
    //假日_剪髮價格
    var holidayPrice: Int = 800
    //平日_剪髮標題
    //    var weekdayTitle: String = LocalizedString("Hour/Weekday,")
    var weekdayTitle : String = "時/平日,"
    //假日_剪髮標題
    //    var holidayTitle: String = LocalizedString("Hour/Holiday")
    var holidayTitle : String = "時/假日"
    //cell 格式
    let minimunLineSpacing: CGFloat = 10
    let minimunInterItemSpacing: CGFloat = 10
    let cellSectionTop : CGFloat = 14
    let cellSectionLeft : CGFloat = 14
    let cellSectionBottom : CGFloat = 14
    let cellSectionRight : CGFloat = 14
    
    //MARK: ----------Life Cycle----------
    override func viewDidLoad() {
        super.viewDidLoad()
        storeListCollectionView.delegate = self
        storeListCollectionView.dataSource = self
        //        for i in 1...4{
        //            storeImageArray.append(UIImage(named: "salon_\(i).jpg")!)
        //        }
    }
    
    //MARK: ----------CollectionView Delegate----------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return storeNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreListCollectionViewCell", for: indexPath) as! StoreHomePageCollectionViewCell
        
        cell.setupWithCell(indexPath: indexPath, storeNameArray: storeNameArray, storeAreaArray: storeAreaArray, weekdayPrice: weekdayPrice, weekdayTitle: weekdayTitle, holidayPrice: holidayPrice, holidayTitle: holidayTitle, evaluationPeopleCount: evaluationPeopleCount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "StoreDetailViewController") as! StoreDetailViewController
        nextVC.PreviousVCValue(storeNameString: self.storeNameArray[indexPath.row], evaluationCount: self.evaluationPeopleCount, weekdayPrice: self.weekdayPrice, holidayPrice: self.holidayPrice)
        present(nextVC, animated: true, completion: nil)

//        let nextVC = UIStoryboard(name: kStory_StoreHomePage, bundle: nil).instantiateViewController(withIdentifier: "CourtImageViewController") as! CourtImageViewController
//        present(nextVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: cellSectionTop, left: cellSectionLeft, bottom: cellSectionBottom, right: cellSectionRight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.minimunLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return self.minimunInterItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //
        let cellWidth = (UIScreen.main.bounds.width - cellSectionLeft - cellSectionRight - self.minimunLineSpacing ) / 2
        
        let cellHeight = cellWidth * 256 / 170   //170 和 256 是 invision 給的比例
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}

