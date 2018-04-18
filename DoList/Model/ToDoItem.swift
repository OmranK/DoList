//
//  ToDoItem.swift
//  DoList
//
//  Created by Omran Khoja on 4/17/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var isCompleted: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: ToDoList.self, property: "items")
}
