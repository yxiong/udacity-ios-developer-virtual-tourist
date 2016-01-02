//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ying Xiong on 12/30/15.
//  Copyright © 2015 Ying Xiong. All rights reserved.
//

import CoreData
import UIKit

class Photo : NSManagedObject {

    struct Keys {
        static let ID = "id"
        static let ImagePath = "image_path"
    }

    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var location: Location?

    var image: UIImage?

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        id = dictionary[Keys.ID] as! Int
        imagePath = dictionary[Keys.ImagePath] as? String
    }

    func getImage(completion: () -> Void) {
    }
}