//
//  TryCollectionViewController.swift
//  SalonWalker
//
//  Created by Skywind on 2018/3/29.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit

class TryCollectionViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weekPrice = 700
    var weekTitle = "時/平日,"
    var holidayPrice = 800
    var holidayTitle = "時/假日"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: --------------Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TryCollectionCell", for: indexPath) as! TryCollectionViewCell
        
        let attrWeekPrice = NSAttributedString(string: "\(weekPrice)",
            attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14.0)])
        let attrHolidayPrice = NSAttributedString(string: "\(holidayPrice)",
            attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14.0)])
        let attrWeekTitle = NSAttributedString(string: weekTitle,
            attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 10.0)])
        let attrHolidayTitle = NSAttributedString(string: holidayTitle,
            attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 10.0)])
        let combin = NSMutableAttributedString()
        combin.append(attrWeekPrice)
        combin.append(attrWeekTitle)
        combin.append(attrHolidayPrice)
        combin.append(attrHolidayTitle)
        cell.priceLabel.attributedText = combin
        cell.priceLabel.adjustsFontSizeToFitWidth = true
        cell.priceLabel.minimumScaleFactor = 0.5
        
        
        
        
        return cell
    }
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
