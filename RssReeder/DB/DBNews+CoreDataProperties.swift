//
//  DBNews+CoreDataProperties.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//
//

import Foundation
import CoreData


extension DBNews {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNews> {
        return NSFetchRequest<DBNews>(entityName: "DBNews")
    }

    @NSManaged public var guid: String
    @NSManaged public var sourceTitle: String
    @NSManaged public var title: String
    @NSManaged public var body: String
    @NSManaged public var time: Date
    @NSManaged public var imageURL: String
    @NSManaged public var unread: Bool
    @NSManaged public var source: DBSource

}

extension DBNews : Identifiable {

}
