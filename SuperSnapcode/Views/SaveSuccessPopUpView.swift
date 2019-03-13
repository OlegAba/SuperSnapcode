import UIKit

class SaveSuccessPopUpView: UIView {
    
    var successIconImageView: UIImageView!
    var successLabel: UILabel!
    var lineBreakOneView: UIView!
    var openPhotosImageView: UIImageView!
    var openPhotosIconButton: UIButton!
    var lineBreakTwoView: UIView!
    var lineBreakThreeView: UIView!
    var newImageView: UIImageView!
    var newIconButton: UIButton!
    var rateImageView: UIImageView!
    var rateIconButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        backgroundColor = UIColor.snapBlack
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        successIconImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 40, height: 40))
        successIconImageView.center.x = center.x
        successIconImageView.frame.origin.y = frame.origin.y + 10.0
        let successIconImage = UIImage(named: "success")?.withRenderingMode(.alwaysTemplate)
        successIconImageView.image = successIconImage
        successIconImageView.tintColor = UIColor.snapWhite
        successIconImageView.contentMode = .scaleAspectFill
        
        successLabel = UILabel()
        successLabel.text = "Success"
        successLabel.font = successLabel.font.withSize(15)
        successLabel.sizeToFit()
        successLabel.center.x = center.x
        successLabel.frame.origin.y = successIconImageView.frame.maxY + 5.0
        successLabel.textColor = UIColor.snapWhite
        
        lineBreakOneView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 1.0))
        lineBreakOneView.center.x = center.x
        lineBreakOneView.frame.origin.y = successLabel.frame.maxY + 15.0
        lineBreakOneView.backgroundColor = UIColor.black
        
        openPhotosImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        let openPhotosImage = UIImage(named: "photo-library")?.withRenderingMode(.alwaysTemplate)
        openPhotosImageView.image = openPhotosImage
        openPhotosImageView.tintColor = UIColor.snapYellow
        openPhotosImageView.contentMode = .scaleAspectFill
        
        let openPhotosFrame = CGRect(x: 0, y: 0, width: frame.width, height: 60.0)
        openPhotosIconButton = IconButton(frame: openPhotosFrame, icon: openPhotosImageView, text: "Open Photo Library", textColor: UIColor.snapYellow, fontSize: 15.0, spaceBetween: 10.0)
        openPhotosIconButton.center.x = center.x
        openPhotosIconButton.frame.origin.y = lineBreakOneView.frame.maxY
        openPhotosIconButton.addTarget(self, action: #selector(goToPhotosButtonWasPressed), for: .touchUpInside)
        
        lineBreakTwoView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 1.0))
        lineBreakTwoView.center.x = center.x
        lineBreakTwoView.frame.origin.y = openPhotosIconButton.frame.maxY
        lineBreakTwoView.backgroundColor = .black
        
        lineBreakThreeView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1.0, height: lineBreakTwoView.frame.origin.y - lineBreakOneView.frame.origin.y))
        lineBreakThreeView.center.x = center.x
        lineBreakThreeView.frame.origin.y = lineBreakTwoView.frame.maxY
        lineBreakThreeView.backgroundColor = .black
        
        newImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        let newImage = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        newImageView.image = newImage
        newImageView.tintColor = UIColor.snapYellow
        newImageView.contentMode = .scaleAspectFill
        
        let newIconButtonFrame = CGRect(x: 0, y: 0, width: frame.width / 2, height: 60.0)
        newIconButton = IconButton(frame: newIconButtonFrame, icon: newImageView, text: "New", textColor: UIColor.snapYellow, fontSize: 15.0, spaceBetween: 10.0)
        newIconButton.center.x = center.x - (frame.width / 4)
        newIconButton.frame.origin.y = lineBreakTwoView.frame.maxY
        newIconButton.addTarget(self, action: #selector(newButtonWasPressed), for: .touchUpInside)
        
        rateImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
        let rateImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        rateImageView.image = rateImage
        rateImageView.tintColor = UIColor.snapYellow
        rateImageView.contentMode = .scaleAspectFill
        
        let rateIconButtonFrame = CGRect(x: 0, y: 0, width: frame.width / 2, height: 60.0)
        rateIconButton = IconButton(frame: rateIconButtonFrame, icon: rateImageView, text: "Rate App", textColor: UIColor.snapYellow, fontSize: 15.0, spaceBetween: 10.0)
        rateIconButton.center.x = center.x + (frame.width / 4)
        rateIconButton.frame.origin.y = lineBreakTwoView.frame.maxY
        rateIconButton.addTarget(self, action: #selector(rateButtonWasPressed), for: .touchUpInside)
        
        addSubview(successIconImageView)
        addSubview(successLabel)
        addSubview(lineBreakOneView)
        addSubview(openPhotosIconButton)
        addSubview(lineBreakTwoView)
        addSubview(lineBreakThreeView)
        addSubview(newIconButton)
        addSubview(rateIconButton)
    }
    
    
    @objc func goToPhotosButtonWasPressed() {
        guard let generalSettingsURL = URL(string: "photos-redirect://") else { return }
        if UIApplication.shared.canOpenURL(generalSettingsURL) {
            UIApplication.shared.open(generalSettingsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else { return }
        
        newButtonWasPressed()
    }
    
    @objc func newButtonWasPressed() {
        System.shared.imageToCrop = nil
        System.shared.snapcode = nil
        System.shared.wallpaper = nil
        
        let fetchSnapcodeViewController = FetchSnapcodeViewController()
        System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func rateButtonWasPressed() {
        let appID = "1442173056"
        let appReviewURL = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)"
        
        guard let url = URL(string: appReviewURL), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
