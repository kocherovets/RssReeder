//
//  DBSource+CoreDataProperties.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//
//

import Foundation
import CoreData


extension DBSource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBSource> {
        return NSFetchRequest<DBSource>(entityName: "DBSource")
    }

    @NSManaged public var active: Bool
    @NSManaged public var url: String
    @NSManaged public var news: NSSet

}

// MARK: Generated accessors for news
extension DBSource {

    @objc(addNewsObject:)
    @NSManaged public func addToNews(_ value: DBNews)

    @objc(removeNewsObject:)
    @NSManaged public func removeFromNews(_ value: DBNews)

    @objc(addNews:)
    @NSManaged public func addToNews(_ values: NSSet)

    @objc(removeNews:)
    @NSManaged public func removeFromNews(_ values: NSSet)

}
