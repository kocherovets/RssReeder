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
        
        print(url)

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

    func set(news items: [NewsState.News], forSource url: String) -> Error?
    {
        switch source(url: url) {
        case .success(let source):
            do
            {
                let request: NSFetchRequest<DBNews> = DBNews.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "(source == %@) AND (time == max(time))", source)
                let lastTime = try moc.fetch(request).first?.time ?? Date.distantPast

                for item in items {
                    if item.time > lastTime {
                        let news = DBNews(context: moc)
                        news.source = source
                        news.guid = item.guid
                        news.sourceTitle = item.source
                        news.title = item.title
                        news.body = item.body
                        news.time = item.time
                        news.imageURL = item.imageURL
                        news.unread = true
                        news.starred = false
                        moc.insert(news)
                    }
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

    func news(onlyStarred: Bool, from: Int, limit: Int) -> Result<[NewsState.News], Error>
    {
        do
        {
            let request = NSFetchRequest<DBNews>(entityName: "DBNews")
            var predicate = "(source.active == YES)"
            if onlyStarred {
                predicate += "AND (starred == YES)"
            }
            request.predicate = NSPredicate(format: predicate)
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBNews.time), ascending: false)]
            request.fetchLimit = limit
            request.fetchOffset = from
            let items = try moc.fetch(request)
            let result = items.map {
                NewsState.News(
                    source: $0.sourceTitle,
                    guid: $0.guid,
                    title: $0.title,
                    body: $0.body,
                    time: $0.time,
                    imageURL: $0.imageURL,
                    unread: $0.unread,
                    starred: $0.starred)
            }
            return .success(result)
        }
        catch
        {
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

    func setStarred(guid: String, starred: Bool) -> Error?
    {
        return DBNews.update(in: moc,
                             predicate: NSPredicate(format: "guid == %@", guid),
                             handler: { (news: DBNews) in
                                 news.starred = starred
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

    func fillTestData() -> Error?
    {
        do
        {
            let source = DBSource(context: moc)
            source.url = "testdata.com"
            source.active = true
            moc.insert(source)
            try moc.save()

            var time = Date().timeIntervalSince1970
            for i in 1 ... 10000 {
                let news = DBNews(context: moc)
                news.source = source
                news.guid = UUID().uuidString
                news.sourceTitle = "TEST DATA"
                news.title = "title \(i)"
                news.body = "body \(i) body body body body body body body body body body body body body body body body body"
                news.time = Date(timeIntervalSince1970: time)
                news.imageURL = ""
                news.unread = true
                news.starred = false
                moc.insert(news)

                time = time - 55 * 60
            }
            try moc.save()
        }
        catch
        {
            return error
        }
        return nil
    }
}
