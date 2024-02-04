//
//  ProfileViewController.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 04/02/24.
//

import UIKit
import GoogleSignIn


class ProfileViewController: UIViewController {

    @IBOutlet weak var btnSignOut: UIButton!
    
    @IBOutlet weak var lblEmailid: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = GIDSignIn.sharedInstance()?.currentUser {
            let email = currentUser.profile.email
            lblEmailid.text = email
        } else {
            lblEmailid.text = "Not logged in"
        }
        DispatchQueue.main.async { [self] in
        self.btnSignOut.layer.cornerRadius = btnSignOut.bounds.height / 2

        }
    }
    

    @IBAction func BtnBack(_ sender: UIButton) {
        if let navigationController = navigationController, navigationController.viewControllers.count >= 2 {
            navigationController.popViewController(animated: true)
        } else {
            print("No view controller to pop to")
        }
    }
    @IBAction func BtnSignOut(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            GIDSignIn.sharedInstance()?.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    

}
