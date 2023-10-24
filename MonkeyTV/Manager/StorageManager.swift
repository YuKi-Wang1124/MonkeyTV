//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/26.
//

import Foundation
import UIKit
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyData")
        container.loadPersistentStores { ( _, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Create Object
    
    @discardableResult
    
    func isContainMyShow(id: String) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MyShow> = MyShow.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let matchingRecords = try context.fetch(fetchRequest)
            if matchingRecords.isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            print("search my show error: \(error)")
            return false
        }
    }
    
    func createMyShowObject(
        showName: String,
        id: String,
        playlistId: String,
        showImage: String
    ) -> MyShow? {
            let context = persistentContainer.viewContext
            let myShow = NSEntityDescription.insertNewObject(forEntityName: "MyShow",
                                                                    into: context) as? MyShow
            guard let myShow = myShow else { return nil }
            myShow.showName = showName
            myShow.id = id
            myShow.playlistId = playlistId
            myShow.showImage = showImage
            do {
                try context.save()
                return myShow
            } catch let createError {
                print("Failed to create search history: \(createError)")
            }
            
            return nil
        }
    
    func createSearchHistoryObject(
        showName: String
    ) -> SearchHistory? {
            let context = persistentContainer.viewContext
            let searchHistory = NSEntityDescription.insertNewObject(forEntityName: "SearchHistory",
                                                                    into: context) as? SearchHistory
            guard let searchHistory = searchHistory else { return nil }
            searchHistory.showName = showName
            do {
                try context.save()
                return searchHistory
            } catch let createError {
                print("Failed to create search history: \(createError)")
            }
            return nil
        }
    
    // MARK: - Fetch Object
    
    func fetchSearchMyShows() -> [MyShow]? {
        
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<MyShow>(entityName: "MyShow")
        
        do {
            let myShow = try context.fetch(fetchRequest)
            return myShow
        } catch let fetechError {
            print("Failed to fetch: \(fetechError)")
        }
        return nil
    }
    
    func fetchSearchHistorys() -> [SearchHistory]? {
        
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        
        do {
            let searchHistory = try context.fetch(fetchRequest)
            return searchHistory
        } catch let fetechError {
            print("Failed to fetch: \(fetechError)")
        }
        return nil
    }
    
    // MARK: - Update
    
    func updateMyShow(show: MyShow) {
        
        let context = persistentContainer.viewContext
        do {
            try context.save()
        } catch let createError {
            print("Failed to update: \(createError)")
        }
    }
    
    func updateSearchHistory(searchHistoryObject: SearchHistory) {
        
        let context = persistentContainer.viewContext
        do {
            try context.save()
        } catch let createError {
            print("Failed to update: \(createError)")
        }
    }
    
    // MARK: - Delete  Object
    
    func deleteMyShow(id: String) {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<MyShow>(entityName: "MyShow")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    
        do {
            let objectsToDelete = try context.fetch(fetchRequest)
            for object in objectsToDelete {
                context.delete(object)
            }
            try context.save()
        
        } catch let saveError {
            print("Failed to delete: \(saveError)")
        }
    }
    
    func deleteSearchHistoryObject(searchHistoryObject: SearchHistory) {
        
        let context = persistentContainer.viewContext
        do {
            context.delete(searchHistoryObject)
            try context.save()
        } catch let saveError {
            print("Failed to delete: \(saveError)")
        }
    }
    
    // MARK: - Delete All Object
    
    func deleteAllMyShow() {
        
        let context = persistentContainer.viewContext
        if let searchShows = fetchSearchMyShows() {
            for show in searchShows {
                context.delete(show)
            }
            do {
                try context.save()
            } catch let saveError {
                print("Failed to delete all products: \(saveError)")
            }
        }
    }
    
    func deleteAllSearchHistory() {
        
        let context = persistentContainer.viewContext
        if let searchHistorys = fetchSearchHistorys() {
            for searchHistory in searchHistorys {
                context.delete(searchHistory)
            }
            do {
                try context.save()
            } catch let saveError {
                print("Failed to delete all products: \(saveError)")
            }
        }
    }
}
