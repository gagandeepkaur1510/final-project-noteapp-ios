//
//  AddEditNotesViewController.swift
//  NoteApp_GVA_112_368_344
//
//  Created by Mac on 6/20/20.
//  Copyright © 2020 Mac. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class AddEditNotesViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate ,AVAudioPlayerDelegate,DataEnteredDelegate,DataEnteredDelegateAudio{
    
    func userDidEnterInformation(name: String) {
        audiostring = name
    }
    var player:AVAudioPlayer!
    var noteData = NoteData()
    var editNoteData: NoteData?
    var noteTableData = NoteViewController()
    var categorydata = CategoryData()
    var isEdit = false
    var latitude1 = 0.0
    var longitude1 = 0.0
    var audiostring = ""
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var noteDetailLbl: UITextView!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    
    @IBAction func playAudioBtnTapped(_ sender: Any) {
        
        if audiostring == ""{
            self.showToast(message: "No Audio Present!", font: .systemFont(ofSize: 12.0))
            return
        }
        let audioFilename = getCacheDirectory().appendingPathComponent(audiostring)
        player = try? AVAudioPlayer(contentsOf: audioFilename)
        player.delegate = self
        player.prepareToPlay()
        player.volume = 1.0
        player.play()
        
    }
    
    func getCacheDirectory() -> URL {
        let fm = FileManager.default
        let docsurl = fm.urls(for:.documentDirectory, in: .userDomainMask)
        
        let documentDirectory = docsurl[0]
        return documentDirectory
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        saveNoteToCoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        _ = appDelegate.persistentContainer.viewContext
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapOnImage))
        imageview.isUserInteractionEnabled = true
        self.imageview.addGestureRecognizer(tap)
        
        if (isEdit == true) {
            print("Editing an existing note")
            noteTitle.text = editNoteData?.noteName
            self.imageview.image = UIImage(data: (editNoteData?.noteImage!)!)
            latitude.text = "Latitude:" + String(editNoteData!.latitude)
            noteDetailLbl.text = editNoteData!.notedetail
            longitude.text = "Longitude:" + String(editNoteData!.longitude)
            audiostring = editNoteData!.audio!
        }else {
            
            latitude.text = "Latitude:  No Coordinates"
            longitude.text = "Longitude:  No Coordinates"
            
        }
    }
    func saveNoteToCoreData(){
        
        if (isEdit == true) {
            editNoteData!.noteName = noteTitle.text
            let imageData = imageview.image!.pngData() as NSData?
            editNoteData!.noteImage = imageData as Data?
            editNoteData!.latitude = latitude1
            editNoteData!.notedetail = noteDetailLbl.text ?? ""
            editNoteData!.longitude = longitude1
            editNoteData?.audio = audiostring
        }else {
            noteData = NoteData(context:managedContext)
            noteData.noteToCategory = self.categorydata
            noteData.setValue(Date(), forKey: "date")
            
            if (noteTitle.text!.isEmpty) {
                noteData.noteName = "No Title"
            }else{
                noteData.noteName = noteTitle.text ?? ""
            }
            noteData.notedetail = noteDetailLbl.text ?? ""
            let imageData = imageview.image!.pngData() as NSData?
            noteData.noteImage = imageData as Data?
            noteData.latitude = latitude1
            noteData.longitude = longitude1
            noteData.audio = audiostring
        }
        do {
            try managedContext.save()
            print("Note Saved!")
            self.showToast(message: "Saved...", font: .systemFont(ofSize: 12.0))
            self.navigationController?.popViewController(animated: true)
        }catch {
            let alertBox = UIAlertController(title: "Error", message: "Error while saving.", preferredStyle: .alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertBox, animated: true, completion: nil)
        }
        
    }
    
    @objc func tapOnImage()  {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        let alertController = UIAlertController(title: "Choose From", message: "", preferredStyle: .actionSheet)
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //Image Picker Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let imageData = image.pngData() as NSData?
            
            self.imageview.image = UIImage(data: imageData! as Data)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "audio") {
            let destination = segue.destination as! AudioViewController
            destination.modalPresentationStyle = .fullScreen
            destination.delegate = self
        }else  if (segue.identifier == "maplocation") {
            let destination = segue.destination as! MapViewController
            if  let edit = editNoteData{
                let lat:Double = edit.latitude
                let long:Double = edit.longitude
                destination.lat = lat
                destination.long = long
            }
            destination.delegate = self
        }
    }
    
    func userDidEnterInformation(lat: Double, long: Double) {
        longitude1 = long
        latitude1 = lat
        latitude.text =  "Latitude:" + lat.description
        longitude.text = "Longitude:" + long.description
    }
}


