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
        var result: Error?
        context.performAndWait
        {
            do
            {
                let request = NSFetchRequest<T>(entityName: String(describing: self))
                request.predicate = predicate
                if
                    let object = try? context.fetch(request).first
                {
                    handler(object)
                    try context.save()
                }
                else
                {
                    result = DBServiceError.objectIsNotExists
                }
            }
            catch
            {
                print(error)
                result = error
            }
        }
        return result
    }

    class func delete(in context: NSManagedObjectContext,
                      predicate: NSPredicate) -> Error?
    {
        var result: Error?
        context.performAndWait
        {
            do
            {
                let request = NSFetchRequest<Self>(entityName: String(describing: self))
                request.predicate = predicate
                if
                    let object = try? context.fetch(request).first
                {
                    context.delete(object)
                    try context.save()
                }
                else
                {
                    result = DBServiceError.objectIsNotExists
                }
            }
            catch
            {
                print(error)
                result = error
            }
        }
        return result
    }

    class func deleteArray(in context: NSManagedObjectContext,
                           predicate: NSPredicate) -> Error?
    {
        var result: Error?
        context.performAndWait
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
                print(error)
                result = error
            }
        }
        return result
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
