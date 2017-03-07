//
//  LoginViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorPalette.logoGreenColor
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
    
    func loginTapped(sender: UIButton) {
        print("Login")
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Login Error \(error.localizedDescription)")
                    let alertController = showAlert(title: "Login Failed!", message: "Failed to Login. Please Check Your Email and Password!", useDefaultAction: true)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    let alertController = showAlert(title: "Login Successful!", message: nil, useDefaultAction: false)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        self.clearTextFields()
                        let tabVC = EventsViewController()
                        self.navigationController?.pushViewController(tabVC, animated:true)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    func gotoRegisterTapped(sender: UIButton) {
        print("signup")
        
        let registerVC = RegisterViewController()
        self.navigationController?.pushViewController(registerVC, animated:true)
    }
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        self.view.addSubview(logoImageView)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(loginButton)
        self.view.addSubview(gotoRegisterButton)
    }
    
    func configureConstraints() {
        
        logoImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.height.width.equalTo(225.0)
            view.top.equalToSuperview().offset(20.0)
        }
        emailTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(logoImageView.snp.bottom).offset(25.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        passwordTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(emailTextField.snp.bottom).offset(16.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
            
        }
        loginButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(passwordTextField.snp.bottom).offset(16.0)
            view.width.equalTo(100.0)
            view.height.equalTo(30.0)
        }
        gotoRegisterButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(loginButton.snp.bottom).offset(8.0)
            view.width.equalTo(200.0)
            view.height.equalTo(30.0)
        }
        
    }
    
    
    func clearTextFields() {
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    internal lazy var logoImageView: UIImageView! = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Lapze_Logo")
        return imageView
    }()
    internal lazy var emailTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    internal lazy var passwordTextField: UITextField! = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        return textField
    }()
    internal lazy var loginButton: UIButton! = {
        let button = UIButton()
        button.backgroundColor = ColorPalette.orangeThemeColor
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = false
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginTapped(sender:)), for: .touchUpInside)
        return button
    }()
    internal lazy var gotoRegisterButton: UIButton! = {
        let button = UIButton()
        button.setTitle("Don't have an account?", for: .normal)
        button.addTarget(self, action: #selector(gotoRegisterTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    
}
