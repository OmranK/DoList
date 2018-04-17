//
//  ListsBinderViewController.swift
//  DoList
//
//  Created by Omran Khoja on 4/17/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import UIKit
import CoreData

class ListsBinderViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var listsArray = [List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLists()

    }
    
  
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCategoryCell", for: indexPath)
        let list = listsArray[indexPath.row]
        cell.textLabel?.text = list.name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedList = listsArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveLists() {
        do {
            try context.save()
        } catch {
            print("Error saving List to Binder \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadLists(with request: NSFetchRequest<List> = List.fetchRequest()) {
        do {
            listsArray = try context.fetch(request)
        } catch {
            print("Error loading Lists from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Add New List
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Create New List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add List", style: .default)
        { (action) in
            guard textField.text != "" else { return }
            
            let newList = List(context: self.context)
            newList.name = textField.text!
            self.listsArray.append(newList)
            self.saveLists()
            self.tableView.reloadData()
        }
        
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField.placeholder = "Create New List"
            textField = field
        }
        
        present(alert, animated: true, completion: nil)
    }

}
