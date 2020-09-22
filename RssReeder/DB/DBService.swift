//
//  DBService.swift
//  MoviesDB
//
//  Created by Dmitry Kocherovets on 28.03.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

public class DBService
{
    private var persistentContainer: NSPersistentContainer = {
        guard
            let modelURL = Bundle(for: DBService.self).url(forResource: "RssReeder", withExtension: "momd") else
        {
            fatalError("Error loading model from bundle")
        }
        guard
            let mom = NSManagedObjectModel(contentsOf: modelURL) else
        {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let container = NSPersistentContainer(name: "RssReeder", managedObjectModel: mom)
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = storeDirectory.appendingPathComponent("RssReeder.sqlite")

//        clear()

        let description = NSPersistentStoreDescription(url: url)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("storeDescription = \(storeDescription)")
            if let error = error as NSError?
                {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var moc: NSManagedObjectContext = {
        let moc = persistentContainer.newBackgroundContext()
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return moc
    }()

    public init()
    {
    }

    private static func clear()
    {
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        print("DBService url  - \(storeDirectory)")
        var url = storeDirectory.appendingPathComponent("RssReeder.sqlite")
        try? FileManager.default.removeItem(at: url)
        url = storeDirectory.appendingPathComponent("RssReeder.sqlite-shm")
        try? FileManager.default.removeItem(at: url)
        url = storeDirectory.appendingPathComponent("RssReeder.sqlite-wal")
        try? FileManager.default.removeItem(at: url)
    }

    func addSource(url: String, active: Bool) -> Error?
    {
        do
        {
            let source = DBSource(context: moc)
            source.url = url
            source.active = active
            moc.insert(source)
            try moc.save()
        }
        catch
        {
            return error
        }
        return nil
    }

    func removeSource(url: String) -> Error?
    {
        DBSource.delete(in: moc,
                        predicate: NSPredicate(format: "url == %@", url))
    }

    func set(active: Bool, forSource url: String) -> Error?
    {
        DBSource.update(in: moc,
                        predicate: NSPredicate(format: "url == %@", url),
                        handler: { (source: DBSource) in
                            source.active = active
                        })
    }

    func source(url: String) -> Result<DBSource, Error>
    {
        do
        {
            let request = NSFetchRequest<DBSource>(entityName: "DBSource")
            request.predicate = NSPredicate(format: "url == %@", url)
            guard let source = try moc.fetch(request).first else
            {
                return .failure(DBServiceError.objectIsNotExists)
            }
            return .success(source)
        }
        catch
        {
            return .failure(error)
        }
    }

    func sources() -> Result<[DBSource], Error>
    {
        do
        {
            let request = NSFetchRequest<DBSource>(entityName: "DBSource")
            let sources = try moc.fetch(request)
            return .success(sources)
        }
        catch
        {
            return .failure(error)
        }
    }

    func set(news items: [State.News], forSource url: String) -> Error?
    {
        switch source(url: url) {
        case .success(let source):
            do
            {
                let request = NSFetchRequest<DBNews>(entityName: "DBNews")
                request.predicate = NSPredicate(format: "(source == %@) AND (unread == false)", source)
                let readItems = try moc.fetch(request)
                let readGUIDs = readItems.map({ $0.guid })

                let request2 = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: DBNews.self))
                request2.predicate = NSPredicate(format: "source == %@", source)
                let batchRequest = NSBatchDeleteRequest(fetchRequest: request2)
                try moc.execute(batchRequest)

                for item in items {

                    var unread = true
                    if let _ = readGUIDs.first(where: { $0 == item.guid }) {
                        unread = false
                    }

                    let news = DBNews(context: moc)
                    news.source = source
                    news.guid = item.guid
                    news.sourceTitle = item.source
                    news.title = item.title
                    news.body = item.body
                    news.time = item.time
                    news.imageURL = item.imageURL
                    news.unread = unread
                    moc.insert(news)
                }
                try moc.save()

                return nil
            }
            catch
            {
                print(error)
                return error
            }
        case .failure(let error):
            return error
        }
    }

    func news(forSource url: String) -> Result<[DBNews], Error>
    {
        switch source(url: url) {
        case .success(let source):
            do
            {
                let request = NSFetchRequest<DBNews>(entityName: "DBNews")
                request.predicate = NSPredicate(format: "source == %@", source)
                let items = try moc.fetch(request)
                return .success(items)
            }
            catch
            {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    func setRead(guid: String) -> Error?
    {
        return DBNews.update(in: moc,
                             predicate: NSPredicate(format: "guid == %@", guid),
                             handler: { (news: DBNews) in
                                 news.unread = false
                             })
    }

    func set(updateInterval: Int) -> Error?
    {
        return DBSettings.update(in: moc,
                                 predicate: nil,
                                 handler: { (settings: DBSettings) in
                                     settings.updateInterval = Int16(updateInterval)
                                 })
    }

    func updateInterval() -> Result<Int, Error>
    {
        do
        {
            let request = NSFetchRequest<DBSettings>(entityName: "DBSettings")
            if let settings = try moc.fetch(request).first {
                return .success(Int(settings.updateInterval))
            }
            
            let settings = DBSettings(context: moc)
            settings.updateInterval = 300
            moc.insert(settings)
            try moc.save()
            
            return .success(Int(settings.updateInterval))
        }
        catch
        {
            return .failure(error)
        }
    }

}
