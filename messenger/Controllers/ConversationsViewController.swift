//
//  ViewController.swift
//  messenger
//
//  Created by sotatek on 28/08/2023.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {
    
    private let logoutButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font  = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Conversations"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(logout))
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

        
        view.addSubview(logoutButton)
    }
    
    @objc private func logout() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            validateAuth()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoutButton.frame = CGRect(x: 30, y: view.top + 50, width: view.width - 60, height: 52)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

