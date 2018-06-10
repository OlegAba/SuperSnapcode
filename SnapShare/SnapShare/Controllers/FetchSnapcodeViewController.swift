//
//  FetchSnapcodeViewController.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/15/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import JGProgressHUD

class FetchSnapcodeViewController: UIViewController, UITextFieldDelegate {
    
    var instructionsTextLabel: UILabel!
    var usernameTextField: UITextField!
    var getSnapcodeButton: UIButton!
    var cannotGetSnapcodeErrorIndicator: JGProgressHUD!
    var noInternetConnectionErrorIndicator: JGProgressHUD!
    var fetchSnapcodeIndicator: JGProgressHUD!
    
    var snapcodeImageView: UIImageView!
    var snapcodeSelectionToolbar: UIToolbar!
    var toolbarInsturctionsLabel: UILabel!
    var snapcodeSelectionInsturctionsLabel: UILabel!
    var snapcodeSelectionSwitch: UISwitch!
    
    var bitmojiSnapcode: UIImage?
    var defaultSnapcode: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        System.shared.snapcode = nil
        
        view.backgroundColor = UIColor.snapBlack
        if view.isIPhoneX() {
            view.frame.size.height -= 34.0
        }
        
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
        
        getSnapcodeButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        getSnapcodeButton.setTitle("Get Snapcode", for: .normal)
        getSnapcodeButton.setTitleColor(UIColor.snapBlack, for: .normal)
        getSnapcodeButton.setBackgroundImage(UIImage(color: UIColor.snapYellow, size: getSnapcodeButton.frame.size), for: .normal)
        getSnapcodeButton.setBackgroundImage(UIImage(color: UIColor.snapYellow.withAlphaComponent(0.75), size: getSnapcodeButton.frame.size), for: .highlighted)
        getSnapcodeButton.addTarget(self, action: #selector(getSnapcodeButtonWasPressed), for: .touchUpInside)
        
        cannotGetSnapcodeErrorIndicator = JGProgressHUD(style: .dark)
        cannotGetSnapcodeErrorIndicator.indicatorView = JGProgressHUDErrorIndicatorView()
        cannotGetSnapcodeErrorIndicator.textLabel.text = "Failed to get Snapcode!\nPlease try again"
        cannotGetSnapcodeErrorIndicator.shadow = JGProgressHUDShadow()
        cannotGetSnapcodeErrorIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        noInternetConnectionErrorIndicator = JGProgressHUD(style: .dark)
        noInternetConnectionErrorIndicator.indicatorView = JGProgressHUDErrorIndicatorView()
        noInternetConnectionErrorIndicator.textLabel.text = "No internet connection!\nPlease check your network settings"
        noInternetConnectionErrorIndicator.shadow = JGProgressHUDShadow()
        noInternetConnectionErrorIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        
        fetchSnapcodeIndicator = JGProgressHUD(style: .dark)
        fetchSnapcodeIndicator.contentView.backgroundColor = UIColor.snapBlack
        fetchSnapcodeIndicator.textLabel.text = "Fetching Snapcode"
        
        //Snapcode Selection UI
        snapcodeImageView = UIImageView()
        snapcodeImageView.frame = CGRect(x: 0.0, y: System.shared.statusBarHeight + usernameTextField.frame.height + 10.0, width: view.frame.width * 0.75, height: view.frame.width * 0.75)
        snapcodeImageView.center.x = view.center.x
        
        snapcodeSelectionToolbar = UIToolbar(frame: CGRect(x: 0, y: view.frame.height - 45, width: view.frame.size.width, height: 45))
        snapcodeSelectionToolbar.isTranslucent = false
        snapcodeSelectionToolbar.barTintColor = UIColor.snapBlack
        
        let backBarButton = UIBarButtonItem(title: "Back", style:.plain, target: self, action: #selector(backButtonWasPressed))
        backBarButton.tintColor = UIColor.snapYellow
        
        let nextBarButton: UIBarButtonItem = UIBarButtonItem(title: "Next", style:.plain, target: self, action: #selector(nextButtonWasPressed))
        nextBarButton.tintColor = UIColor.snapYellow
        
        snapcodeSelectionToolbar.items = [backBarButton, UIBarButtonItem.flexibleSpace(), nextBarButton]
        
        toolbarInsturctionsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width * 0.5, height: 45))
        toolbarInsturctionsLabel.center = snapcodeSelectionToolbar.center
        toolbarInsturctionsLabel.text = "Select Snapcode"
        toolbarInsturctionsLabel.textColor = .white
        toolbarInsturctionsLabel.textAlignment = .center
        
        snapcodeSelectionInsturctionsLabel = UILabel()
        snapcodeSelectionInsturctionsLabel.text = "Bitmoji Snapcode"
        snapcodeSelectionInsturctionsLabel.sizeToFit()
        snapcodeSelectionInsturctionsLabel.textColor = .white
        snapcodeSelectionInsturctionsLabel.textAlignment = .left
        snapcodeSelectionInsturctionsLabel.frame.origin.y = snapcodeImageView.frame.maxY + (usernameTextField.frame.height * 1.5) + 40
        snapcodeSelectionInsturctionsLabel.frame.origin.x = snapcodeImageView.frame.minX
        
        snapcodeSelectionSwitch = UISwitch()
        snapcodeSelectionSwitch.center.y = snapcodeSelectionInsturctionsLabel.frame.midY
        snapcodeSelectionSwitch.frame.origin.x = snapcodeImageView.frame.maxX - snapcodeSelectionSwitch.frame.width
        snapcodeSelectionSwitch.setOn(true, animated: false)
        snapcodeSelectionSwitch.onTintColor = UIColor.snapYellow
        snapcodeSelectionSwitch.addTarget(self, action: #selector(bitmojiSwitchWasTapped), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            getSnapcodeButton.center = CGPoint(x: view.frame.width / 2.0, y: view.frame.height - keyboardSize.height - getSnapcodeButton.frame.height / 2.0)
        }
    }
    
