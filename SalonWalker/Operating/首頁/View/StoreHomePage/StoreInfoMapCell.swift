//
//  StoreInfoMapCell.swift
//  SalonWalker
//
//  Created by Daniel on 2018/4/20.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import GoogleMaps

class StoreInfoMapCell: UITableViewCell {

    @IBOutlet private weak var mapView: GMSMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMapView()
    }
    
    private func setupMapView() {
        let position = LocationManager.getlastLocation().coordinate
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude, longitude: position.longitude, zoom: 16)
        self.mapView.camera = camera
        self.mapView?.delegate = self
        self.mapView?.isMyLocationEnabled = false
        self.mapView?.settings.compassButton = false
        self.mapView?.settings.rotateGestures = false
    }
}

extension StoreInfoMapCell: GMSMapViewDelegate {
    
}
