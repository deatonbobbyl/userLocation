//
//  MapViewController.swift
//  userLocation
//
//  Created by Bobby Deaton on 10/10/18.
//  Copyright © 2018 Bobby Deaton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CALayerDelegate, UIGestureRecognizerDelegate {
    
    let locationManager = CLLocationManager()
    let heading = CLHeading()
    var regionHasBeenCentered = false

    struct MyWeather : Decodable {
        let coord : Coordinate?
        let weather : [Weather]?
        let base : String?
        let main : Main?
        let visibility: Int?
        let wind : Wind?
        let clouds : Clouds?
        let sys : Sys?
        let id : Int?
        let name : String?
        let cod : Int?
    }

    struct Coordinate : Decodable {
        let lat : Double?
        let lon : Double?
    }

    struct Weather : Decodable {
        var id : Int?
        var main, myDescription, icon : String?

        enum CodingKeys : String, CodingKey {
            case id = "id"
            case main = "main"
            case icon = "icon"
            case myDescription = "description"
        }
    }

    struct Main : Decodable {
        let temp : Double?
        let pressure : Int?
        let humidity : Int?
        let temp_min : Double?
        let temp_max : Double?
    }

    struct Wind : Decodable {
        let speed : Double?
        let deg : Int?
    }

    struct Clouds: Decodable {
        let all : Int?
    }

    struct Sys : Decodable {
        let type : Int?
        let id : Int?
        let message : Double?
        let country : String?
    }
    
    var timer = Timer()
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var minusArrow: UIButton!
    @IBOutlet weak var plusArrow: UIButton!
    @IBOutlet weak var headingDisplay: UILabel!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var tempCDisplay: UILabel!
    @IBOutlet weak var tempFDisplay: UILabel!
    @IBOutlet weak var mphSpeedDisplay: UILabel!
    @IBOutlet weak var kmhSpeedDisplay: UILabel!
    @IBOutlet weak var kmhDisplay: UILabel!
    @IBOutlet weak var altitudeDisplay: UILabel!
    @IBOutlet weak var arrowPressed: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)

        mapView.delegate = self
        mapView.showsCompass = true
        self.tabBarController?.tabBar.isHidden = true
        headingDisplay.layer.masksToBounds = true
        headingDisplay.layer.cornerRadius = 8
        mphSpeedDisplay.layer.masksToBounds = true
        mphSpeedDisplay.layer.cornerRadius = 8
        kmhSpeedDisplay.layer.masksToBounds = true
        kmhSpeedDisplay.layer.cornerRadius = 8
        tempCDisplay.layer.masksToBounds = true
        tempCDisplay.layer.cornerRadius = 8
        tempFDisplay.layer.masksToBounds = true
        tempFDisplay.layer.cornerRadius = 8
        altitudeDisplay.layer.masksToBounds = true
        altitudeDisplay.layer.cornerRadius = 8
        arrowPressed.layer.masksToBounds = true
        arrowPressed.layer.cornerRadius = 8
        plusArrow.layer.cornerRadius = 8
        plusArrow.layer.masksToBounds = true
        minusArrow.layer.cornerRadius = 8
        minusArrow.layer.masksToBounds = true
//        settingsButton.layer.cornerRadius = 8
//        settingsButton.layer.masksToBounds = true
    
        self.locationManager.requestWhenInUseAuthorization()
    
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.headingFilter = 5
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        mapView.mapType = MKMapType.standard
        let location = locations[0]
        if !regionHasBeenCentered {
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: userLocation, span: span)
            
            mapView.setRegion(region, animated: true)
            regionHasBeenCentered = true
        }
        self.mapView.showsUserLocation = true
        
        
        let speed = location.speed
        if speed < 2 {
            self.mphSpeedDisplay.text = "0.0"
            self.kmhSpeedDisplay.text = "0.0"
        }
        else {
            self.mphSpeedDisplay.text = String(format: "%.1f", speed * 2.236936284, "MPH")
            self.kmhSpeedDisplay.text = String(format: "%.1f", speed * 3.6, "MPH")
        }
        print(speed, "speed")
        
        let altitude = location.altitude
        self.altitudeDisplay.text = String(format: "%.0f ft", altitude * 3.280839895, "Ft")
        print(altitude, "alt")
        
        let heading = location.course
        if heading < 0 { return }
        
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((heading + 22.5) / 45.0) & 7
        
        headingDisplay.text = directions[index]
        print(directions[index])
 
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        
        let APIUrl = NSURL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=e7b2054dc37b1f464d912c00dd309595&units=Metric")
        
        let request = URLRequest(url:APIUrl! as URL)
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                print(error ?? "Error is empty.")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "HTTP response is empty.")
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                let weatherData = try JSONDecoder().decode(MyWeather.self, from: responseData)
                let ggtemp = weatherData.main?.temp
                print(ggtemp!, "THIS IS THE TEMP")
                DispatchQueue.main.async {
                    self.tempCDisplay.text = String(format: "%.0f ⁰C", ggtemp!)
                    self.tempFDisplay.text = String(format: "%.0f ⁰F", ggtemp! * 1.8 + 32)
                }
            } catch  {
                print(error)
                return
            }
        })
        
        dataTask.resume()
    }
    
    @objc func tick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        timeDisplay.text = dateFormatter.string(from: NSDate() as Date)
    }
    
    var location: CLLocation!
    
    @IBAction func arrowPressed(_ sender: Any) {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }

    @IBAction func zoomInButton(_ sender: Any) {
    
        let region = MKCoordinateRegion(center: self.mapView.region.center, span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*0.7, longitudeDelta: mapView.region.span.longitudeDelta*0.7))
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOutButton(_ sender: Any) {
        
        let region = MKCoordinateRegion(center: self.mapView.region.center, span: MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/0.7, longitudeDelta: mapView.region.span.longitudeDelta/0.7))
            mapView.setRegion(region, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
}

