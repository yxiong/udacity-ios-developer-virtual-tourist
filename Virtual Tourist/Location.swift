//
//  Location.swift
//  Virtual Tourist
//
//  Created by Ying Xiong on 12/30/15.
//  Copyright © 2015 Ying Xiong. All rights reserved.
//

import CoreData

class Location : NSManagedObject {

    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let ID = "id"
    }

    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        id = dictionary[Keys.ID] as! Int
        latitude = dictionary[Keys.Latitude]! as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
}