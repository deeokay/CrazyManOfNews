//
//  Aimi+CoreDataProperties.swift
//  
//
//  Created by Deeokay on 2017/6/2.
//
//

import Foundation
import CoreData


extension Aimi {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Aimi> {
        return NSFetchRequest<Aimi>(entityName: "Aimi")
    }

    @NSManaged public var aid: Int64
    @NSManaged public var dic: NSObject?
    @NSManaged public var time: String?
    @NSManaged public var type: Int64

}
