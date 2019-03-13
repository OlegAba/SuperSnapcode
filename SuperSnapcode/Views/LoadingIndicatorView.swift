import UIKit
import NVActivityIndicatorView

class LoadingIndicatorView: UIView {
    
    var loadingIndicator: NVActivityIndicatorView!
    var loadingLabel: UILabel!
    
    var text: String!
    var color: UIColor!
    
    init(frame: CGRect, text: String, color: UIColor) {
        super.init(frame: frame)
        self.text = text
        self.color = color
        
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: frame.height * 0.5, height: frame.height * 0.5),
                                                   type: NVActivityIndicatorType.ballScaleRippleMultiple,
                                                   color: color,
                                                   padding: nil)
        loadingIndicator.center.x = center.x
        
        let loadingLabelY = loadingIndicator.frame.maxY + (frame.height * 0.1)
        loadingLabel = UILabel(frame: CGRect(x: 0, y: loadingLabelY, width: frame.width, height: frame.height - loadingLabelY))
        loadingLabel.text = text
        loadingLabel.textColor = color
        loadingLabel.textAlignment = .center
        loadingLabel.adjustsFontSizeToFitWidth = true
    }
    
    func startAnimating() {
        addSubview(loadingIndicator)
        addSubview(loadingLabel)
        loadingIndicator.startAnimating()
    }
    
    func stopAnimating() {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
        loadingLabel.removeFromSuperview()
    }
    
}
