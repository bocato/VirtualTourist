//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private enum BottomBarButtonTitle: String {
    case newCollection = "New Collection"
    case removeSelectedPictures = "Remove Selected Pictures"
}

private struct Constants {
    static let numberOfItemsInCollectionViewRow: CGFloat = 3
    static let minimumCollectionViewItemSpacing: CGFloat = 2
}

class PhotoAlbumViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomToolbarCenterButton: UIBarButtonItem!
    
    // MARK: - Properties
    var mapAnnotation: MKAnnotation!
    var selectedItemsCount = 0 {
        didSet {
            updateBottomToolbarCenterButton()
        }
    }
    private var fetchedResultsController: NSFetchedResultsController<PersistedPhoto>!
    private var mapPin: MapPin!
    private var mapPinPhotosCount: Int {
        guard let count = mapPin.photos?.count else {
            return 0
        }
        return count
    }
    private var pages: Int?
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // MARK: - Computed Properties
    var amountOfPersistedPhotosWithData: Int {
        var photosWithData = 0
        guard let sections = fetchedResultsController.sections else { return 0 }
        for section in sections {
            if let objects = section.objects as? [PersistedPhoto] {
                photosWithData += objects.filter( { $0.data != nil } ).count
            }
        }
        return photosWithData
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureMapView()
        loadViewData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: - Configuration
    private func configureCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionViewFlowLayout.minimumInteritemSpacing = Constants.minimumCollectionViewItemSpacing
        collectionViewFlowLayout.minimumLineSpacing = Constants.minimumCollectionViewItemSpacing
        let dimension = (view.frame.width - 2 * Constants.minimumCollectionViewItemSpacing) / Constants.numberOfItemsInCollectionViewRow
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func configureMapView() {
        mapView.addAnnotation(mapAnnotation)
        mapView.selectAnnotation(mapAnnotation, animated: true)
        mapView.setRegion(MKCoordinateRegionMake(mapAnnotation.coordinate, MKCoordinateSpanMake(0.5, 0.5)), animated: true)
    }
    
    private func configureNSFetchedResultsController(onSuccess success: @escaping (() -> ()), onFailure failure: ((PersistenceError?) -> ())? = nil){
        // Get the persisted MapPin
        let mapPinId = CoreDataController.shared.getPinId(for: mapAnnotation.coordinate)
        guard let mapPin = CoreDataController.shared.getMapPin(with: mapPinId) else {
            fatalError("Could not find mapPin with id = \(mapPinId)")
        }
        self.mapPin = mapPin
        // Configure the NSFetchedResultsController
        let fetchRequest = NSFetchRequest<PersistedPhoto>(entityName: "PersistedPhoto")
        fetchRequest.predicate = NSPredicate(format: "mapPin == %@", mapPin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            success()
        } catch let error {
            debugPrint("error = \(error)")
            failure?(ErrorFactory.buildPersistenceError(with: .couldNotFetchDataFromPersistenceLayer))
        }
    }
    
    // MARK: - Helpers
    func updateBottomToolbarCenterButton() {
        bottomToolbarCenterButton.title = selectedItemsCount > 0 ? BottomBarButtonTitle.removeSelectedPictures.rawValue : BottomBarButtonTitle.newCollection.rawValue
        if let persistedPhotosCount = fetchedResultsController.fetchedObjects?.count {
            bottomToolbarCenterButton.isEnabled = amountOfPersistedPhotosWithData == persistedPhotosCount
        }
    }
    
    func updateSelectedItemsCountForTappedCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath){
        self.selectedItemsCount = collectionView.indexPathsForSelectedItems?.count ?? 0
    }
    
    func getRandomPage() -> Int? {
        guard let pages = pages else {
            return nil
        }
        return Int(arc4random_uniform(UInt32(pages))+1)
    }
    
    // MARK: - Data
    func loadViewData(){
        configureNSFetchedResultsController(onSuccess: {
            if self.mapPinPhotosCount == 0 {
                DispatchQueue.main.async {
                    self.loadPhotos()
                }
            }
            self.updateBottomToolbarCenterButton()
        }, onFailure: { (persistenceError) in
            AlertHelper.showAlert(in: self, withTitle: "Error", message: persistenceError?.message ?? ErrorMessage.unknown.rawValue, leftAction: UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                self.loadViewData()
            }), rightAction: UIAlertAction(title: "Ok", style: .default, handler: nil))
        })
    }
    
    // MARK: - API Requests
    func loadPhotos(for page: Int = 1) {
        FlickrService().findPhotos(atLatitude: mapAnnotation.coordinate.latitude, longitude: mapAnnotation.coordinate.longitude, page: page, success: { (photosSearchResponse) in
    
            guard let photos = photosSearchResponse?.photos?.photo, let pages = photosSearchResponse?.photos?.pages, photos.count > 0  else {
                self.collectionView.isHidden = true
                return
            }
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
            }
            
            self.pages = pages
            
            for photo in photos {
                CoreDataController.shared.addPersistedPhoto(for: photo, mapPin: self.mapPin, success: { persistedPhoto in
                    debugPrint("added \(persistedPhoto)")
                }, onFailure: { (persistenceError) in
                    debugPrint("persistenceError = \(persistenceError.debugDescription)")
                })
            }
        
            self.updateBottomToolbarCenterButton()
        
        }, onFailure: { (serviceError) in
            
            AlertHelper.showAlert(in: self, withTitle: "Error", message: serviceError?.message ?? ErrorMessage.unknown.rawValue, leftAction: UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                self.loadPhotos()
            }), rightAction: UIAlertAction(title: "Ok", style: .default, handler: nil))
            
        })
    }
    
    func deleteAllObjectsAndReloadWithRandomPage() {
        
        guard let objectsToDelete = fetchedResultsController.fetchedObjects else {
            return
        }
        
        for photo in objectsToDelete {
            CoreDataController.shared.viewContext.delete(photo)
        }
        
        CoreDataController.shared.saveViewContext()
        
        if let randomPage = getRandomPage() {
            loadPhotos(for: randomPage)
        } else {
            loadPhotos()
        }
        
    }
    
    func deleteSelectedObjects(){
        
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        for indexPath in selectedIndexPaths {
            let objectToDelete = fetchedResultsController.object(at: indexPath)
            CoreDataController.shared.viewContext.delete(objectToDelete)
        }
        
        CoreDataController.shared.saveViewContext()
        
        self.selectedItemsCount = 0
        
    }
    
    // MARK: - IBActions
    @IBAction func bottomToolbarCenterButtonDidReceiveTouchUpInside(_ sender: UIBarButtonItem) {
        if selectedItemsCount == 0 {
            deleteAllObjectsAndReloadWithRandomPage()
        } else {
            deleteSelectedObjects()
        }
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        if let data = photo.data {
            cell.configureWithImageData(data)
            cell.stopLoading()
        } else { // load image data
            cell.startLoading(backgroundColor: UIColor.white, activityIndicatorViewStyle: .white, activityIndicatorColor: UIColor.lightGray)
            if let photoURL = photo.imageURL() {
                cell.downloadTask = FlickrService().downloadPhoto(fromURL: photoURL, success: { (data) in
                    guard let data = data else {
                        cell.configureWithImageNamed("no-image")
                        return
                    }
                    photo.data = data
                    cell.configureWithImageData(data)
                }, onFailure: { (serviceError) in
                    cell.configureWithImageNamed("no-image")
                }, onCompletion: {
                    cell.stopLoading()
                })
            }
        }
        
        return cell
        
    }
    
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let photo = fetchedResultsController.object(at: indexPath)
        return photo.data != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateSelectedItemsCountForTappedCollectionView(collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateSelectedItemsCountForTappedCollectionView(collectionView, indexPath: indexPath)
    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: { _ in
            self.updateBottomToolbarCenterButton()
        })
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        updateBottomToolbarCenterButton()
    }
    
}
