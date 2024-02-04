//
//  GalleryViewController.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 02/02/24.
//

import UIKit
import SystemConfiguration
import Reachability
import GoogleSignIn
import Gemini
import Kingfisher

enum CustomAnimationType {
    case custom1
    fileprivate func layout(withParentView parentView: UIView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewPagingFlowLayout()
        if UIDevice.current.userInterfaceIdiom == .pad{
            layout.itemSize = CGSize(width: parentView.bounds.width / 1.6, height:parentView.frame.height/2.2)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 130, bottom: 0, right: 130)
            layout.minimumLineSpacing = 50
            layout.scrollDirection = .horizontal
            return layout
        }else{
            layout.itemSize = CGSize(width: parentView.bounds.width - 90, height:parentView.frame.height/2.2)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 50)
            layout.minimumLineSpacing = 20
            layout.scrollDirection = .horizontal
            return layout
        }
        
    }
}
class UICollectionViewPagingFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let offset = isVertical ? collectionView.contentOffset.y : collectionView.contentOffset.x
        let velocity = isVertical ? velocity.y : velocity.x
        
        let flickVelocityThreshold: CGFloat = 0.2
        let currentPage = offset / pageSize
        
        if abs(velocity) > flickVelocityThreshold {
            let nextPage = velocity > 0.0 ? ceil(currentPage) : floor(currentPage)
            let nextPosition = nextPage * pageSize
            return isVertical ? CGPoint(x: proposedContentOffset.x, y: nextPosition) : CGPoint(x: nextPosition, y: proposedContentOffset.y)
        } else {
            let nextPosition = round(currentPage) * pageSize
            return isVertical ? CGPoint(x: proposedContentOffset.x, y: nextPosition) : CGPoint(x: nextPosition, y: proposedContentOffset.y)
        }
    }
    
    private var isVertical: Bool {
        return scrollDirection == .vertical
    }
    
    private var pageSize: CGFloat {
        if isVertical {
            return itemSize.height + minimumInteritemSpacing
        } else {
            return itemSize.width + minimumLineSpacing
        }
    }
}

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var GalleryclcView: GeminiCollectionView!
    @IBOutlet weak var logout: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let reachability = try! Reachability()
    
    var gallaryImage : [Apidata] = []
    var databasedata : [Apidata] = []
    var ImageGalleryData : [String] = []
    var downloadedImages: [UIImage] = []
    
    var currentPage = 0
    var previousOffset: CGFloat = 0
    var lastContentOffset: CGFloat = 0
    var index = 0
    var indexscroll = 0
    public var animationType = CustomAnimationType.custom1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GalleryclcView.collectionViewLayout = animationType.layout(withParentView: view)
        GalleryclcView.decelerationRate = UIScrollView.DecelerationRate.fast
        if UIDevice.current.userInterfaceIdiom == .pad{
            GalleryclcView.gemini
                .customAnimation()
                .translation(x:0,y: 90,z:25)
                .rotationAngle(x:0,y: 0,z:0)
                .ease(.easeOutExpo)
                .shadowEffect(.fadeIn)
                .maxShadowAlpha(0.3)
        }
        else{
            GalleryclcView.gemini
                .customAnimation()
                .translation(x:0,y: 50,z:5)
                .rotationAngle(x:0,y: 0,z:0)
                .ease(.easeOutExpo)
                .shadowEffect(.fadeIn)
                .maxShadowAlpha(0.3)
        }
        pageControl.numberOfPages = 20
        pageControl.currentPage = 0
        
    }
    
    func checkdata(){
        DispatchQueue.main.async { [self] in
            if Constants.ImageDataPersistent?.isEmpty == false || Constants.ImageDataPersistent?.count != 0{
                if databasedata.count != 0 {
                    getdata()
                    GalleryclcView.reloadData()
                }else{
                    DatabaseManager.shared.deleteAllDataFromGalleryData()
                    fetchData()
                    getdata()
                }
            }else{
                fetchData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkdata()
        
    }
    
    func saveData(){
        // Call the function to check if the database has more than 20 entries
        DatabaseManager.shared.hasMoreThan20Entries { [self] hasMoreEntries in
            if let hasMoreEntries = hasMoreEntries {
                if hasMoreEntries {
                    print("The database has more than 20 entries.")
                    DatabaseManager.shared.deleteAllDataFromGalleryData()
                    for i in 0..<gallaryImage.count {
                        let isSaved = DatabaseManager.shared.SaveImageDetails(gallaryImage[i])
                        Constants.ImageDataPersistent?.append(gallaryImage[i].largeImageURL)
                        ImageGalleryData.append(gallaryImage[i].largeImageURL)
                        if isSaved {
                            print("Data saved successfully")
                        } else {
                            print("Failed to save data")
                        }
                    }
                    // Perform your actions here if the database has more than 20 entries
                } else {
                    print("The database does not have more than 20 entries.")
                    for i in 0..<gallaryImage.count {
                        let isSaved = DatabaseManager.shared.SaveImageDetails(gallaryImage[i])
                        Constants.ImageDataPersistent?.append(gallaryImage[i].largeImageURL)
                        ImageGalleryData.append(gallaryImage[i].largeImageURL)
                        if isSaved {
                            print("Data saved successfully")
                        } else {
                            print("Failed to save data")
                        }
                    }
                }
            } else {
                print("Failed to determine if the database has more than 20 entries.")
            }
        }
        
        
    }
    
    
    func getdata(){
        databasedata.removeAll()
        DatabaseManager.shared.getGalleryData { [self] galleryData in
            if let galleryData = galleryData {
                print("Gallery data retrieved successfully: \(galleryData)")
                self.databasedata = galleryData
                pageControl.numberOfPages = databasedata.count
            } else {
                print("Failed to retrieve gallery data")
            }
        }
    }
    
    func startMonitoringNetwork() {
        reachability.whenReachable = { reachability in
            print("Network is reachable")
        }
        
        reachability.whenUnreachable = { reachability in
            print("Network is not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    func downloadImages() {
        for url in ImageGalleryData {
            let url = URL(string: url)!
            
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    self.downloadedImages.append(value.image)
                    if self.downloadedImages.count == self.databasedata.count {
                        print("All images downloaded:", self.downloadedImages)
                    }
                case .failure(let error):
                    print("Error downloading image:", error.localizedDescription)
                }
            }
        }
    }
    
    func stopMonitoringNetwork() {
        reachability.stopNotifier()
    }
    
    func isNetworkAvailable() -> Bool {
        return reachability.connection != .unavailable
    }
    
    func fetchData() {
        APIManager.shared.fetchDataFromAPI { apidata, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            if let apidata = apidata {
                
                self.gallaryImage = apidata
                self.saveData()
                DispatchQueue.main.async {
                    self.GalleryclcView.reloadData()
                    self.getdata()
                }
            }
        }
    }
    
    @IBAction func btnProfilePage(_ sender: UIButton) {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        navigationController?.pushViewController(next!, animated: true)

    }
    
    @IBAction func logout(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            GIDSignIn.sharedInstance()?.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    func documentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
}


extension GalleryViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.databasedata.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        downloadImages()
        let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryViewCell", for: indexPath) as! GalleryViewCell
        DispatchQueue.main.async { [self] in
            if databasedata.count == 0{
                getdata()
            }else{
                print("data is found")
            }
            cell1.ImgGallary.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
            cell1.ImgGallary.layer.borderWidth = 1
            cell1.ImgGallary.layer.cornerRadius = 25
            cell1.ImgGallary.contentMode = .scaleAspectFill
            let url = URL(string: gallaryImage[indexPath.item].largeImageURL)
            cell1.ImgGallary.kf.setImage(with: url)
            cell1.ImgGallary.image = UIImage(named: "placeholderImage")
            let imageURLString = databasedata[indexPath.item].largeImageURL
            if let imageURL = URL(string: imageURLString) {
                cell1.ImgGallary.kf.setImage(with: imageURL)
            } else {
                cell1.ImgGallary.image = UIImage(named: "placeholderImage")
            }
        }
        return cell1
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GeminiCell {
            self.GalleryclcView.animateCell(cell)
            indexscroll = indexPath.row
            
        }
    }
}
extension GalleryViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        GalleryclcView.isScrollEnabled = true
        GalleryclcView.animateVisibleCells()
        let pageWidth = scrollView.bounds.width
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = currentPage
        
        let xPoint = scrollView.contentOffset.x + scrollView.frame.width / 2
        let yPoint = scrollView.frame.height / 2
        let center = CGPoint(x: xPoint, y: yPoint)
        if let ip = GalleryclcView.indexPathForItem(at: center) {
            self.index = ip.row
        }
        lastContentOffset = scrollView.contentOffset.x
        GalleryclcView.reloadData()
        
    }
    
    
}






