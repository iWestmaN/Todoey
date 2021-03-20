//
//  ViewController.swift
//  Todoey
//
//  Created by Igor Lishchenko on 22.02.2021.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //  let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
       // loadItems()
        
        //        let newItem = Item()
        //        newItem.title = "New item"
        //        itemArray.append(newItem)
        
        //        if var items = defaults.array(forKey: "TodoListArray") as? [Item] {
        //            items = itemArray
        //        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        //        } else{
        //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        //        }
        //        tableView.reloadData()
        saveItems()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            
            //   self.tableView.deleteRows(at: [indexPath], with: .automatic)
            context.delete(itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            saveItems()
            
        }
        
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) { (action) in
            
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            //   self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add item"
            textField = alertTextField
            
            //  print(alertTextField.text)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error encoding item array")
        }
        self.tableView.reloadData()
    }
    //    func loadItems() {
    //        if let data = try? Data(contentsOf: dataFilePath!) {
    //        do {
    //            let decoder = PropertyListDecoder()
    //            itemArray = try decoder.decode([Item].self, from: data)
    //        } catch {
    //            print("Error decoding data")
    //        }
    //    }
    //}
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionaPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionaPredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
//        let compoudPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//        request.predicate = compoudPredicate
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error trying to fetch data \(error)")
        }
        tableView.reloadData()
        
    }
    
}
extension TodoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        request()
        
        searchBar.resignFirstResponder()
        //        if searchBar.text! != "" {
        //            loadItems(with: request)
        //        } else {
        //            loadItems()
        //        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        request()
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func request() {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        searchBar.text! != "" ? loadItems(with: request, predicate: request.predicate) : loadItems()
    }
}
