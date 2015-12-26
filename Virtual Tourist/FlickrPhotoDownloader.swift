//
//  FlickrPhotoDownloader.swift
//  Virtual Tourist
//
//  Created by Ying Xiong on 12/26/15.
//  Copyright © 2015 Ying Xiong. All rights reserved.
//

import Foundation

class FlickrPhotoDownloader {
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "7b9c18a5e8b82db70e30edab7face42b"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0

    init() { }
}