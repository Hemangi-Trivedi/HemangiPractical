//
//  ViewController.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 02/02/24.
//

import UIKit
import GoogleSignIn
import Firebase

class ViewController: UIViewController,GIDSignInDelegate{
   
    @IBOutlet weak var googleLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleLogin(presentingViewController: self)
        roundcorner()

    }
    func roundcorner(){
        DispatchQueue.main.async { [self] in
        self.googleLogin.layer.cornerRadius = googleLogin.bounds.height / 2

        }
    }
    func applyGradient(baseview:UIView,with colours: [UIColor], locations: [NSNumber]? = nil) {
        let gradient = CAGradientLayer()
        gradient.frame = baseview.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.cornerRadius = baseview.bounds.height / 2
        baseview.layer.insertSublayer(gradient, at: 0)
    }

    func GoogleLogin(presentingViewController: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = presentingViewController
        GIDSignIn.sharedInstance()?.delegate = presentingViewController as? GIDSignInDelegate
        
        if  GIDSignIn.sharedInstance()?.hasPreviousSignIn() != nil{
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            print("already login")
        }
        
//        if GIDSignIn.sharedInstance()?.currentUser != nil{
//            print(GIDSignIn.sharedInstance()?.currentUser)
//            print("already login")
//        }
    }


    @IBAction func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            if let error = error {
                // Handle sign-in error
                print("Google Sign-In error: \(error.localizedDescription)")
                return
            }
            
            // Sign-in successful
            guard let authentication = user.authentication else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
           Auth.auth().signIn(with: credential) { (authResult, error) in
               let next = (self.storyboard?.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController)!
               self.navigationController?.pushViewController(next, animated: true)
             }
        }
    
   
}

