//
//  News+CoreDataProperties.swift
//  
//
//  Created by Deeokay on 2017/6/2.
//
//

import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News")
    }

    @NSManaged public var date: String?
    @NSManaged public var descr: String?
    @NSManaged public var link: String?
    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}
