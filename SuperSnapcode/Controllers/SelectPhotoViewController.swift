import UIKit
import Photos

class SelectPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIToolbarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var photosCollectionView: UICollectionView!
    var toolBar: UIToolbar!
    var currentAlbumLabel: UILabel!
    var albumsTableView: UITableView!
    var statusBarView: UIView!
    
    var photoAlbums = [PhotoAlbum]()
    var currentPhotoAlbum: PhotoAlbum!
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        if view.isIPhoneX() {
            view.frame.size.height -= 34.0
        }
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 45, width: view.frame.size.width, height: 45))
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.snapBlack
        
        let backBarButton = UIBarButtonItem(title: "Back", style:.plain, target: self, action: #selector(backButtonWasPressed))
        backBarButton.tintColor = UIColor.snapYellow
        
        let selectAlbumButton: UIBarButtonItem = UIBarButtonItem(title: "Albums", style:.plain, target: self, action: #selector(animateTableView))
        selectAlbumButton.tintColor = UIColor.snapYellow

        toolBar.items = [backBarButton, UIBarButtonItem.flexibleSpace(), selectAlbumButton]
        
        currentAlbumLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width * 0.5, height: 45))
        currentAlbumLabel.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - toolBar.frame.height / 2)
        currentAlbumLabel.text = "All Photos"
        currentAlbumLabel.textColor = .white
        currentAlbumLabel.textAlignment = .center
        
        photosCollectionView = UICollectionView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: view.frame.height - (statusBarHeight + toolBar.frame.height)), collectionViewLayout: UICollectionViewFlowLayout())
        photosCollectionView.register(SelectPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "SelectPhotoCollectionViewCellReuseIdentifier")
        photosCollectionView.backgroundColor = UIColor.snapBlack
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        
        albumsTableView = UITableView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height))
        albumsTableView.backgroundColor = UIColor.snapBlack
        albumsTableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: "AlbumTableViewCellReuseIdentifier")
        albumsTableView.dataSource = self
        albumsTableView.delegate = self
        albumsTableView.separatorColor = UIColor.snapYellow
        albumsTableView.preservesSuperviewLayoutMargins = false
        albumsTableView.separatorInset = UIEdgeInsets.zero
        albumsTableView.layoutMargins = UIEdgeInsets.zero
        albumsTableView.tableFooterView = UIView()
        albumsTableView.isHidden = true
        
        statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor.snapBlack
        
        let photoPremissionStatus = PHPhotoLibrary.authorizationStatus()
        if photoPremissionStatus == PHAuthorizationStatus.authorized {
            photoAlbums = ImageManager.shared.grabAllPhotoAlbums()
            currentPhotoAlbum = ImageManager.shared.findPhotoAlbum(photoAlbums: photoAlbums, name: currentAlbumLabel.text!)!
            view.addSubview(photosCollectionView)
            view.addSubview(albumsTableView)
        }
        
        view.addSubview(statusBarView)
        view.addSubview(toolBar)
        view.addSubview(currentAlbumLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !photosCollectionView.isDescendant(of: view) {
            ImageManager.shared.requestPhotoLibraryPermission { (authorized: Bool) in
                DispatchQueue.main.async {
                    if authorized {
                        self.photoAlbums = ImageManager.shared.grabAllPhotoAlbums()
                        self.currentPhotoAlbum = ImageManager.shared.findPhotoAlbum(photoAlbums: self.photoAlbums, name: self.currentAlbumLabel.text!)!
                        
                        self.view.addSubview(self.photosCollectionView)
                        self.view.addSubview(self.albumsTableView)
                        self.view.bringSubviewToFront(self.toolBar)
                        self.view.bringSubviewToFront(self.currentAlbumLabel)

                    } else {
                        let deniedPhotoLibraryPermissionViewController = DeniedPhotoLibraryPermissionViewController()
                        System.shared.appDelegate().pageViewController?.setViewControllers([deniedPhotoLibraryPermissionViewController], direction: .reverse, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPhotoAlbum.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectPhotoCollectionViewCellReuseIdentifier", for: indexPath) as? SelectPhotoCollectionViewCell else { return UICollectionViewCell() }
        ImageManager.shared.grabThumnailFrom(photoAlbum: currentPhotoAlbum, index: indexPath.row) { (image: UIImage?) in
            
            DispatchQueue.main.async {
                guard let thumbnail = image else { return }
                cell.setImage(image: thumbnail)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 2.0
        let numberOfItermsPerRow: CGFloat = 3.0
        let sizePerItem = (view.frame.width - (2 * spacing)) / numberOfItermsPerRow
        return CGSize(width: sizePerItem, height: sizePerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.isUserInteractionEnabled = false
        
        let asset = currentPhotoAlbum.assets.object(at: indexPath.row)
        ImageManager.shared.grabFullPhotoFromAsset(asset: asset, completion: { (image: UIImage?) in
            if let image = image {
                System.shared.imageToCrop = image
                
                let cropWallpaperViewController = CropWallpaperViewController()
                cropWallpaperViewController.imageToCrop = image
                System.shared.appDelegate().pageViewController?.setViewControllers([cropWallpaperViewController], direction: .forward, animated: true, completion: nil)
            } else {
                self.view.isUserInteractionEnabled = true
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumTableViewCellReuseIdentifier", for: indexPath) as? AlbumTableViewCell else { return UITableViewCell()}
        cell.setText(photoAlbums[indexPath.row].name)
        cell.setAlbumCount(photoAlbums[indexPath.row].assets.count)
        
        if (photoAlbums.count - 1) == indexPath.row {
            let initialSelectionIndexPath = IndexPath(row: 0, section: 0)
            self.albumsTableView.selectRow(at: initialSelectionIndexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentCell = self.albumsTableView.cellForRow(at: indexPath) as? AlbumTableViewCell, let selectedAlbumName = currentCell.albumTitleLabel.text else { return }
        guard selectedAlbumName != currentAlbumLabel.text! else { self.animateTableView(); return }
        
        currentAlbumLabel.text = selectedAlbumName
        currentPhotoAlbum = ImageManager.shared.findPhotoAlbum(photoAlbums: self.photoAlbums, name: selectedAlbumName)
        
        animateTableView()
        photosCollectionView.reloadData()
        photosCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func animateTableView() {
        view.isUserInteractionEnabled = false
        
        if self.albumsTableView.isHidden {
            self.albumsTableView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.albumsTableView.frame = CGRect(x: 0, y: self.statusBarHeight, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: { (finished: Bool) in
                self.view.isUserInteractionEnabled = true
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.albumsTableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: { (finished: Bool) in
                self.albumsTableView.isHidden = true
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    @objc func backButtonWasPressed() {
        view.isUserInteractionEnabled = false
        
        let fetchSnapcodeViewController = FetchSnapcodeViewController()
        
        System.shared.appDelegate().pageViewController?.setViewControllers([fetchSnapcodeViewController], direction: .reverse, animated: true, completion: nil)
    }
}
