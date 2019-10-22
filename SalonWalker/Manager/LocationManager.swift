//
//  LocationManager.swift
//  SalonWalker
//
//  Created by Daniel on 2018/2/21.
//  Copyright © 2018年 skywind. All rights reserved.
//

import UIKit
import CoreLocation

private let ACCURACY_THRESHOLD = 200.0

protocol LocationManagerDelegate: class {
    func locationDidUpdateWithCoordinate(lat: Double, lng: Double)
    func didCancelAllowGPS()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: Property
    private static let sharedInstance = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var userLastLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(25.033493, 121.564101), altitude: 0.0, horizontalAccuracy: 2000.0, verticalAccuracy: 2000.0, timestamp: Date())
    private var authorizationStatus: CLAuthorizationStatus?
    private var alreadyUpdateLocation = false
    private var shouldShowAllowGPSAlert = true
    private weak var delegate: LocationManagerDelegate?
    
    // MARK: Life Cycle
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !alreadyUpdateLocation {
            guard let location = locations.last else { return }
            if location.horizontalAccuracy < ACCURACY_THRESHOLD || location.horizontalAccuracy < userLastLocation.horizontalAccuracy {
                
                userLastLocation = location
                
                DispatchQueue.main.async { [unowned self] in
                    self.stopUpdateLocation()
                }
                print("didUpdateLocations:\(LocationManager.sharedInstance.userLastLocation)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdateLocation()
            break
        case .denied:
            showAllowGPSAlert()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_GE_019"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
            break
        }
        authorizationStatus = status
    }
    
    // MARK: Methods
    static func updateLocation() {
        LocationManager.sharedInstance.checkAuthorizationStatus {
            LocationManager.sharedInstance.startUpdateLocation()
        }
    }
    
    static func getLocationWithTarget(_ target: LocationManagerDelegate?) {
        LocationManager.sharedInstance.delegate = target
        LocationManager.sharedInstance.checkAuthorizationStatus {
            LocationManager.sharedInstance.startUpdateLocation()
        }
    }
    
    static func userLastLocation() -> CLLocation {
        return LocationManager.sharedInstance.userLastLocation
    }
    
    static func getAuthorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    static func tranferAddressToCoordinat(address: String, success: @escaping (_ coordinate: CLLocationCoordinate2D) -> Void, failure: @escaping (_ error: Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placeMarkArray, error) in
            if error != nil {
                failure(error)
                return
            }
            if let location = placeMarkArray?.last?.location {
                success(location.coordinate)
            }
        }
    }
    
    private func checkAuthorizationStatus(success: actionClosure) {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                success()
            } else if CLLocationManager.authorizationStatus() == .denied {
                showAllowGPSAlert()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        } else {
            SystemManager.showAlertWith(alertTitle: LocalizedString("Lang_GE_020"), alertMessage: nil, buttonTitle: LocalizedString("Lang_GE_005"), handler: nil)
        }
    }
    
    private func startUpdateLocation() {
        SystemManager.showLoading()
        alreadyUpdateLocation = false
        locationManager.startUpdatingLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
            if !self.alreadyUpdateLocation {
                print("endUpdateLocation after 3 seconds: \(self.userLastLocation)")
                self.stopUpdateLocation()
            }
        }
    }
    
    private func stopUpdateLocation() {
        alreadyUpdateLocation = true
        SystemManager.hideLoading()
        locationManager.stopUpdatingLocation()
        delegate?.locationDidUpdateWithCoordinate(lat: userLastLocation.coordinate.latitude, lng: userLastLocation.coordinate.longitude)
        delegate = nil
    }
    
    private func showAllowGPSAlert() {
        if !shouldShowAllowGPSAlert {
            self.delegate?.locationDidUpdateWithCoordinate(lat: self.userLastLocation.coordinate.latitude, lng: self.userLastLocation.coordinate.longitude)
            return
        }
        
        shouldShowAllowGPSAlert = false
        SystemManager.showTwoButtonAlertWith(alertTitle: LocalizedString("Lang_GE_017"), alertMessage: nil, leftButtonTitle: LocalizedString("Lang_GE_060"), rightButtonTitle: LocalizedString("Lang_GE_018"), leftHandler: { [unowned self] in
            self.delegate?.didCancelAllowGPS()
            self.delegate = nil
        }, rightHandler: { [unowned self] in
            guard let url = URL(string: "\(UIApplication.openSettingsURLString)\(Bundle.main.bundleIdentifier ?? "")") else { return }
            UIApplication.shared.openURL(url)
            self.delegate?.locationDidUpdateWithCoordinate(lat: self.userLastLocation.coordinate.latitude, lng: self.userLastLocation.coordinate.longitude)
        })
    }
    
}
