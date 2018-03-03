//
//  SettingsViewController.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var redditSourceLabel: UILabel!
    @IBOutlet weak var realTimeSwitch: UISwitch!
    @IBOutlet weak var subredditTextField: UITextField!
    @IBOutlet weak var setNewSubredditLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var realTimeEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "RealTimeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RealTimeEnabled") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subredditTextField.returnKeyType = .done
        subredditTextField.clearButtonMode = .whileEditing
        subredditTextField.delegate = self
        subredditTextField.text = RedditModel().subredditName
        
        if realTimeEnabled {
            realTimeSwitch.isOn = true
        } else {
            realTimeSwitch.isOn = false
        }
        
        // TODO: Remove when we want to enable this feature
        // feature - changing subreddits
//        subredditTextField.isHidden = true
//        setNewSubredditLabel.isHidden = true
//        resetButton.isHidden = true
        
        redditSourceLabel.text = "📥 Currently Pulling From: \(RedditModel().subredditName.capitalized)"
        navigationController?.navigationBar.prefersLargeTitles = true
                
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func resetSettings(_ sender: Any) {
        RedditModel().resetRedditURL()
        subredditTextField.text = RedditModel().subredditName.capitalized
        viewDidLoad()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let enteredText = subredditTextField.text else {
            subredditTextField.text = "Please enter a valid subreddit"
            return false
        }
        
        RedditModel().subredditName = enteredText
        redditSourceLabel.text = "📥 Currently Pulling From: \(RedditModel().subredditName.capitalized)"
        
        subredditTextField.resignFirstResponder()
        
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        // Do all string validation here!
        guard let enteredText = subredditTextField.text else {
            return false
        }
        
        if enteredText == "" || enteredText == " " {
            let alert = UIAlertController.init()
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
            }
            alert.addAction(okAction)
            alert.message = "Please enter the name of a valid subreddit."
            
            showDetailViewController(alert, sender: nil)
            return false
        } else {
            return true
        }
    }
    
}
