//
//  SwipingViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Vanessa Chu on 2017-07-20.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipingViewController: UIViewController{
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    var displayedUserId = ""

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue"{
            PFUser.logOut()
        }
    }
    
    func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: view)
        
        let label = gestureRecognizer.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(abs(100 / xFromCenter), 1)
        
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale) // rotation.scaleBy(x: scale, y: scale) is now rotation.scaledBy(x: scale, y: scale)
        
        
        label.transform = stretchAndRotation
        
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            var acceptedOrRejected = ""
            
            if label.center.x < 100 {
                
                acceptedOrRejected = "rejected"
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                acceptedOrRejected = "accepted"
                
            }
            
            if acceptedOrRejected != "" && displayedUserId != ""{
                PFUser.current()?.addUniqueObject(displayedUserId, forKey: acceptedOrRejected)
                PFUser.current()?.saveInBackground(block: {(success, error) in

                    self.updateImage()
                })
            }
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
            
            label.transform = stretchAndRotation
            
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)

        }
        
        
        
    }
    
    func updateImage(){
        
        let query = PFUser.query()
        
        
        query?.whereKey("isFemale", equalTo: (PFUser.current()?["isInterestedInFemale"])!)
        query?.whereKey("isInterestedInFemale", equalTo: (PFUser.current()?["isFemale"])!)
        
        var ignoredUsers = [""]
        
        if let acceptedUsers = PFUser.current()?["accepted"]{
            ignoredUsers += acceptedUsers as! [String]
        }
        
        if let rejectedUsers = PFUser.current()?["rejected"]{
            ignoredUsers += rejectedUsers as! [String]
        }
        
        query?.whereKey("objectId", notContainedIn: ignoredUsers)
        
        
        if let userGeopoint = PFUser.current()?["location"] as? PFGeoPoint{
            let latitude = userGeopoint.latitude
            let longitude = userGeopoint.longitude
            
            query?.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1) , toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
        }

        query?.limit = 1
        
        query?.findObjectsInBackground(block: { (objects, error) in
            
            if let users = objects{
                
                if users.count > 0{
                
                    for object in users {
                
                        if let user = object as? PFUser{
                    
                            self.displayedUserId = user.objectId!
                            let imageFile = user["imageFile"] as! PFFile
                    
                            imageFile.getDataInBackground(block: { (data, error) in
                        
                                if let imageData = data{
                            
                                    self.imageView.image = UIImage(data: imageData)
                            
                                }
                        
                            })
                        }
                    
                    }
                }else{
                    self.imageView.image = UIImage(named: "person.png")
                    self.messageLabel.text = "No matches found"
                    
                }
            }
        })

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(gestureRecognizer:)))
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(gesture)
        
        PFGeoPoint.geoPointForCurrentLocation(inBackground: {(geopoint, error) in
            
            if let geopoint = geopoint{
                PFUser.current()?["location"] = geopoint
                PFUser.current()?.saveInBackground()
            }
            
        })
        
        updateImage()

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
