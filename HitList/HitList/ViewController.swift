//
//  ViewController.swift
//  HitList
//
//  Created by Thiago Martins on 14/04/20.
//  Copyright © 2020 Thiago Anderson Martins. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    // Properties:
    // - Variables:
    var people : [NSManagedObject] = []
    
    // - IB Properties:
    @IBOutlet weak var tableView: UITableView!
        
    // Overridden Methods:
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        // Guarantees your table view will return a cell of the correct type when the Cell reuseIdentifier is provided to the dequeue method:
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 1: Before you can do anything with Core Data, you need a managed object context. Fetching is no different! Like before, you pull up the application delegate and grab a reference to its persistent container to get your hands on its NSManagedObjectContext.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        // 2: As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data. Fetch requests are both powerful and flexible. You can use fetch requests to fetch a set of objects meeting the provided criteria (i.e. give me all employees living in Wisconsin and have been with the company at least three years), individual values (i.e. give me the longest name in the database) and more.
        // Fetch requests have several qualifiers used to refine the set of results returned. For now, you should know NSEntityDescription is one of these required qualifiers.
        // Setting a fetch request’s entity property, or alternatively initializing it with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities. Also note NSFetchRequest is a generic type. This use of generics specifies a fetch request’s expected return type, in this case NSManagedObject.
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        // 3: You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.
        // Note: Like save(), fetch(_:) can also throw an error so you have to use it within a do block. If an error occurred during the fetch, you can inspect the error inside the catch block and respond appropriately.
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // IB Actions:
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func save(name : String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // 1: Before you can save or retrieve anything from your Core Data store, you first need to get your hands on an NSManagedObjectContext. You can consider a managed object context as an in-memory “scratchpad” for working with managed objects.
        //  Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context; once you’re happy, you “commit” the changes in your managed object context to save it to disk.
        //  Xcode has already generated a managed object context as part of the new project’s template. Remember, this only happens if you check the Use Core Data checkbox at the beginning. This default managed object context lives as a property of the NSPersistentContainer in the application delegate. To access it, you first get a reference to the app delegate.
        let managedContext = appDelegate.persistentContainer.viewContext
        // 2: You create a new managed object and insert it into the managed object context. You can do this in one step with NSManagedObject’s static method: entity(forEntityName:in:).
        // You may be wondering what an NSEntityDescription is all about. Recall earlier, NSManagedObject was called a shape-shifter class because it can represent any entity. An entity description is the piece linking the entity definition from your Data Model with an instance of NSManagedObject at runtime.
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        // 3: With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model, otherwise, your app will crash at runtime.
        person.setValue(name, forKey: "name")
        // 4: You commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

// Extensions:
extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
    
}

