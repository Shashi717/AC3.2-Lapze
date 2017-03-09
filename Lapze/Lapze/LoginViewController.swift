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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorPalette.logoGreenColor
        setupViewHierarchy()
        configureConstraints()
        
        observeKeyboardNotifications()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
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
                        self.dismiss(animated: true, completion: nil)
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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: .UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: .UIKeyboardDidHide, object: nil)
    }
    
    func showKeyboard() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    func hideKeyboard(notification: NSNotification) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = CGRect(x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: nil)
    }
    

    
    
    
    
    //MARK: - Setup
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
    
    //MARK: - View init
    internal lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Lapze_Logo")
        return imageView
    }()
    internal lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    internal lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        return textField
    }()
    internal lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ColorPalette.orangeThemeColor
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = false
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginTapped(sender:)), for: .touchUpInside)
        return button
    }()
    internal lazy var gotoRegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Don't have an account?", for: .normal)
        button.addTarget(self, action: #selector(gotoRegisterTapped(sender:)), for: .touchUpInside)
        return button
    }()

}
