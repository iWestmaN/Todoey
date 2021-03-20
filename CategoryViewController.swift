//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Igor Lishchenko on 22.02.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .localDomainMask).first?.appendingPathComponent("Category.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            saveCategories()
        }
    }
    
    // MARK: - Tableview delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desinationVC = segue.destination as! TodoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            desinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Data manipulation methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving categories \(error)")
        }
        tableView.reloadData()
    }
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching request \(error)")
        }
        tableView.reloadData()
    }
    // MARK: - Add new category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: { (cancel) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add category"
        }
        
        present(alert, animated: true, completion: nil)
    }
}
