//
//  SettingsViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

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
    
    
    
    @IBAction func sendFeedback(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func realTimeSwitchToggled(_ sender: Any) {
        if realTimeSwitch.isOn {
            userDefaults.set(true, forKey: "RealTimeEnabled")
            
        } else {
            userDefaults.set(false, forKey: "RealTimeEnabled")
        }
    }
    
    //MARK: Mail Composer Methods
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["yountdaniel@gmail.com"])
        mailComposerVC.setSubject("F5 o'Clock App Feedback")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration in settings and try again.", preferredStyle: .alert)
        self.show(sendMailErrorAlert, sender: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
