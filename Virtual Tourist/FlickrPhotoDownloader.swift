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

    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}