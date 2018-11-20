//
//  hudViewController.swift
//  userLocation
//
//  Created by Bobby Deaton on 10/19/18.
//  Copyright © 2018 Bobby Deaton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HudViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIApplicationDelegate {
    
    let locationManager = CLLocationManager()
    let heading = CLHeading()
    
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

    @IBOutlet weak var hideTabBar: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var altitudeDisplay: UILabel!
    @IBOutlet weak var speedDisplay: UILabel!
    @IBOutlet weak var speedType: UILabel!
    @IBOutlet weak var timeDisplay: UILabel!
    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var headingDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)

        hideTabBar.layer.masksToBounds = true
        hideTabBar.layer.cornerRadius = 8
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.headingFilter = 5
        }
        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//        self.view.addGestureRecognizer(swipeLeft)
//
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
//        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
//        self.view.addGestureRecognizer(swipeRight)
 
        self.tabBarController?.tabBar.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.speedDisplay.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.altitudeDisplay.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.headingDisplay.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.tempDisplay.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.timeDisplay.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.speedType.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
//    func swipeAction(gesture: UISwipeGestureRecognizer) {
//
//        switch UISwipeGestureRecognizer.self {
//            case UISwipeGestureRecognizer.Direction.right:
//                print("Swiped right")
//            case UISwipeGestureRecognizer.Direction.left:
//                print("Swiped left")
//            default:
//                break
//            }
//    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.mapType = MKMapType.standard
        let location = locations[0]
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: myLocation, span: span)
        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
       
        let speed = location.speed
        if speed < 2 {
            self.speedDisplay.text = "0.0"
        }
        else {
//            self.speedDisplay.text = String(format: "%.1f", speed * 2.236936284, "MPH")
            self.speedDisplay.text = String(format: "%.1f", speed * 3.6, "km/h")
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
//                    self.tempDisplay.text = String(format: "%.0f ⁰C", ggtemp!)
                    self.tempDisplay.text = String(format: "%.0f ⁰F", ggtemp! * 1.8 + 32)

                }
            } catch  {
                print(error)
                return
            }
        })

        dataTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func tick() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        timeDisplay.text = dateFormatter.string(from: NSDate() as Date)
        
    }
    
    private func locationManager(manager: CLLocationManager,
                                 didFailWithError error: Error) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tabBarController?.tabBar.isHidden = false
        self.hideTabBar?.isHidden = false
    }
    
    @IBAction func hideTabBar(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        self.hideTabBar?.isHidden = true

    }
    
    @IBAction func showPopup(_ sender: UIButton) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsView") as! PopupViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
}
