//
//  ViewController.swift
//  CarTimer
//
//  Created by Miguel Almeida on 08.10.18.
//  Copyright © 2018 Miguel Almeida. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var hAccuracy: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var vAccuracy: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var acceleration: UILabel!
    
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        startLocation = nil
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func update() {
        print("update")
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData)
        }
        if let gyroData = motionManager.gyroData {
            print(gyroData)
        }
        if let magnetometerData = motionManager.magnetometerData {
            print(magnetometerData)
        }
        if let deviceMotion = motionManager.deviceMotion {
            print(deviceMotion)
            
            let acc = sqrt(pow(deviceMotion.userAcceleration.x,2) + pow(deviceMotion.userAcceleration.y,2) + pow(deviceMotion.userAcceleration.z,2))
            
                acceleration.text = String(format: "%.4f",acc)
        }
    }
    


    @IBAction func resetDistance(_ sender: Any) {
        startLocation = nil
    }
    
    @IBAction func startWhenInUse(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    @IBAction func startAlways(_ sender: Any) {
        
        locationManager.stopUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        latitude.text = String(format: "%.4f", userLocation.coordinate.latitude)
        longitude.text = String(format: "%.4f", userLocation.coordinate.longitude)
        
        let kmh = (userLocation.speed/1000)*3600
        
        speed.text =  String(format: "%.4f",kmh)
        altitude.text = String(format: "%.4f", userLocation.altitude)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
}

