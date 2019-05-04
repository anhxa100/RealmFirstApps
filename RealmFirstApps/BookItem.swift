//
//  BookItem.swift
//  RealmFirstApps
//
//  Created by anhxa100 on 5/4/19.
//  Copyright © 2019 anhxa100. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class BookItem: Object {
    enum Property: String {
        case id, name, isCompleted
    }
    
    dynamic var id = UUID().uuidString
    dynamic var name = ""
    dynamic var isCompleted = false
    
    override static func primaryKey() -> String? {
        return BookItem.Property.id.rawValue
    }
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
    
    //Get List Book
    static func getAll(in realm: Realm = try! Realm()) -> Results<BookItem> {
        return realm.objects(BookItem.self)
            .sorted(byKeyPath: BookItem.Property.isCompleted.rawValue)
    }
    
    //Edit Book
    func toggleCompleted() {
        guard let realm = realm else { return }
        try! realm.write {
            isCompleted = !isCompleted
        }
    }
    
    //Delete Book
    func delete() {
        guard let realm = realm else { return }
        try! realm.write {
            realm.delete(self)
        }
    }
    
}
extension BookItem {
    static func add(name: String, in realm: Realm = try! Realm()) -> BookItem {
        let book = BookItem(name)
        try! realm.write {
            realm.add(book)
        }
        return book
    }
}
