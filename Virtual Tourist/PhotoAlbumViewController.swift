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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    var pinLocation: Location?
    var flickrPhotoDownloader: FlickrPhotoDownloader?
    var images: [UIImage]?
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

        do {
            try fetchedResultsController.performFetch()
        } catch {}
        fetchedResultsController.delegate = self

        flickrPhotoDownloader = FlickrPhotoDownloader()
        images = [UIImage]()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if pinLocation!.photos.isEmpty {
            flickrPhotoDownloader!.getImageURLsFromFlickrByByLatLong((pinLocation?.latitude.doubleValue)!, longitude: (pinLocation?.longitude.doubleValue)!) {(imageURLs) -> Void in

                for imageURL in imageURLs {
                    let dictionary: [String: AnyObject] = [
                        Photo.Keys.ID: 0,
                        Photo.Keys.ImagePath: "\(imageURL)"
                    ]
                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                    photo.location = self.pinLocation!
                }
                CoreDataStackManager.sharedInstance().saveContext()

                var urlIndex = 0
                while self.images!.count < self.NUM_PHOTOS_IN_COLLECTION {
                    let imageURL = imageURLs[urlIndex++]
                    if let imageData = NSData(contentsOfURL: imageURL) {
                        self.images!.append(UIImage(data: imageData)!)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView.reloadData()
                        })
                    }
                }
            }
        } else {
            print(self.pinLocation!.photos)
        }
        collectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_PHOTOS_IN_COLLECTION
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoAlbumCollectionViewCell", forIndexPath: indexPath) as! PhotoAlbumCollectionViewCell
        if (indexPath.row < images!.count) {
            cell.imageView?.image = images![indexPath.row]
        }
        return cell
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
}