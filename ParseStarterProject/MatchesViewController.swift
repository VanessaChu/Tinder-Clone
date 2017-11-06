//
//  MatchesViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Vanessa Chu on 2017-07-21.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var images = [PFFile]()
    var userIds = [String]()
    var messages = [String]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MatchesTableViewCell
        
        
        cell.messageLabel.text = messages[indexPath.row]
        
        cell.userId.text = userIds[indexPath.row]
        
        let imageFile = images[indexPath.row]
        
        imageFile.getDataInBackground(block: { (data, error) in
            
            if let imageData = data{
                
                cell.userImage.image = UIImage(data: imageData)
                
            }
            
        })
        
        return cell
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let userQuery = PFUser.query()
        
        userQuery?.whereKey("accepted", contains: (PFUser.current()?.objectId)!)
        
        userQuery?.whereKey("objectId", containedIn: (PFUser.current()?["accepted"])! as! [String])
        
        userQuery?.findObjectsInBackground(block: {(objects, error) in
        
            if let users = objects{
                
                self.images.removeAll()
                self.userIds.removeAll()
                self.messages.removeAll()
                
                for object in users{
                    
                    if let user = object as? PFUser{
                        
                        
                        let messageQuery = PFQuery(className: "Messages")
                        
                        messageQuery.whereKey("recipient", equalTo: (PFUser.current()?.objectId)!)
                        messageQuery.whereKey("sender", equalTo: (user.objectId)!)
                        
                        messageQuery.findObjectsInBackground(block: {(objects, error) in
                            var displayMessage = "No messages from this user"
                            if let messages = objects{
                                for message in messages{
                                    if let content = message["content"] as? String{
                                        displayMessage = content
                                    }
                                    
                                }
                                
                            }
                            self.messages.append(displayMessage)
                            self.userIds.append(user.objectId!)
                            self.images.append(user["imageFile"] as! PFFile)
                            self.tableView.reloadData()
                            
                        })
                        
                        
                        
                    }
                    
                    
                }
                
            }
        
        })
        
        
        
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
