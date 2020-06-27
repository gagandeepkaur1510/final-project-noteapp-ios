//
//  NoteViewController.swift
//  NoteApp_GVA_112_368_344
//
//  Created by Mac on 6/20/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var notedata = [NoteData]()
    var filterNoteData = [NoteData]()
    var categoryData = CategoryData()
    var categoryDataArray = [CategoryData]()
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    @IBAction func addNote(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        searchbar.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
        filterNoteData = notedata
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterNoteData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        if let notecell = tableview.dequeueReusableCell(withIdentifier: "notecell", for: indexPath) as? NoteCell{
            let data  = filterNoteData[indexPath.row]
            notecell.noteName.text = data.noteName ?? ""
            
            if let imageData = filterNoteData[indexPath.row].noteImage {
                let image = UIImage(data: imageData)
                notecell.noteImage.image = image
            }else {
                notecell.noteImage.image = UIImage(named: "SomeEmptyImage")
            }
            
            if let date = data.date{
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "dd/MM/yyyy"
                notecell.date.text = inputFormatter.string(from: date)
            }
            cell = notecell
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.filterNoteData[indexPath.row])
            filterNoteData.remove(at: indexPath.row)
            do{
                try managedContext.save()
                loadNotes()
                self.tableview.reloadData()
            }
                
            catch{
                print("Failed")
            }
            
        }
    }
    //Functions
    
    func loadNotes() {
        
        let fetchRequest:NSFetchRequest<NoteData> = NoteData.fetchRequest()
        
        if let name = self.categoryData.name{
            let categoryPradicate = NSPredicate(format: "noteToCategory.name MATCHES %@", name)
            fetchRequest.predicate = categoryPradicate
        }
        do {
            filterNoteData = try managedContext.fetch(fetchRequest)
            notedata = try managedContext.fetch(fetchRequest)
        } catch {
            print("Error while fetching database")
        }
        tableview.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "addedit") {
            let destination = segue.destination as! AddEditNotesViewController
            destination.modalPresentationStyle = .fullScreen
            destination.categorydata = categoryData
            //destination.delegate = self
        }else if (segue.identifier == "editnote") {
            let destination = segue.destination as! AddEditNotesViewController
            destination.modalPresentationStyle = .fullScreen
            if let indexpath = tableview.indexPathForSelectedRow{
                destination.isEdit = true
                destination.editNoteData = filterNoteData[indexpath.row]
            }
        }
    }
}


class NoteCell: UITableViewCell{
    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var noteImage: UIImageView!
    
}
extension NoteViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterNoteData = searchText.isEmpty ? notedata : notedata.filter({ (item: NoteData) -> Bool in
            return item.noteName!.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableview.reloadData()
    }
}
