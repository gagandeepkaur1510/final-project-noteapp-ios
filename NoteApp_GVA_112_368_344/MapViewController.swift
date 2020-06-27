//
//  MapViewController.swift
//  NoteApp_GVA_112_368_344
//
//  Created by Mac on 6/20/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

// protocol used for sending data back
protocol DataEnteredDelegate {
    func userDidEnterInformation(lat : Double,long:Double)
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var lat  = 0.0
    var long = 0.0
    let locationManager = CLLocationManager()
    var delegate: DataEnteredDelegate?
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        delegate?.userDidEnterInformation(lat: lat, long: long)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lat = locValue.latitude
        long = locValue.longitude
        setPinOnMap()
    }
    
    
    func setPinOnMap() {
        
        var locValue:CLLocationCoordinate2D = CLLocationCoordinate2D()
        let annotation = MKPointAnnotation()
        locValue.latitude = lat
        locValue.longitude = long
        annotation.coordinate = locValue
        mapView!.isZoomEnabled = false
        self.mapView!.showAnnotations(self.mapView!.annotations, animated: true)
        mapView?.addAnnotation(annotation)
        delegate?.userDidEnterInformation(lat: lat, long: long)
    }
}


