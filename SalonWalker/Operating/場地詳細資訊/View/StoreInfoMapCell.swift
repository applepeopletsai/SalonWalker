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

    @IBOutlet private weak var mapBaseView: UIView!
    private var mapView: GMSMapView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCellWithLocation(lat: Double?, lng: Double?) {
        if let lat = lat, let lng = lng {
            for view in self.mapBaseView.subviews {
                view.removeFromSuperview()
            }
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 16)
            self.mapView = GMSMapView.map(withFrame: self.mapBaseView.bounds, camera: camera)
            self.mapView?.camera = camera
            self.mapView?.isMyLocationEnabled = false
            self.mapView?.settings.compassButton = false
            self.mapView?.settings.rotateGestures = false
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
            marker.icon = UIImage(named: "ic_located")
            marker.map = self.mapView
            
            if let mapView = mapView {
                self.mapBaseView.addSubview(mapView)
            }
        }
    }
}
