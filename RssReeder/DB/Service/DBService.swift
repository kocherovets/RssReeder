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
        var result: Error?
        moc.performAndWait
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
                print(error)
                result = error
            }
        }
        return result
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

    func source(url: String, complete: (Result<DBSource, Error>) -> Void)
    {
        moc.performAndWait
        {
            do
            {
                let request = NSFetchRequest<DBSource>(entityName: "DBSource")
                request.predicate = NSPredicate(format: "url == %@", url)
                if let source = try moc.fetch(request).first
                {
                    complete(.success(source))
                }
                else
                {
                    complete(.failure(DBServiceError.objectIsNotExists))
                }
            }
            catch
            {
                complete(.failure(error))
            }
        }
    }

    func sources(complete: (Result<[DBSource], Error>) -> Void)
    {
        moc.performAndWait
        {
            do
            {
                let request = NSFetchRequest<DBSource>(entityName: "DBSource")
                let sources = try moc.fetch(request)
                complete(.success(sources))
            }
            catch
            {
                complete(.failure(error))
            }
        }
    }

    func set(news items: [NewsState.Article], forSource url: String, complete: (Result<Void, Error>) -> Void)
    {
        moc.performAndWait
        {
            source(url: url) { result in
                switch result
                {
                case .success(let source):
                    do
                    {
                        let request: NSFetchRequest<DBNews> = DBNews.fetchRequest()
                        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBNews.time), ascending: false)]
                        request.predicate = NSPredicate(format: "(source == %@)", source)
                        request.fetchLimit = 1
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
                        complete(.success(()))
                    }
                    catch
                    {
                        print(error)
                        complete(.failure(error))
                    }
                case .failure(let error):
                    complete(.failure(error))
                }
            }
        }
    }

    func news(onlyStarred: Bool, complete: (Result<[NewsState.DayArticles], Error>) -> Void)
    {
        moc.performAndWait {
            do
            {
                let request = NSFetchRequest<DBNews>(entityName: "DBNews")
                var predicate = "(source.active == YES)"
                if onlyStarred {
                    predicate += "AND (starred == YES)"
                }
                request.predicate = NSPredicate(format: predicate)
                request.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBNews.time), ascending: false)]
                let items = try moc.fetch(request)

                var articles = [NewsState.DayArticles]()
                var date: Date!
                var dayArticles: NewsState.DayArticles?
                for item in items {

                    let news = NewsState.Article(
                        source: item.sourceTitle,
                        guid: item.guid,
                        title: item.title,
                        body: item.body,
                        time: item.time,
                        imageURL: item.imageURL,
                        unread: item.unread,
                        starred: item.starred)

                    if date == nil || date > item.time {
                        date = item.time.removeTime()
                        if let dayArticles = dayArticles {
                            articles.append(dayArticles)
                        }
                        dayArticles = NewsState.DayArticles(date: date, articles: [news])
                    }
                    else {
                        dayArticles?.articles.append(news)
                    }
                }
                if let dayArticles = dayArticles {
                    articles.append(dayArticles)
                }
                complete(.success(articles))
            }
            catch
            {
                complete(.failure(error))
            }
        }
    }

    func setRead(guid: String) -> Error?
    {
         DBNews.update(in: moc,
                             predicate: NSPredicate(format: "guid == %@", guid),
                             handler: { (news: DBNews) in
                                 news.unread = false
                             })
    }

    func setStarred(guid: String, starred: Bool) -> Error?
    {
         DBNews.update(in: moc,
                             predicate: NSPredicate(format: "guid == %@", guid),
                             handler: { (news: DBNews) in
                                 news.starred = starred
                             })
    }

    func set(updateInterval: Int) -> Error?
    {
         DBSettings.update(in: moc,
                                 predicate: nil,
                                 handler: { (settings: DBSettings) in
                                     settings.updateInterval = Int16(updateInterval)
                                 })
    }

    func updateInterval(complete: (Result<Int, Error>) -> Void)
    {
        moc.performAndWait
        {
            do
            {
                let request = NSFetchRequest<DBSettings>(entityName: "DBSettings")
                if
                    let settings = try moc.fetch(request).first
                {
                    complete(.success(Int(settings.updateInterval)))
                }
                else
                {
                    let settings = DBSettings(context: moc)
                    settings.updateInterval = 300
                    moc.insert(settings)
                    try moc.save()

                    complete(.success(Int(settings.updateInterval)))
                }
            }
            catch
            {
                complete(.failure(error))
            }
        }
    }
}
