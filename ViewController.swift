//
//  ViewController.swift
//  userLocation
//
//  Created by Bobby Deaton on 9/18/18.
//  Copyright © 2018 Bobby Deaton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CALayerDelegate {

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
            let humidity : Int?
            let temp_min : Double?
            let temp_max : Double?
        }

        struct Wind : Decodable {
            let speed : Double?
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
    
    @IBOutlet weak var altitudeBoth: UILabel!
    @IBOutlet weak var speedTypeBoth: UILabel!
    @IBOutlet weak var speedBoth: UILabel!
    @IBOutlet weak var tempBoth: UILabel!
    @IBOutlet weak var hideTabBarButton: UIButton!
    @IBOutlet weak var tempFDisplay: UILabel!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var headingDisplay: UILabel!
    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var altitudeDisplay: UILabel!
    @IBOutlet weak var speedTypeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latDisplay: UILabel!
    @IBOutlet weak var longDisplay: UILabel!
    @IBOutlet weak var speedDisplayMPH: UILabel!
    @IBOutlet weak var altitudeFtDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
        mapView?.delegate = self
        altitudeDisplay?.isHidden = true
        speedDisplayMPH?.isHidden = true
        tempFDisplay?.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        hideTabBarButton?.isHidden = true
        
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.headingFilter = 5
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func tick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        timeDisplay.text = dateFormatter.string(from: NSDate() as Date)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        mapView?.mapType = MKMapType.standard
        let location = locations[0]
        if !regionHasBeenCentered {
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: userLocation, span: span)

            mapView?.setRegion(region, animated: true)
            regionHasBeenCentered = true
        }
        self.mapView?.showsUserLocation = true
        self.mapView?.userTrackingMode = .followWithHeading
        
        let speed = location.speed
        if speed < 1 {
            self.speedDisplay?.text = "0.0"
            self.speedDisplayMPH?.text = "0.0"
        }
        else {
                self.speedDisplayMPH?.text = String(format: "%.1f", speed * 2.236936284, "MPH")
                self.speedDisplay?.text = String(format: "%.1f", speed * 3.6, "km/h")
                self.speedBoth?.text = String(format: "%.1f", speed * 2.236936284, "MPH")
        }
        print(speed, "speed")

        let altitude = location.altitude
        self.altitudeDisplay?.text = String(format: "%.0f m", altitude, "m")
        self.altitudeFtDisplay?.text = String(format: "%.0f ft", altitude * 3.280839895, "Ft")
        self.altitudeBoth?.text = String(format: "%.0f m", altitude, "m")
        print(altitude, "alt")

        let heading = location.course
        if heading < 0 { return }

        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((heading + 22.5) / 45.0) & 7

        headingDisplay?.text = directions[index]
        print(directions[index])

        let lat = location.coordinate.latitude
        print(lat, "lat")
        let long = location.coordinate.longitude
        print(long, "long")
        let latDegrees = abs(Int(lat))
        let latMinutes = abs(Int((lat * 3600).truncatingRemainder(dividingBy: 3600) / 60))
        let latSeconds = Double(abs((lat * 3600).truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60)))
        
        let lonDegrees = abs(Int(long))
        let lonMinutes = abs(Int((long * 3600).truncatingRemainder(dividingBy: 3600) / 60))
        let lonSeconds = Double(abs((long * 3600).truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60) ))
        latDisplay?.text = String(format:"%d° %d' %.0f\" %@", latDegrees, latMinutes, latSeconds, lat >= 0 ? "N" : "S")
        longDisplay?.text = String(format:"%d° %d' %.0f\" %@", lonDegrees, lonMinutes, lonSeconds, long >= 0 ? "E" : "W")
        print("latLabel", String(format:"%d° %d' %.0f\" %@", latDegrees, latMinutes, latSeconds, lat >= 0 ? "N" : "S"))
        print("longLabel", String(format:"%d° %d' %.0f\" %@", lonDegrees, lonMinutes, lonSeconds, long >= 0 ? "E" : "W"))

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
                    
                    self.tempDisplay?.text = String(format: "%.0f ⁰C", ggtemp!)
                    self.tempFDisplay?.text = String(format: "%.0f ⁰F", ggtemp! * 1.8 + 32)
                    self.tempBoth?.text = String(format: "%.0f ⁰F", ggtemp! * 1.8 + 32)
                    print("temp", String(format: "%.0f ⁰C", ggtemp!))
                    print("temp", String(format: "%.0f ⁰F", ggtemp! * 1.8 + 32))
                    
                }
            } catch  {
                print(error)
                return            }
        })
        dataTask.resume()
    }


    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tabBarController?.tabBar.isHidden = false
        hideTabBarButton?.isHidden = false
    }

    @IBAction func hideTabBar(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        hideTabBarButton?.isHidden = true
    }

    @IBAction func showPopup(_ sender: UIButton) {
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsView") as! PopupViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
    }
    
}

