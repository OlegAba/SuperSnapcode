//
//  FetchSnapcodeViewController.swift
//  Live-Snap
//
//  Created by Baby on 1/15/18.
//  Copyright © 2018 Baby. All rights reserved.
//

import UIKit

class FetchSnapcodeViewController: UIViewController, UITextFieldDelegate {
    
    var instructionsTextLabel: UILabel!
    var usernameTextField: UITextField!
    var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        System.shared.snapcode = nil
        
        view.backgroundColor = UIColor.snapBlack
        
        instructionsTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.75, height: 100))
        instructionsTextLabel.center = CGPoint(x: view.frame.width / 2.0, y: view.frame.height * 0.2)
        instructionsTextLabel.textColor = UIColor.snapWhite
        instructionsTextLabel.textAlignment = .center
        instructionsTextLabel.text = "What is your Snapchat username?"
        view.addSubview(instructionsTextLabel)
        
        usernameTextField = UITextField(frame: CGRect(x: 0, y: instructionsTextLabel.bottomCenter().y + view.frame.height * 0.075, width: view.frame.width * 0.75, height: 50))
        usernameTextField.center = CGPoint(x: view.frame.width / 2.0, y: usernameTextField.center.y)
        usernameTextField.backgroundColor = UIColor.snapBlack
        usernameTextField.setBottomUnderline(color: UIColor.snapYellow, lineWidth: 1.0)
        usernameTextField.textColor = UIColor.snapWhite
        usernameTextField.tintColor = UIColor.snapWhite
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        usernameTextField.textAlignment = .center
        usernameTextField.keyboardType = .alphabet
        usernameTextField.keyboardAppearance = .dark
        usernameTextField.addTarget(self, action: #selector(usernameTextFieldTextChanged), for: .editingChanged)
        usernameTextField.delegate = self
        view.addSubview(usernameTextField)
        
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(UIColor.snapBlack, for: .normal)
        nextButton.setBackgroundImage(UIImage(color: UIColor.snapYellow, size: nextButton.frame.size), for: .normal)
        nextButton.setBackgroundImage(UIImage(color: UIColor.snapYellow.withAlphaComponent(0.75), size: nextButton.frame.size), for: .highlighted)
        nextButton.addTarget(self, action: #selector(nextButtonWasPressed), for: .touchUpInside)
        
        // Notification for when keyboard will show up to set frame of next button
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        showKeyboard()
    }
    
    func showKeyboard() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer: Timer) in
            self.usernameTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            nextButton.center = CGPoint(x: view.frame.width / 2.0, y: view.frame.height - keyboardSize.height - nextButton.frame.height / 2.0)
        }
    }
    
    @objc func usernameTextFieldTextChanged() {
        if let textLength = usernameTextField.text?.count, textLength > 0 {
            view.addSubview(nextButton)
        } else {
            nextButton.removeFromSuperview()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextButtonWasPressed()
        return false
    }
    
    @objc func nextButtonWasPressed() {
        guard let username = usernameTextField.text else { return }
        
        let endpointRequest = SnapcodeEndpointRequest(snapchatUsername: username)
        endpointRequest.start { (snapcodeImage: UIImage?) in
            if let snapcodeImage = snapcodeImage {
                System.shared.snapcode = snapcodeImage
                let selectPhotoViewController = SelectPhotoViewController()
                System.shared.appDelegate().pageViewController?.setViewControllers([selectPhotoViewController], direction: .forward, animated: true, completion: nil)
            } else {
                // display failure case here
            }
        }
    }
}

