//
//  SettingsViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let userDefaults = UserDefaults()
    
    @IBOutlet weak var realTimeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == true {
            realTimeSwitch.isOn = true
        }
        
        if userDefaults.bool(forKey: "RealTimeEnabled") == false {
            realTimeSwitch.isOn = false
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func realTimeSwitchToggled(_ sender: Any) {
        if realTimeSwitch.isOn {
            userDefaults.set(true, forKey: "RealTimeEnabled")
            
        } else {
            userDefaults.set(false, forKey: "RealTimeEnabled")
        }
    }

}
