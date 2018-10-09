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
    
    @IBOutlet weak var filterV: UILabel!
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    let RC = 0.0525
    
    let dt = 0.1
    var vx = 0.0
    var vy = 0.0
    var vz = 0.0
    var ax = 0.0
    var ay = 0.0
    var az = 0.0
    
    var date = Date()
    
    var oldAcc = 0.0
    var velAcc = 0.0
    var velGPS = 0.0
    var vel = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //motionManager.startAccelerometerUpdates()
        //motionManager.startGyroUpdates()
        //motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        
        
        timer = Timer.scheduledTimer(timeInterval: dt, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func update() {
        /*
        print("update")
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData)
        }
        if let gyroData = motionManager.gyroData {
            print(gyroData)
        }
        if let magnetometerData = motionManager.magnetometerData {
            print(magnetometerData)
        }*/
        if let deviceMotion = motionManager.deviceMotion {
            
            
            //print(deviceMotion)
            
            vx+=(deviceMotion.userAcceleration.x-ax)*dt*9.8
            vy+=(deviceMotion.userAcceleration.y-ay)*dt*9.8
            vz+=(deviceMotion.userAcceleration.z-az)*dt*9.8
            
            ax = deviceMotion.userAcceleration.x
            ay = deviceMotion.userAcceleration.y
            az = deviceMotion.userAcceleration.z
                
            //let acc = sqrt(pow(deviceMotion.userAcceleration.x,2) + pow(deviceMotion.userAcceleration.y,2) + pow(deviceMotion.userAcceleration.z,2))
            
            //let alpha = dt / (dt + RC)
            let alpha = 0.25
            
            velAcc = sqrt(pow(vx,2) + pow(vy,2) + pow(vz,2))
            vel = alpha*velAcc+(1-alpha)*vel
            acceleration.text = String(format: "%.2f",velAcc*3.6)
            
            filterV.text = String(format: "%.1f",vel*3.6)
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
        
        let userLocation = locations[locations.count - 1]
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        print(userLocation)
        // manager.stopUpdatingLocation()
        latitude.text = String(format: "%.4f", userLocation.coordinate.latitude)
        longitude.text = String(format: "%.4f", userLocation.coordinate.longitude)
        
        hAccuracy.text = String(format: "%.4f",userLocation.horizontalAccuracy)
        vAccuracy.text = String(format: "%.4f",userLocation.verticalAccuracy)
        
        let deltaT =  userLocation.timestamp.timeIntervalSince(date)
        date = userLocation.timestamp
        
        //let alpha = deltaT / (deltaT + RC)
        let alpha = 0.95
        
        speed.text =  String(format: "%.2f",userLocation.speed*3.6)
        altitude.text = String(format: "%.4f", userLocation.altitude)
        
        vel = alpha*userLocation.speed+(1-alpha)*vel
        
        filterV.text = String(format: "%.1f",vel*3.6)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
}

