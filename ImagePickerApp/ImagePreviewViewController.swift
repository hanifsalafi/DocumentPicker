//
//  UploadFileViewController.swift
//  ImagePickerApp
//
//  Created by Hanif Salafi on 13/10/18.
//  Copyright © 2018 Telkom University. All rights reserved.
//

import UIKit

protocol ImagePreviewDelegate {
    func onSend(image: UIImage?, text: String)
}

class ImagePreviewViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtSend: UITextField!
    @IBOutlet weak var imgPreview: UIImageView!
    var image : UIImage?
    var text : String?
    
    var delegate:ImagePreviewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPreview.image = image
        txtSend.delegate = self
        
    }
    
    @IBAction func sendImage(_ sender: Any) {
        
        
//        viewController.imagePreview = image
//        viewController.textMessage = "Message : \(txtSend.text!)"
        
        delegate?.onSend(image: image, text: txtSend.text!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closePreview(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        self.present(viewController, animated:true, completion:nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtSend.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