    @objc func usernameTextFieldTextChanged() {
        if let textLength = usernameTextField.text?.count, textLength > 0 {
            view.addSubview(getSnapcodeButton)
        } else {
            getSnapcodeButton.removeFromSuperview()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getSnapcodeButtonWasPressed()
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
                bitmojiImageView.image = bitmojiImage
                
                completion(UIImage.imageFromUIViews(views: [snapcodeImageView, bitmojiImageView]))
            }
        }
    }
    
    func showCannotGetSnapcodeError() {
        print("Could not get snapcode")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.fetchSnapcodeIndicator.dismiss(animated: false)
            self.fetchSnapcodeIndicator.animation.animationFinished()
            self.view.addSubview(self.instructionsTextLabel)
            self.view.addSubview(self.usernameTextField)
            self.view.addSubview(self.getSnapcodeButton)
            self.showKeyboard()
            
            self.cannotGetSnapcodeErrorIndicator.show(in: self.view, animated: true)
            self.cannotGetSnapcodeErrorIndicator.dismiss(afterDelay: 2.0, animated: true)
            self.cannotGetSnapcodeErrorIndicator.animation.animationFinished()
        }
    }
    
    func showInvalidSnapchatUsernameError() {
        print("Invalid snapchat username")
        
        CATransaction.begin()
        
        let yellowToRedAnimation = CABasicAnimation(keyPath: "shadowColor")
        yellowToRedAnimation.fromValue = usernameTextField.layer.shadowColor
        yellowToRedAnimation.toValue = UIColor.red.cgColor
        yellowToRedAnimation.duration = 0.5
        yellowToRedAnimation.fillMode = kCAFillModeForwards
        yellowToRedAnimation.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock{ [weak self] in
            let redToYellowAnimation = CABasicAnimation(keyPath: "shadowColor")
            redToYellowAnimation.fromValue = UIColor.red.cgColor
            redToYellowAnimation.toValue = UIColor.snapYellow.cgColor
            redToYellowAnimation.duration = 0.5
            redToYellowAnimation.fillMode = kCAFillModeForwards
            redToYellowAnimation.isRemovedOnCompletion = false
            
            self?.usernameTextField.layer.add(redToYellowAnimation, forKey: redToYellowAnimation.keyPath)
        }
        
        usernameTextField.layer.add(yellowToRedAnimation, forKey: yellowToRedAnimation.keyPath)
        
        CATransaction.commit()
    }
    
    func showNoInternetConnectionError() {
        print("No internet connection")
        
        self.noInternetConnectionErrorIndicator.show(in: self.view, animated: true)
        self.noInternetConnectionErrorIndicator.dismiss(afterDelay: 2.0, animated: true)
        self.noInternetConnectionErrorIndicator.animation.animationFinished()
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
        
        if result.count < 3 || result.count > 30 {
            return nil
        }

        return result
    }
    
    @objc func getSnapcodeButtonWasPressed() {
        
        guard let username = usernameTextField.text, let sanitizedUsername = sanitizeSnapchatUsernameString(username: username) else {
            showInvalidSnapchatUsernameError()
            return
        }
        
        if !NetworkConnectivity.isConnected {
            showNoInternetConnectionError()
            return
        }
        
        instructionsTextLabel.removeFromSuperview()
        usernameTextField.removeFromSuperview()
        getSnapcodeButton.removeFromSuperview()
        fetchSnapcodeIndicator.show(in: view)
        
        // Get snapcode with bitmoji image in the middle
        getSnapcodeWithBitmojiImage(username: sanitizedUsername) { (bitmojiSnapcodeImage: UIImage?) in
            
            // Get regular snapcode with ghose in the middle
            let snapcodeEndpointRequest = SnapcodeEndpointRequest(snapchatUsername: sanitizedUsername)
            snapcodeEndpointRequest.start { (snapcodeImage: UIImage?) in
                
                if let bitmojiSnapcodeImage = bitmojiSnapcodeImage {
                    
                    if let snapcodeImage = snapcodeImage {
                        System.shared.snapcode = bitmojiSnapcodeImage
                        self.bitmojiSnapcode = bitmojiSnapcodeImage
                        self.defaultSnapcode = snapcodeImage
                        self.showSnapcodeSelectionUI()
                    } else {
                        self.fetchSnapcodeIndicator.dismiss(animated: false)
                        self.fetchSnapcodeIndicator.animation.animationFinished()
                        System.shared.snapcode = bitmojiSnapcodeImage
                        self.nextButtonWasPressed()
                    }
                    
                } else if let snapcodeImage = snapcodeImage {
                    System.shared.snapcode = snapcodeImage
                    self.fetchSnapcodeIndicator.dismiss(animated: false)
                    self.fetchSnapcodeIndicator.animation.animationFinished()
                    self.nextButtonWasPressed()
                } else {
                    self.showCannotGetSnapcodeError()
                    return
                }
                
            }
        }
    }
    
    func showSnapcodeSelectionUI() {
        fetchSnapcodeIndicator.dismiss(animated: false)
        fetchSnapcodeIndicator.animation.animationFinished()
        
        snapcodeImageView.image = bitmojiSnapcode
        
        usernameTextField.isUserInteractionEnabled = false
        usernameTextField.frame.origin.y = snapcodeImageView.frame.maxY + 40
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
        hapticFeedback.impactOccurred()
        
        view.addSubview(snapcodeSelectionToolbar)
        view.addSubview(toolbarInsturctionsLabel)
        view.addSubview(usernameTextField)
        view.addSubview(snapcodeSelectionInsturctionsLabel)
        view.addSubview(snapcodeSelectionSwitch)
        view.addSubview(snapcodeImageView)
    }
    
    @objc func bitmojiSwitchWasTapped(toggle: UISwitch) {
        if toggle.isOn {
            snapcodeImageView.image = bitmojiSnapcode
            System.shared.snapcode = bitmojiSnapcode
        } else {
            snapcodeImageView.image = defaultSnapcode
            System.shared.snapcode = defaultSnapcode
        }
    }
    
    @objc func backButtonWasPressed() {
        let fetchSnapcodeViewController = FetchSnapcodeViewController()
        System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .reverse, animated: true, completion: nil)
    }
    
    @objc func nextButtonWasPressed() {
        let selectPhotoViewController = SelectPhotoViewController()
        System.shared.appDelegate().pageViewController?.setViewControllers([selectPhotoViewController], direction: .forward, animated: true, completion: nil)
    }
    
}
