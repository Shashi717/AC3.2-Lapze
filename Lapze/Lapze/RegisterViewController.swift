//
//  RegisterViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    
    var databaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorPalette.logoGreenColor
        self.databaseRef = FIRDatabase.database().reference().child("users")
        setupViewHierarchy()
        configureConstraints()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func registerTapped(sender: UIButton) {
        print("Register")
        if let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text {
            
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Creating Error \(error.localizedDescription)")
                    let alertController = showAlert(title: "Registering Failed!", message: "Failed to Register. Please Try Again!", useDefaultAction: true)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else {
                    let alertController = showAlert(title: "Signup Successful!", message: "Successfully Registered. You will be automatically logged in!", useDefaultAction: false)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        //self.present(tbvc, animated: true, completion: nil)
                        
                        let userDict = ["name": username]
                        self.databaseRef.child((FIRAuth.auth()?.currentUser?.uid)!).setValue(userDict)
                        print("pressed ok")
                        self.clearTextFields()
                        let tabVC = EventsViewController()
                        self.navigationController?.pushViewController(tabVC, animated:true)
                        
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        self.view.addSubview(logoImageView)
        self.view.addSubview(usernameTextField)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(registerButton)
    }
    
    func configureConstraints() {
        
        logoImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.height.width.equalTo(225.0)
            view.top.equalToSuperview().offset(20.0)
        }
        usernameTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(logoImageView.snp.bottom).offset(25.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        emailTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(usernameTextField.snp.bottom).offset(16.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
            
        }
        passwordTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(emailTextField.snp.bottom).offset(16.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        registerButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(passwordTextField.snp.bottom).offset(16.0)
            view.width.equalTo(100.0)
            view.height.equalTo(30.0)
        }
        
    }
    
    func clearTextFields() {
        emailTextField.text = nil
        passwordTextField.text = nil
        usernameTextField.text = nil
    }
    
    internal lazy var logoImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Lapze_Logo")
        return imageView
    }()
    internal lazy var usernameTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        return textField
    }()
    internal lazy var emailTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    internal lazy var passwordTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    internal lazy var registerButton: UIButton! = {
        let button = UIButton()
        button.backgroundColor = ColorPalette.orangeThemeColor
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = false
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(registerTapped(sender:)), for: .touchUpInside)
        return button
    }()
}

public func showAlert(title: String, message: String?, useDefaultAction: Bool) -> UIAlertController {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    if useDefaultAction == true {
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
    }
    
    return alertController
}

