//
//  File.swift
//  MonkeyTV
//
//  Created by 王昱淇 on 2023/9/26.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyData")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Create Search History Object
    
    @discardableResult
    func createSearchHistoryObject(
        showName: String) -> SearchHistory? {
            
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
    
    // MARK: - Fetch Search Historys
    
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
    
    // MARK: - Update Search History
    
    func updateSearchHistory(searchHistoryObject: SearchHistory) {
        
        let context = persistentContainer.viewContext
        do {
            try context.save()
        } catch let createError {
            print("Failed to update: \(createError)")
        }
    }
    
    // MARK: - Delete Search History Object
    
    func deleteSearchHistoryObject(searchHistoryObject: SearchHistory) {
        
        let context = persistentContainer.viewContext
        do {
            context.delete(searchHistoryObject)
            try context.save()
        } catch let saveError {
            print("Failed to delete: \(saveError)")
        }
    }
    
    // MARK: - Delete All Search History
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
