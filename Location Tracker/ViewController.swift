//
//  ViewController.swift
//  Location Tracker
//
//  Created by Eric London on 6/30/16.
//  Copyright © 2016 Eric London. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var device_uuid: String = ""
    var api_host: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true

        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }

        if CLLocationManager.locationServicesEnabled() && CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        // API Stuff:
        device_uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString

        // TODO: get ngrok working, or deploy to a production environment:
        api_host = "10.0.1.4:3000"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            // locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1]
        
        let url:NSURL = NSURL(string: "http://" + api_host + "/api/location_payloads")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        var httpRequestBody = "uuid=" + self.device_uuid
        httpRequestBody += "&latitude=" + String(location.coordinate.latitude)
        httpRequestBody += "&longitude=" + String(location.coordinate.longitude)
        httpRequestBody += "&timestamp_at=" + String(location.timestamp)
        httpRequestBody += "&speed=" + String(location.speed)
        request.HTTPBody = httpRequestBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (
            let data, let response, let error) in
        
            // debug:
            // print(data)
            // print(response)
            // print(error)
            
        }
        
        task.resume()
        
    }
    
}

