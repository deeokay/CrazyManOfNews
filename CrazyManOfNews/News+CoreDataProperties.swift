//
//  News+CoreDataProperties.swift
//  
//
//  Created by Dee Money on 2016/11/8.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension News {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<News> {
        return NSFetchRequest<News>(entityName: "News");
    }

    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var link: String?
    @NSManaged public var descr: String?
    @NSManaged public var date: String?
    @NSManaged public var source: String?

}
