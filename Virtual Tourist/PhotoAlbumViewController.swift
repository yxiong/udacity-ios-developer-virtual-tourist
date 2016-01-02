//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ying Xiong on 12/25/15.
//  Copyright © 2015 Ying Xiong. All rights reserved.
//

import CoreData
import MapKit
import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomButton: UIButton!

    var pinLocation: Location?
    var selectedCellIndices: NSMutableSet?
    var flickrPhotoDownloader: FlickrPhotoDownloader?
    let NUM_PHOTOS_IN_COLLECTION = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let mapCenter = CLLocationCoordinate2DMake((pinLocation?.latitude.doubleValue)!, (pinLocation?.longitude.doubleValue)!)
        let region = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCenter
        mapView.addAnnotation(annotation)

        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSizeMake(dimension, dimension)
        collectionView.dataSource = self
        collectionView.delegate = self
        selectedCellIndices = NSMutableSet()

        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self

        flickrPhotoDownloader = FlickrPhotoDownloader()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if pinLocation!.photos.isEmpty {
            flickrPhotoDownloader!.getImageURLsFromFlickrByByLatLong((pinLocation?.latitude.doubleValue)!, longitude: (pinLocation?.longitude.doubleValue)!) {(imageURLs) -> Void in

                dispatch_async(dispatch_get_main_queue(), {
                    for imageURL in imageURLs {
                        let dictionary: [String: AnyObject] = [
                            Photo.Keys.ID: 0,
                            Photo.Keys.ImagePath: "\(imageURL)"
                        ]
                        let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                        photo.location = self.pinLocation!
                    }
                    CoreDataStackManager.sharedInstance().saveContext()
                    self.collectionView.reloadData()
                })
            }
        }
        collectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_PHOTOS_IN_COLLECTION
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoAlbumCollectionViewCell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell

        if indexPath.row >= pinLocation!.photos.count {
            cell.imageView.image = nil
            cell.textField.hidden = false
            cell.textField.text = "Loading..."
            return cell
        }

        let photo = pinLocation!.photos[indexPath.row]
        if photo.image == nil {
            cell.imageView.image = nil
            cell.textField.hidden = false
            cell.textField.text = "Loading"
            photo.getImage({() -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let c = self.collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
                    c.textField.hidden = true
                    c.imageView.image = photo.image
                })
            })
        } else {
            cell.textField.hidden = true
            cell.imageView.image = photo.image
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView.alpha = 0.5
        selectedCellIndices?.addObject(indexPath)
        bottomButton.titleLabel?.text = "Remove"
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView.alpha = 1.0
        selectedCellIndices?.removeObject(indexPath)
        if selectedCellIndices?.count == 0 {
            bottomButton.titleLabel?.text = "New Collection"
        }
    }

    @IBAction func backToMap(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.pinLocation!);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController

    }()

    @IBAction func bottomButtonPressed(sender: AnyObject) {
        for var indexPath in selectedCellIndices! {
            let photo = pinLocation!.photos[indexPath.row]
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        selectedCellIndices!.removeAllObjects()

        collectionView.reloadData()
    }
}