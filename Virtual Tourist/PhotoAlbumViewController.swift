//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Ying Xiong on 12/25/15.
//  Copyright © 2015 Ying Xiong. All rights reserved.
//

import MapKit
import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    var mapCenter: CLLocationCoordinate2D?
    var flickrPhotoDownloader: FlickrPhotoDownloader?
    var images: [UIImage]?
    let NUM_PHOTOS_IN_COLLECTION = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: mapCenter!, span: mapSpan)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCenter!
        mapView.addAnnotation(annotation)

        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSizeMake(dimension, dimension)
        collectionView.dataSource = self

        flickrPhotoDownloader = FlickrPhotoDownloader()
        images = [UIImage]()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        flickrPhotoDownloader!.getImageURLsFromFlickrByByLatLong(30.0, longitude: 60.0) {(imageURLs) -> Void in
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
}