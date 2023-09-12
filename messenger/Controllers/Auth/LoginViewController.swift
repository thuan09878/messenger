//
//  LoginViewController.swift
//  messenger
//
//  Created by sotatek on 28/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.clipsToBounds = true
        return view
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let passwordField1: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font  = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let loginWithGoogle = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginWithGoogle.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(loginWithGoogle)
        
        fbLoginButton.delegate = self
        scrollView.addSubview(fbLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/4
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: view.top + 20, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
        
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60, height: 52)
        
        
        fbLoginButton.center = scrollView.center
        fbLoginButton.frame = CGRect(x: 30, y: loginButton.bottom + 20, width: scrollView.width - 60, height: 52)
        
        loginWithGoogle.frame = CGRect(x: 30, y: fbLoginButton.bottom + 20, width: scrollView.width - 60, height: 52)
        
        //        googleSignInButton.frame.origin.y = fbLoginButton.bottom + 20
    }
    
    @objc private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError()
        }
        
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = signInConfig
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                print("Google sign in error: \(String(describing: error))")
                return
            }
            
            // If sign in succeeded, display the app's main content View.
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString,
                  let email = user.profile?.email,
                  let firstName = user.profile?.givenName
            else {
                return
            }
            
            let chatUser = ChatAppUser(firstName: firstName,
                                   lastName: user.profile?.familyName ?? "",
                                   email: email)
            
            DatabaseManager.shared.emailExists(with: email, completion: {exists in
                if !exists {
                    DatabaseManager.shared.inserUser(with: chatUser) {[weak self] result in
                        guard let strongSelf = self else {
                            return
                        }
//                        strongSelf.uploadProfilePicture(user: chatUser, strongSelf: strongSelf, data: )
                    }
                }
            })
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    print("Google sign in credential failed - \(String(describing: error))!")
                    return
                }
                
                strongSelf.navigationController?.dismiss(animated: true)
            })
            
        }
    }
    
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
         
        spinner.show(in: view)
        //Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard authResult != nil, error == nil else {
                print("Error logging in user: \(String(describing: error))")
                return
            }
            strongSelf.navigationController?.dismiss(animated: true)
        })
    }
    
    private func uploadProfilePicture(user: ChatAppUser, strongSelf: LoginViewController, data: Data) {
        StorageManager.shared.uploadProfilePicture(with: data, fileName: user.profilePictureFileName) { result in
            switch result {
            case .success(let downloadUrl):
                print(downloadUrl)
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        }

    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to log in!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
        
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // Show log out button when user already login with facebook
        // No operation
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Login facebook failed!")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: {_, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("facebookRequest failed: \(String(describing: error))")
                return
            }
            print(result)
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String,
                  let email = result["email"] as? String else {
                print("Get name and email from facebook failed")
                return
            }
            
            
            DatabaseManager.shared.emailExists(with: email, completion: {exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, email: email)
                    DatabaseManager.shared.inserUser(with: chatUser) {[weak self] sucess in
                        print("inserUser: \(sucess)")

                        if sucess {
                            guard let strongSelf = self else {
                                print("1")
                                return
                            }
                            
                            guard let url = URL(string: pictureUrl) else {
                                print("2")
                                return
                            }

                            print("Get image data from url: \(pictureUrl)")
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                                print("aaaa: \(String(describing: data))")
                                guard let data = data else {
                                    print("Get data from facebook error: \(error)")
                                    return
                                }
                                print("Get data from facebook OK")

                                strongSelf.uploadProfilePicture(user: chatUser, strongSelf: strongSelf, data: data)
                            })
                        }
                    }
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self]authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    print("Facebook creadential login failed, MFA may be needed - \(String(describing: error))!")
                    return
                }
                
                strongSelf.navigationController?.dismiss(animated: true)
            })
        })
    }
}
