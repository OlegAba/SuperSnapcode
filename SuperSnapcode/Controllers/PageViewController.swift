import UIKit

class PageViewController: UIPageViewController {
    
    init(firstViewController: UIViewController) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        setViewControllers([firstViewController], direction: .forward, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

