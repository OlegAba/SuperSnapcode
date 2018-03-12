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
    
    func getSnapcodeWithBitmojiImage(username: String, completion: @escaping (UIImage?)->()) {
        let bitmojiImageEndpointRequest = BitmojiImageEndpointRequest(snapchatUsername: username)
        bitmojiImageEndpointRequest.start { (bitmojiImage: UIImage?) in
            
            guard let bitmojiImage = bitmojiImage else { completion(nil); return }
            
            let bitmojiSnapcodeEndpointRequest = BitmojiSnapcodeEndpointRequest(snapchatUsername: username)
            bitmojiSnapcodeEndpointRequest.start { (snapcodeImage: UIImage?) in
                
                guard let snapcodeImage = snapcodeImage else { completion(nil); return }
                    
                let snapcodeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                snapcodeImageView.image = snapcodeImage
                
                let bitmojiImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 190, height: 190))
                bitmojiImageView.center = snapcodeImageView.center
                bitmojiImageView.backgroundColor = UIColor.snapYellow
                bitmojiImageView.layer.cornerRadius = bitmojiImageView.frame.width / 2.0
                bitmojiImageView.clipsToBounds = true
                bitmojiImageView.image = bitmojiImage
                
                completion(UIImage.imageFromUIViews(views: [snapcodeImageView, bitmojiImageView]))
            }
        }
    }
    
    func showCannotGetSnapcodeError() {
        print("Could not get snapcode")
    }
    
    func showInvalidSnapchatUsernameError() {
        print("Invalid snapchat username")
    }
    
    func sanitizeSnapchatUsernameString(username: String) -> String? {

//Snapchat usernames:
//● Must be 3-15 characters long
//● Can’t contain spaces
//● Must begin with a letter
//● Can only contain letters, numbers, and the special characters
//hyphen ( - ), underscore ( _ ), and period ( . ), EXCEPT that the username:
//● Can’t begin with a number, hyphen, underscore, or period
//● Can’t end with a hyphen, underscore, or period
//● Can’t contain emojis or other symbols such as @, $, #, etc.
//● Will appear only in lower-case letters within the app
        
        let result = username.trimmingCharacters(in: .whitespaces).lowercased()
        
        for i in 0 ..< result.count {
            let character = result[i]
            
            if character.isLetter() || character.isDigit() {
                continue
            }
            
            if character == "-" || character == "_" || character == "." {
                if i == 0 || i == result.count - 1 {
                    return nil
                }
                continue
            }
            
            return nil
        }
        
        if result.count < 3 {
            return nil
        }

        return result
    }
    
    @objc func nextButtonWasPressed() {
        guard let username = usernameTextField.text else { return }
        guard let sanitizedUsername = sanitizeSnapchatUsernameString(username: username) else { showInvalidSnapchatUsernameError(); return }
        
        // Get snapcode with bitmoji image in the middle
        self.getSnapcodeWithBitmojiImage(username: sanitizedUsername) { (bitmojiSnapcodeImage: UIImage?) in
            
            // Get regular snapcode with ghose in the middle
            let snapcodeEndpointRequest = SnapcodeEndpointRequest(snapchatUsername: sanitizedUsername)
            snapcodeEndpointRequest.start { (snapcodeImage: UIImage?) in
                
                if let bitmojiSnapcodeImage = bitmojiSnapcodeImage {
                    System.shared.snapcode = bitmojiSnapcodeImage
                } else if let snapcodeImage = snapcodeImage {
                    System.shared.snapcode = snapcodeImage
                } else {
                    self.showCannotGetSnapcodeError()
                    return
                }
                
                DispatchQueue.main.async {
                    let selectPhotoViewController = SelectPhotoViewController()
                    System.shared.appDelegate().pageViewController?.setViewControllers([selectPhotoViewController], direction: .forward, animated: true, completion: nil)
                }
            }
        }
    }
}

