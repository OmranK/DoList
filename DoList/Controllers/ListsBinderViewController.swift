//
//  ListsBinderViewController.swift
//  DoList
//
//  Created by Omran Khoja on 4/17/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ListsBinderViewController: SwipeTableViewController {
    
    var colorArray = NSArray(ofColorsWith: ColorScheme.complementary, using: FlatMint(), withFlatScheme: true)
    let colors: [UIColor] = [FlatPowderBlue(), FlatMint(), FlatGreen(), FlatLime(), FlatWatermelon()]
    
    let realm = try! Realm()

    var listsArray: Results<ToDoList>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        loadLists()
        
    }
    
  
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let list = listsArray?[indexPath.row] {
            cell.textLabel?.text = list.name
            cell.backgroundColor = UIColor(hexString: list.cellColor)
        }
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedList = listsArray?[indexPath.row]
            destinationVC.title = listsArray?[indexPath.row].name
        }
        
    }
    
    
    //MARK: - Data Manipulation Methods - Save, Load, Delete
    
    func save(list: ToDoList) {
        do {
            try realm.write {
                realm.add(list)
            }
        } catch {
            print("Error saving List to Binder \(error)")
        }
        tableView.reloadData()
    }
    
    func loadLists() {
        listsArray = realm.objects(ToDoList.self)
        tableView.reloadData()
    }
    
    // delete
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let item = self.listsArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting To Do List \(error)")
            }
        }
    }
    
    
    //MARK: - Add New List
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Create New List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default)
       
        { (action) in
            guard textField.text != "" else { return }
            
            let newList = ToDoList()
            newList.name = textField.text!
            print(self.listsArray?.count)
            if let indexPath = self.listsArray?.count {
                let colorNumber = (indexPath % 5)
                let color = self.colors[colorNumber]
                newList.cellColor = color.hexValue()
            }
            
            
            self.save(list: newList)
            
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField.placeholder = "Create New List"
            textField = field
        }
        
        present(alert, animated: true, completion: nil)
    }

}
