//
//  ViewController.swift
//  ImagePickerApp
//
//  Created by Hanif Salafi on 10/10/18.
//  Copyright © 2018 Telkom University. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, ImagePreviewDelegate{
    
    var videoUrl : NSURL?
    var imagePreview : UIImage?
    var textMessage : String?

    @IBOutlet weak var titleUrlFile: UILabel!
    @IBOutlet weak var titleUrlView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtMessage: UILabel!
    
    @IBOutlet weak var pickBtn: UIButton!
    @IBAction func imgPicker(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        let actionSheets = UIAlertController(title: "Unggah File", message: nil, preferredStyle: .actionSheet)
        
        let titleStr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        let titleAttrString = NSMutableAttributedString(string: "Unggah File", attributes: titleStr)
        actionSheets.setValue(titleAttrString, forKey: "attributedTitle")
        
        actionSheets.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not Available")
                let alert = UIAlertController(title: "Alert", message: "Camera not Available", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }))
        actionSheets.addAction(UIAlertAction(title: "Foto", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheets.addAction(UIAlertAction(title: "Video", style: .default, handler: { (action: UIAlertAction) in
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = ["public.image","public.movie"]
            
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
        actionSheets.addAction(UIAlertAction(title: "Dokumen", style: .default, handler: { (action: UIAlertAction) in
            
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc","org.openxmlformats.wordprocessingml.document" , kUTTypePDF as String], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = true
            self.present(documentPicker, animated: true, completion: nil)
            
        }))
        actionSheets.addAction(UIAlertAction(title: "Batalkan", style: .cancel, handler: { (action: UIAlertAction) in
        }))
        
        self.present(actionSheets, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        
        
        if image != nil {
            imgView.isHidden = false
            titleUrlView.isHidden = true
            imagePreview = image
            picker.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "showModal", sender: self)
        } else {
            imgView.isHidden = false
            titleUrlView.isHidden = true
            imgView.image = previewImageFromVideo(url: videoUrl! as NSURL)!
            imgView.contentMode = .scaleAspectFit
            picker.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        titleUrlView.isHidden = false
        titleUrlFile.text = selectedFileURL.lastPathComponent
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileUrl = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileUrl)
            
        } catch {
            print("Error : \(error)")
        }
        
        imgView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pickBtn.layer.borderColor = UIColor.lightGray.cgColor
        titleUrlView.isHidden = true
        imgView.isHidden = false
        imgView.image = imagePreview
        txtMessage.text = textMessage
        
        // writeFiles()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModal"{
            let destination = segue.destination as! ImagePreviewViewController
            destination.image = imagePreview
            destination.delegate = self
        }
    }
    
    func writeFiles(){
        let file = "\(UUID().uuidString).doc"
        let contents = "Some text..."
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = dir.appendingPathComponent(file)
        
        do {
            try contents.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    func previewImageFromVideo(url:NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
    
        var time = asset.duration
        time.value = min(time.value,2)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            
            let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.playVideo))
            imgView.addGestureRecognizer(tapAction)
            
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
   
    @objc func playVideo() {
        if let videoURL = videoUrl{
            
            let player = AVPlayer(url: videoURL as URL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            present(playerViewController, animated: true){
                playerViewController.player!.play()
            }
        }
        
    }
    
    //MARK : ImagePreviewDelegate
    
    func onSend(image: UIImage?, text: String) {
        imgView.image = image
        txtMessage.text = text
    }
}

