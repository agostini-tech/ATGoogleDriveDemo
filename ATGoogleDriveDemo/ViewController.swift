//
//  ViewController.swift
//  ATGoogleDriveDemo
//
//  Created by Dejan on 09/04/2018.
//  Copyright © 2018 Dejan. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class ViewController: UIViewController {

    @IBOutlet weak var resultsLabel: UILabel!
    
    fileprivate let service = GTLRDriveService()
    private var drive: ATGoogleDrive?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGoogleSignIn()
        
        drive = ATGoogleDrive(service)
        
        view.addSubview(GIDSignInButton())
    }
    
    private func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveFile]
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    // MARK: - Actions
    @IBAction func uploadAction(_ sender: Any) {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let testFilePath = documentsDir.appendingPathComponent("logo.png").path
            drive?.uploadFile("agostini_tech_demo", filePath: testFilePath, MIMEType: "image/png") { (fileID, error) in
                print("Upload file ID: \(fileID); Error: \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func listAction(_ sender: Any) {
        drive?.listFilesInFolder("agostini_tech_demo") { (files, error) in
            guard let fileList = files else {
                print("Error listing files: \(error?.localizedDescription)")
                return
            }
            
            self.resultsLabel.text = fileList.files?.description
        }
    }
}

// MARK: - GIDSignInDelegate
extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()

            drive?.search("agostini_tech_demo") { (objectID, error) in
                print("ObjectID: \(objectID); Error: \(error?.localizedDescription)")
            }
        }
    }
}

// MARK: - GIDSignInUIDelegate
extension ViewController: GIDSignInUIDelegate {}
