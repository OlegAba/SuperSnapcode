import UIKit
import Photos

class DeniedPhotoLibraryPermissionViewController: UIViewController, UIToolbarDelegate {
    
    var toolBar: UIToolbar!
    var deniedPhotoPermissionTitleLabel: UILabel!
    var deniedPhotoPermissionInstructionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        if view.isIPhoneX() {
            view.frame.size.height -= 34.0
        }
        
        deniedPhotoPermissionTitleLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.2, width: view.frame.width * 0.9, height: 0))
        deniedPhotoPermissionTitleLabel.center.x = view.center.x
        deniedPhotoPermissionTitleLabel.text = "\(System.shared.appName) needs access to your photo library to import and export images"
        deniedPhotoPermissionTitleLabel.font = deniedPhotoPermissionTitleLabel.font.withSize(20.0)
        deniedPhotoPermissionTitleLabel.textAlignment = .center
        deniedPhotoPermissionTitleLabel.textColor = UIColor.snapWhite
        deniedPhotoPermissionTitleLabel.numberOfLines = 2
        deniedPhotoPermissionTitleLabel.adjustsFontSizeToFitWidth = true
        deniedPhotoPermissionTitleLabel.sizeToFit()
        
        deniedPhotoPermissionInstructionsLabel = UILabel(frame: CGRect(x: view.frame.width / 8, y: deniedPhotoPermissionTitleLabel.frame.maxY + 50.0, width: view.frame.width * 0.9, height: 0))
        deniedPhotoPermissionInstructionsLabel.setTextString(string: "1. Tap on the Settings button below \n2. Tap on Photos \n3. Tap Read and Write", withLineSpacing: 15.0)
        deniedPhotoPermissionInstructionsLabel.textAlignment = .left
        deniedPhotoPermissionInstructionsLabel.textColor = UIColor.snapWhite
        deniedPhotoPermissionInstructionsLabel.numberOfLines = 0
        deniedPhotoPermissionInstructionsLabel.sizeToFit()
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 45, width: view.frame.size.width, height: 45))
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.snapBlack
        
        let settingsButton = UIBarButtonItem(title: "Settings", style:.plain, target: self, action: #selector(settingsButtonWasPressed))
        settingsButton.tintColor = UIColor.snapYellow
        
        toolBar.items = [UIBarButtonItem.flexibleSpace(), settingsButton, UIBarButtonItem.flexibleSpace()]
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        view.addSubview(deniedPhotoPermissionTitleLabel)
        view.addSubview(deniedPhotoPermissionInstructionsLabel)
        view.addSubview(toolBar)
    }
    
    @objc func didBecomeActive() {
        ImageManager.shared.requestPhotoLibraryPermission { (authorized) in
            if authorized {
                let fetchViewController = FetchSnapcodeViewController()
                System.shared.appDelegate().pageViewController?.setViewControllers([fetchViewController], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    @objc func settingsButtonWasPressed() {
        let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
