//
//  PopupViewController.swift
//  userLocation
//
//  Created by Bobby Deaton on 11/6/18.
//  Copyright © 2018 Bobby Deaton. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {

    
    @IBOutlet weak var speedSC: UIView!
    @IBOutlet weak var tempSC: UIView!
    @IBOutlet weak var altitudeSC: UIView!
    @IBOutlet weak var doneButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        self.view.removeFromSuperview()
    
    }
    //    @IBAction func popupSettings(_ sender: UIButton) {
    //        self.settingsView.isHidden = false
    //        hideTabBarButton?.isHidden = true
    //    }
    //
    //    @IBAction func closeSettingsView(_ sender: UIButton) {
    //        self.settingsView.isHidden = true
    //        hideTabBarButton?.isHidden = false
    //    }

    @IBAction func speedSC(_ sender: UISegmentedControl) {
        
                let speedIndex = sender.selectedSegmentIndex
                switch speedIndex {
                case 0:
//                    speedDisplay.isHidden = false
//                    speedDisplayMPH.isHidden = true
//                    speedBoth?.isHidden = true
//                    speedTypeLabel.text = "km/h"
//                    speedTypeBoth?.isHidden = true
                    print("km/h")
                case 1:
//                    speedDisplayMPH.isHidden = false
//                    speedDisplay.isHidden = true
//                    speedBoth?.isHidden = true
//                    speedTypeBoth?.isHidden = true
//                    speedTypeLabel.text = "mph"
                    print("mph")
                case 2:
//                    speedDisplay.isHidden = false
//                    speedDisplayMPH.isHidden = true
//                    speedBoth?.isHidden = false
//                    speedTypeBoth?.isHidden = false
//                    speedTypeLabel.text = "km/h"
                    break
                default:
//                    speedDisplay.isHidden = false
//                    speedDisplayMPH.isHidden = true
//                    speedTypeBoth?.isHidden = true
//                    speedBoth?.isHidden = true
//                    speedTypeLabel.text = "km/h"
                    break
                }
        
            }
    
            @IBAction func tempSC(_ sender: UISegmentedControl) {
                let tempIndex = sender.selectedSegmentIndex
                switch tempIndex {
                case 0:
//                    tempDisplay.isHidden = false
//                    tempFDisplay.isHidden = true
//                    tempBoth.isHidden = true
                    break
                case 1:
//                    tempFDisplay.isHidden = false
//                    tempDisplay.isHidden = true
//                    tempBoth.isHidden = true
                    break
                case 2:
//                    tempFDisplay.isHidden = true
//                    tempDisplay.isHidden = false
//                    tempBoth.isHidden = false
                    break
                default:
//                    tempDisplay.isHidden = false
//                    tempFDisplay.isHidden = true
//                    tempBoth.isHidden = true
                    break
                }
            }
    
            @IBAction func altitudeSC(_ sender: UISegmentedControl) {
                let altIndex = sender.selectedSegmentIndex
                switch altIndex {
                case 0:
//                    altitudeDisplay.isHidden = true
//                    altitudeFtDisplay.isHidden = false
//                    altitudeBoth.isHidden = true
                    break
                case 1:
//                    altitudeDisplay.isHidden = false
//                    altitudeFtDisplay.isHidden = true
//                    altitudeBoth.isHidden = true
                    break
                case 2:
//                    altitudeDisplay.isHidden = true
//                    altitudeFtDisplay.isHidden = false
//                    altitudeBoth.isHidden = false
                    break
                default:
//                    altitudeDisplay.isHidden = true
//                    altitudeFtDisplay.isHidden = false
//                    altitudeBoth.isHidden = true
                    break
                }
                    
            }
}
