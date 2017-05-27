//
//  Model+CoreDataProperties.swift
//  
//
//  Created by Deeokay on 2017/5/6.
//
//

import Foundation
import CoreData


extension Model {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Model> {
        return NSFetchRequest<Model>(entityName: "Model")
    }

    @NSManaged public var id: String?
    @NSManaged public var isGif: Bool
    @NSManaged public var isLike: Bool
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}
