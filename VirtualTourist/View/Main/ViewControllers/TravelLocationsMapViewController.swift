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
    private var isAddingPin = false
    
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
    
    // MARK: IBActions
    @IBAction func longPressGestureRecognizerDidReceiveActionEvent(_ sender: UILongPressGestureRecognizer) {
        if !isEditing && !isAddingPin {
            isAddingPin = true
            DispatchQueue.main.async {
                let touchPoint = sender.location(in: self.mapView)
                let newCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinates
                CoreDataController.shared.addMapPin(for: annotation.coordinate, success: { mapPin in
                    self.mapView.addAnnotation(annotation)
                }, onCompletion: {
                    self.isAddingPin = false
                })
            }
        }
    }
    
    @IBAction func rightBarButtonItemDidReceiveTouchUpInside(_ sender: UIBarButtonItem) {
        isEditing = !isEditing
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Defaults.photoAlbumViewControllerSegueIdentifier {
            let annotation = sender as! MKAnnotation
            let destination = segue.destination as! PhotoAlbumViewController
            destination.mapAnnotation = annotation
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
            performSegue(withIdentifier: Defaults.photoAlbumViewControllerSegueIdentifier, sender: view.annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaultsHelper.persistMapRegion(mapView.region)
    }
    
}
