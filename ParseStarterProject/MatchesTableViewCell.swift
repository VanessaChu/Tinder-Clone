//
//  MatchesTableViewCell.swift
//  ParseStarterProject-Swift
//
//  Created by Vanessa Chu on 2017-07-21.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class MatchesTableViewCell: UITableViewCell {


    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var messageContent: UITextField!
    @IBOutlet var userId: UILabel!
    @IBOutlet var userImage: UIImageView!

    @IBAction func send(_ sender: Any) {
        let messages = PFObject(className: "Messages")
        
        messages["content"] = messageContent.text
        messages["sender"] = PFUser.current()?.objectId
        messages["recipient"] = userId.text
        
        messages.saveInBackground()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
