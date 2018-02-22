//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Eduardo Sanches Bocato on 15/02/18.
//  Copyright © 2018 Eduardo Sanches Bocato. All rights reserved.
//

import UIKit
import MapKit

private struct Defaults {
    private init() {}
    static let tapPinsToDeleteButtonHeight: CGFloat = 64
    static let photoAlbumViewControllerSegueIdentifier = "PhotoAlbumViewControllerSegue"
}

class TravelLocationsMapViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tapPinsToDeleteView: UIView!
    @IBOutlet weak var tapPinsToDeleteViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    override internal var isEditing: Bool {
        didSet {
            updateLayout()
        }
    }
    private var currentSelectedMapAnnotation: MKAnnotation? = nil
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restoreMapData()
    }
    
    // MARK: - Layout
    private func updateLayout() {
        UIView.animate(withDuration: 0.5) {
            self.tapPinsToDeleteView.alpha = self.isEditing ? 1 : 0
            self.tapPinsToDeleteViewHeightConstraint.constant = self.isEditing ? Defaults.tapPinsToDeleteButtonHeight : 0
            self.rightBarButtonItem.title = self.isEditing ? "Done" : "Edit"
        }
    }
    
    // MARK: Helpers
    private func restoreMapData() {
        mapView.startLoading(blur: true, backgroundColor: UIColor.white, activityIndicatorViewStyle: .whiteLarge, activityIndicatorColor: UIColor.lightGray)
        CoreDataController.shared.findAllPins(in: .view, success:  { (pins) in
            self.restorePins(pins: pins)
            self.restoreMapRegion()
        }, onFailure: { (error) in
            AlertHelper.showAlert(in: self, withTitle: "Error", message: error?.localizedDescription ?? ErrorMessage.unknown.rawValue, leftAction: UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                self.restoreMapData()
            }), rightAction: UIAlertAction(title: "Ok", style: .default, handler: nil))
        }, onCompletion: {
            self.mapView.stopLoading()
        })
    }
    
    private func restoreMapRegion() {
        if let region = UserDefaultsHelper.getMapRegion() {
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func restorePins(pins: [MapPin]?) {
        guard let pins = pins else { return }
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func createMapAnnotation(for coordinate: CLLocationCoordinate2D!){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        currentSelectedMapAnnotation = annotation
        mapView.addAnnotation(annotation)
    }
    
    private func updateCurrentMapPineFromMapLongPressGesture(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if !isEditing {
            let touchPoint = longPressGestureRecognizer.location(in: self.mapView)
            let newCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            guard let currentSelectedMapAnnotation = currentSelectedMapAnnotation else {
                createMapAnnotation(for: newCoordinates)
                return
            }
           if currentSelectedMapAnnotation.coordinate != newCoordinates {
                createMapAnnotation(for: newCoordinates)
            }
        }
    }
    
    private func persistCurrentSelectedMapAnnotation() {
        guard let coordinate = currentSelectedMapAnnotation?.coordinate else { return }
        CoreDataController.shared.addMapPin(for: coordinate, context: .view, success: { (pin) in
            debugPrint("Sucessfully persisted \(pin)")
        }, onFailure: { (persistenceError) in
            AlertHelper.showAlert(in: self, withTitle: "Error", message: persistenceError?.message ?? ErrorMessage.unknown.rawValue)
        }, onCompletion: {
            self.currentSelectedMapAnnotation = nil
        })
    }
    
    // MARK: IBActions
    @IBAction func longPressGestureRecognizerDidReceiveActionEvent(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            updateCurrentMapPineFromMapLongPressGesture(sender)
            break
        case .changed:
            updateCurrentMapPineFromMapLongPressGesture(sender)
            break
        case .ended:
            persistCurrentSelectedMapAnnotation()
            break
        default:
            break
        }
    }
    
    @IBAction func rightBarButtonItemDidReceiveTouchUpInside(_ sender: UIBarButtonItem) {
        isEditing = !isEditing
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Defaults.photoAlbumViewControllerSegueIdentifier {
            let pin = sender as! MapPin
            let destination = segue.destination as! PhotoAlbumViewController
            destination.mapPin = pin
        }
    }

}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if isEditing {
            guard let annotation = view.annotation else { return }
            mapView.removeAnnotation(annotation)
            CoreDataController.shared.deletePin(for: annotation.coordinate, success: {
                self.mapView.addAnnotation(annotation)
            })
        } else {
            guard let coordinate = view.annotation?.coordinate else { return }
            CoreDataController.shared.getMapPin(with: CoreDataController.shared.getPinId(for: coordinate), context: .view, success: { (pin) in
                guard let pin = pin else {
                    AlertHelper.showAlert(in: self, withTitle: "Error", message: "Could not find map Pin on local database.")
                    return
                }
                self.performSegue(withIdentifier: Defaults.photoAlbumViewControllerSegueIdentifier, sender: pin)
            }, onFailure: { (persistenceError) in
                AlertHelper.showAlert(in: self, withTitle: "Error", message: persistenceError?.message ?? ErrorMessage.unknown.rawValue)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaultsHelper.persistMapRegion(mapView.region)
    }
    
}
