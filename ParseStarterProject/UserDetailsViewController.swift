//
//  UserDetailsViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Vanessa Chu on 2017-07-18.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class UserDetailsViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var genderSwitch: UISwitch! // off: man, on: woman
    @IBOutlet var interestedInSwitch: UISwitch! // off: men, on: women
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func logOut(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    func createAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            profilePic.image = image
        
        }else{
        
            print("Error getting image")
        
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateImage(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        imagePickerController.allowsEditing = false
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func updateDetails(_ sender: Any) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()

            
        PFUser.current()?["isFemale"] = genderSwitch.isOn
        
        PFUser.current()?["isInterestedInFemale"] = interestedInSwitch.isOn
        
        let imageData = UIImageJPEGRepresentation(profilePic.image!, 1.0)
        
        let imageFile = PFFile(name: "image.jpg", data: imageData!)
        
        PFUser.current()?["imageFile"] = imageFile
        
        PFUser.current()?.saveInBackground{(success, error) in
            
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil{
                
                self.createAlert(title: "Could not post image", message: "Please try again later")
                
            }else{
                
                self.createAlert(title: "Image posted!", message: "Your image has been posted successfully")
                
                self.performSegue(withIdentifier: "toSwipeScreen", sender: self)
                
            }
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let isFemale = PFUser.current()?["isFemale"] as? Bool{
            genderSwitch.setOn(isFemale, animated: true)
        }
        
        if let isInterestedInFemale = PFUser.current()?["isInterestedInFemale"] as? Bool{
            interestedInSwitch.setOn(isInterestedInFemale, animated: true)
        }

        if let image = (PFUser.current()?["imageFile"]) as? PFFile{
            image.getDataInBackground{(data, error) in
                if let imageData = data{
                    
                    if let downloadedImage = UIImage(data: imageData){
                        
                        self.profilePic.image = downloadedImage
                        
                    }
                    
                }

            }
        }
        
        /*
        let urlArray = ["https://s-media-cache-ak0.pinimg.com/originals/10/ee/8c/10ee8cff813e76201125b58a9e81e53c.jpg", "http://images.complex.com/complex/image/upload/c_limit,w_680/fl_lossy,pg_1,q_auto/oi8aazaih39hvzbqoxul.jpg", "https://s-media-cache-ak0.pinimg.com/236x/a6/88/41/a6884189181e82070c818c5faab9d726--monsters-ink-boo-from-monsters-inc.jpg", "https://s-media-cache-ak0.pinimg.com/736x/6f/80/87/6f8087afb1fde7707ccf379298e02f19--disney-princess-cartoons-disney-characters.jpg", "https://itfinspiringwomen.files.wordpress.com/2014/03/scooby-doo-tv-09.jpg", "https://qph.ec.quoracdn.net/main-qimg-38d5f106ecda74858f640774a9e36d1d-c"]
        
        var counter = 0
        
        for urlString in urlArray{
            
            counter += 1
            
            let url = URL(string: urlString)!
            
            do{
            
                let data = try Data(contentsOf: url)
                
                let imageFile = PFFile(name: "photo.jpg", data: data)
                
                let user = PFUser()
                    
                user["imageFile"] = imageFile
                
                user.username = String(counter)
                
                user.password = "Password"
                
                user["isFemale"] = true
                
                user["isInterestedInFemale"] = false
                
                let acl = PFACL()
                
                acl.getPublicWriteAccess = true
                
                user.acl = acl
                
                user.signUpInBackground(block: {(success, error) in
                
                    if success{
                        print("User signed up")
                    }
                
                })
                
                    
            }catch{
                
            }

        }
    */
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
