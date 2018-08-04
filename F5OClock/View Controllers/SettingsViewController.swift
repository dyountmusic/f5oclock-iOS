//
//  SettingsViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import MessageUI
import OAuthSwift

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var redditSourceLabel: UILabel!
    @IBOutlet weak var realTimeSwitch: UISwitch!
    @IBOutlet weak var itentityLabel: UILabel!
    
    var oauthAuthorizer: OAuthSwift?
    
    var realTimeEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "RealTimeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RealTimeEnabled") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if realTimeEnabled {
            realTimeSwitch.isOn = true
        } else {
            realTimeSwitch.isOn = false
        }
        
        redditSourceLabel.text = "📥 Currently Pulling From: \(RedditModel().subredditName.capitalized)"
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
            realTimeEnabled = true
        } else {
            realTimeEnabled = false
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
    
    @IBAction func logIntoReddit(_ sender: Any) {
        handleAuth()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func whoAmI(_ sender: Any) {
        retrieveIdentity()
    }
    
    func retrieveIdentity() {
        oauthAuthorizer?.client.request(AuthorizationStrings.baseURL.rawValue + "/api/v1/me", method: .GET, success: { (response) in
            do {
                let redditUser = try JSONDecoder().decode(RedditUser.self, from: response.data)
                self.itentityLabel.text = "Logged in as: \(redditUser.name)"
            } catch let jsonError {
                print("Error serializing JSON from remote server \(jsonError.localizedDescription)")
            }
        }, failure: { (error) in
            print("Error retriving identity from reddit: \(error)")
        })
    }
}
