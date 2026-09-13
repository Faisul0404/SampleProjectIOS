//
//  Persistence.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    private let persistentContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "QuoteNGo")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
}

extension PersistenceController {
    @discardableResult
    func saveUserData(with user: User) -> LocalUserData? {
        let context = PersistenceController.shared.backgroundContext()
        
        let entity = LocalUserData.entity()
        let userData = LocalUserData(entity: entity, insertInto: context)
    
        userData.accessToken = user.accessToken
        
        do {
            try context.save()
            return userData
        } catch let error {
            print("Error: \(error)")
        }
        
        return nil
    }
    
    func loadUserData() -> LocalUserData? {
        let mainContext = PersistenceController.shared.mainContext
        let fetchRequest: NSFetchRequest<LocalUserData> = LocalUserData.fetchRequest()
        
        do {
            let result = try mainContext.fetch(fetchRequest).first
            return result
        }
        catch {
            debugPrint(error)
        }
        
        return nil
    }
    
    func updateAccessToken(with token: String) {
        let context = PersistenceController.shared.backgroundContext()
        let fetchRequest: NSFetchRequest<LocalUserData> = LocalUserData.fetchRequest()
        
        do {
            guard let userData = try context.fetch(fetchRequest).first else { return }
            
            userData.accessToken = token
            
            do {
                try context.save()
            } catch let error {
                print("Error: \(error)")
            }
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func deleteUserData() {
        let context = PersistenceController.shared.backgroundContext()
        let fetchRequest: NSFetchRequest<LocalUserData> = LocalUserData.fetchRequest()
        
        do {
            let userData = try context.fetch(fetchRequest)
            userData.forEach{ context.delete($0) }
            
            do {
                try context.save()
            } catch let error {
                print("Error: \(error)")
            }
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    var accessToken: String? {
        return loadUserData()?.accessToken
    }
}
