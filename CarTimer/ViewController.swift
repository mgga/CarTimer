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
    @IBOutlet weak var gCoutOutValue: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var acceleration: UILabel!

    
    
    @IBOutlet weak var tNorth: UISwitch!
    @IBOutlet weak var filterV: UILabel!
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    let dt = 0.1
    
    var errorR = 0.0
  
    var date = Date()
    
    var alphaACC = 0.0
    var alphaGPS = 1.0
    var gCoutOut = 0.0
    
    var vGPSx = 0.0
    var vGPSy = 0.0
    
    var vACCx = 0.0
    var vACCy = 0.0
    
    var vFx = 0.0
    var vFy = 0.0
    
    var velAcc = 0.0
    var velGPS = 0.0
    var vel = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xMagneticNorthZVertical )
        timer = Timer.scheduledTimer(timeInterval: dt, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
        
        filterV.text = String(format: "%.1f",sqrt(pow(vFx,2)+pow(vFy,2))*3.6)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func update() {
        
        if let deviceMotion = motionManager.deviceMotion {
            
            
            //print(deviceMotion)
            if sqrt(pow(deviceMotion.userAcceleration.x,2)+pow(deviceMotion.userAcceleration.y,2)) > gCoutOut {
                
                //let accX = deviceMotion.userAcceleration.x*9.8*
                //let accy =
                
                //vACCx+=(deviceMotion.userAcceleration.x)*dt*9.8
                //vACCy+=(deviceMotion.userAcceleration.y)*dt*9.8
                //vz+=(deviceMotion.userAcceleration.z)*dt*9.8
                
                
                //vFx = alphaACC*vACCx+(1-alphaACC)*vFx
                //vFy = alphaACC*vACCy+(1-alphaACC)*vFy
                vFx += (deviceMotion.userAcceleration.x)*dt*9.8
                vFy += (deviceMotion.userAcceleration.y)*dt*9.8
                
                //acceleration.text = String(format: "%.2f",sqrt(pow(vACCx,2) + pow(vACCy,2))*3.6)
                filterV.text = String(format: "%.1f",sqrt(pow(vFx,2)+pow(vFy,2))*3.6)
            
            }
        }
    }
    
    @IBAction func tNorthSwitch(_ sender: Any) {
        if tNorth.isOn {
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xTrueNorthZVertical )
            print("True north On")
            
        }
        else{
            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xMagneticNorthZVertical )
            print("True north Off")
        }
        
    }

    @IBAction func alphaGPSChange(_ sender: UISlider) {
        alphaGPS = Double(sender.value)
        print("AlphaGPS: %.2f", alphaGPS)
        
    }
    @IBAction func alphaACCChange(_ sender: UISlider) {
        alphaACC = Double(sender.value)
        print("AlphaACC: %.2f", alphaACC)
    }
    @IBAction func GcoutOut(_ sender: UISlider) {
        gCoutOut = Double(sender.value)
        gCoutOutValue.text = String(format: "%.4f",gCoutOut)
        //print("AlphaACC: %.2f", gCoutOut)
    }
    @IBAction func resetDistance(_ sender: Any) {
        reset()
        
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
    
    func reset(){
        vFx = 0
        vFy = 0
        vACCx = 0
        vACCy = 0
        vGPSx = 0
        vGPSy = 0
        
        
        speed.text =  String(format: "%.1f",0.0)
        acceleration.text = String(format: "%.1f",0.0)
        filterV.text = String(format: "%.1f",0.0)
        
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
        altitude.text = String(format: "%.4f", userLocation.altitude)
        //vAccuracy.text = String(format: "%.4f",userLocation.verticalAccuracy)
        
        //let deltaT =  userLocation.timestamp.timeIntervalSince(date)
        //date = userLocation.timestamp
        
        //let alpha = deltaT / (deltaT + RC)
        
        if (userLocation.course >= 0){
            vGPSx = userLocation.speed * cos(2.0*Double.pi - (userLocation.course*2.0*Double.pi)/360)
            vGPSy = userLocation.speed * sin(2.0*Double.pi - (userLocation.course*2.0*Double.pi)/360)
            
            let perrorR = errorR
            errorR = userLocation.speed-sqrt(pow(vFx,2)+pow(vFy,2))
            //if (perrorR > errorR){ gCoutOut -= 0.001}else{ gCoutOut += 0.001}
            vFx = vGPSx
            vFy = vGPSy
            acceleration.text =  String(format: "%.1f",errorR)
            speed.text =  String(format: "%.1f",userLocation.speed*3.6)
            filterV.text = String(format: "%.1f",sqrt(pow(vFx,2)+pow(vFy,2))*3.6)
        }
        
        
        //filterV.text = String(format: "%.1f",sqrt(pow(vFx,2)+pow(vFy,2))*3.6)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
}

