//
//  ViewController.swift
//  NoteApp_GVA_112_368_344
//
//  Created by Mac on 6/20/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categorydata = [CategoryData]()
    var filterCategory = [CategoryData]()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    @IBAction func addCategoryBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Category Name",message: "",preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .destructive) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let categoryNameTxtField = textField.text else {return}
            
            self.saveData(categoryName: categoryNameTxtField)
            self.tableview.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel",style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        searchBar.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterCategory = categorydata
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else {return}
        
        loadData()
    }
    // Functions
    func saveData(categoryName: String){
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else { return}
        
        let category = CategoryData(context: self.managedContext)
        category.name = categoryName
        categorydata.append(category)
        filterCategory.append(category)
        do {
            try managedContext.save()
        }catch let error as NSError {
            print("Error while saving. \(error), \(error.userInfo)")
        }
    }
    
    
    func loadData(with request : NSFetchRequest<CategoryData> = CategoryData.fetchRequest()){
        do{
            categorydata = try managedContext.fetch(request)
            filterCategory = categorydata
        } catch{
            print("Error while saving.. \(error)")
        }
    }
    
    //Table data
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let categoryCell = tableview.dequeueReusableCell(withIdentifier: "categorycell", for: indexPath) as! CategoryCell
        categoryCell.categoryName.text = filterCategory[indexPath.row].name
        cell = categoryCell
        return cell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "noteData") {
            let destination = segue.destination as! NoteViewController
            destination.modalPresentationStyle = .fullScreen
            if let indexpath = tableview.indexPathForSelectedRow{
                destination.categoryData = filterCategory[indexpath.row]
            }
        }
    }
}

class CategoryCell:UITableViewCell{
    @IBOutlet weak var categoryName: UILabel!    
}

extension CategoryViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterCategory = searchText.isEmpty ? categorydata : categorydata.filter({ (item: CategoryData) -> Bool in
            return item.name!.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableview.reloadData()
    }
}


// for toast msg

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
