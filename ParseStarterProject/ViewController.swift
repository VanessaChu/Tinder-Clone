/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signupOrLogin: UIButton!
    @IBOutlet var changeSignUpMode: UIButton!
    @IBOutlet var messageLabel: UILabel!
    
    var signupMode = true
    var activityIndicator = UIActivityIndicatorView()
    
    func createAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action) in
            
            self.dismiss(animated: true, completion: nil)
          
        }))
    
        self.present(alertController, animated: true, completion:nil)
    
    }
    
    @IBAction func signupOrLogin(_ sender: Any) {
        //Sign Up
        if usernameTextField.text == "" ||
            
            passwordTextField.text == ""{
            
            print("Enter a username and password")
        
        }else{
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        
            if signupMode{
            
                let user = PFUser()
            
                user.username = usernameTextField.text
                
                user.password = passwordTextField.text
                
                let acl = PFACL()
                
                acl.getPublicWriteAccess = true
                
                acl.getPublicReadAccess = true
                
                user.acl = acl
            
                user.signUpInBackground(block: {(objects,
                    error) in
                
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                
                    var displayErrorMessage = "Please try again later"
                    
                    if error != nil{
                    
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                            
                            displayErrorMessage = errorMessage
                        
                        }
                        
                        self.createAlert(title:"Sign up error", message: displayErrorMessage)
                    
                        
                    }else{
                    
                        print("User Signed Up")
                        
                        self.performSegue(withIdentifier: "toUserDetails", sender: self)
                    
                    }
                
                })
            
            }else{
            
            //Log In
            
                PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!, block: {(user, error) in
                
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                
                    if error != nil{
                        
                        var displayErrorMessage = "Please try again later"
                        
                        if error != nil{
                            
                            if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                                
                                displayErrorMessage = errorMessage
                                
                            }
                            
                            self.createAlert(title:"Log in error", message: displayErrorMessage)
                        }
                    
                    }else{
                    
                        print("Logged In")
                        
                        if PFUser.current()?["isFemale"] != nil && PFUser.current()?["isInterestedInFemale"] != nil && PFUser.current()?["imageFile"] != nil{
                            self.performSegue(withIdentifier: "toSwipeScreen", sender: self)
                        }else{
                            self.performSegue(withIdentifier: "toUserDetails", sender: self)
                        }
                        
                    }
                
                })
                
            }
        }
    }
    
    @IBAction func changeSignUpMode(_ sender: Any) {
        
        if signupMode{
            
            messageLabel.text = "Already have an account?"
            
            signupOrLogin.setTitle("Log In", for: [])
            
            changeSignUpMode.setTitle("Sign Up", for: [])
            
            signupMode = false
            
        }else{
            
            messageLabel.text = "Don't have an account?"
            
            signupOrLogin.setTitle("Sign Up", for: [])
            
            changeSignUpMode.setTitle("Log In", for: [])
            
            signupMode = true
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current() != nil{
            if PFUser.current()?["isFemale"] != nil && PFUser.current()?["isInterestedInFemale"] != nil && PFUser.current()?["imageFile"] != nil{
                performSegue(withIdentifier: "toSwipeScreen", sender: self)
            }else{
                performSegue(withIdentifier: "toUserDetails", sender: self)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
