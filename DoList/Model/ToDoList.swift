//
//  List.swift
//  DoList
//
//  Created by Omran Khoja on 4/17/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoList: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var cellColor: String = ""
    let items = List<ToDoItem>()
    
}
