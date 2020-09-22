//
//  DBSettings+CoreDataProperties.swift
//  RssReeder
//
//  Created by Dmitry Kocherovets on 22.09.2020.
//
//

import Foundation
import CoreData


extension DBSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBSettings> {
        return NSFetchRequest<DBSettings>(entityName: "DBSettings")
    }

    @NSManaged public var updateInterval: Int16

}

extension DBSettings : Identifiable {

}
