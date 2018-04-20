//
//  ViewController.swift
//  DoList
//
//  Created by Omran Khoja on 3/23/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var toDoItems: Results<ToDoItem>?
    let realm = try! Realm()
    var selectedList : ToDoList? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedList?.name
        guard let colorHex = selectedList?.cellColor else {fatalError()}
        updateNavBar(withHexCode: colorHex)
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        updateNavBar(withHexCode: "1D9BF6")
//    }
    
    
    //MARK: - Nav Bar Setup Method
    
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("NavBar does not exist.")}
        
        guard let uiColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.barTintColor = uiColor
        navBar.tintColor = ContrastColorOf(uiColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(uiColor, returnFlat: true)]
        searchBar.barTintColor = uiColor
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isCompleted ? .checkmark : .none
            if let color = UIColor(hexString: selectedList!.cellColor)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isCompleted = !item.isCompleted
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if let item = toDoItems?[indexPath.row] {
//                do {
//                    try realm.write {
//                        realm.delete(item)
//                    }
//                } catch {
//                    print("Error deleting To Do Item \(error)")
//                }
//                tableView.reloadData()
//            }
//        }
//    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New To Do Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default)
        { (action) in
            guard textField.text != "" else { return }
            
            if let currentList = self.selectedList {
                do {
                    try self.realm.write {
                        let newItem = ToDoItem()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentList.items.append(newItem)
                    }
                } catch {
                    print("Error adding Item to List \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data Manipulation Methods - Save, Load, Delete
    
    func saveItems(task: ToDoItem) {
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    func loadItems() {
        toDoItems = selectedList?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting To Do Item \(error)")
            }
        }
    }
    
}


//MARK: - Search Bar Method Extension

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        }
        tableView.reloadData()
    }
}





