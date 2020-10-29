import Foundation
import CoreData

enum DBServiceError: Error
{
    case objectIsNotExists
}

extension NSManagedObject
{
    func `in`(context: NSManagedObjectContext) -> Self?
    {
        return self.object(inContext: context)
    }

    // MARK: - Class functions
    class func entityName() -> String
    {
        if #available(iOS 10.0, *)
            {
            if let entityName = self.entity().name
                {
                return entityName
            }
            else
            {
                return String(describing: self)
            }
        }
        return String(describing: self)
    }

    class func create(in context: NSManagedObjectContext) -> Self
    {
        if #available(iOS 10.0, *)
            {
            return self.init(context: context)
        }
        else
        {
            return self.createObject(in: context)
        }
    }

    class func update<T: NSManagedObject>(in context: NSManagedObjectContext,
                                          predicate: NSPredicate?,
                                          handler: (T) -> ()) -> Error?
    {
        do
        {
            let request = NSFetchRequest<T>(entityName: String(describing: self))
            request.predicate = predicate
            guard let object = try? context.fetch(request).first else
            {
                return DBServiceError.objectIsNotExists
            }
            handler(object)
            try context.save()
        }
        catch
        {
            print(error)
            return error
        }
        return nil
    }

    class func delete(in context: NSManagedObjectContext,
                      predicate: NSPredicate) -> Error?
    {
        do
        {
            let request = NSFetchRequest<Self>(entityName: String(describing: self))
            request.predicate = predicate
            guard let object = try? context.fetch(request).first else
            {
                return DBServiceError.objectIsNotExists
            }
            context.delete(object)
            try context.save()
        }
        catch
        {
            return error
        }
        return nil
    }

    class func deleteArray(in context: NSManagedObjectContext,
                           predicate: NSPredicate) -> Error?
    {
        do
        {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
            request.predicate = predicate
            let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(batchRequest)
            try context.save()
        }
        catch
        {
            return error
        }
        return nil
    }

    // MARK: - Private functions
    private func object<T: NSManagedObject>(inContext context: NSManagedObjectContext) -> T?
    {
        if self.objectID.isTemporaryID
            {
            do
            {
                try self.managedObjectContext?.obtainPermanentIDs(for: [self])
            }
            catch let error
            {
                debugPrint("ManagedObject in context FAILED with error: \(error)")
                return nil
            }
        }
        var object: T?
        do
        {
            object = try context.existingObject(with: self.objectID) as? T
        }
        catch let error
        {
            debugPrint("ManagedObject in context FAILED with error: \(error)")
            return nil
        }
        return object
    }

    // MARK: - Private Class functions
    private class func createObject<T: NSManagedObject>(in context: NSManagedObjectContext) -> T
    {
        return NSEntityDescription.insertNewObject(forEntityName: self.entityName(), into: context) as! T
    }
}
