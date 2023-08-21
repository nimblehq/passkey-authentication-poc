//
//  ViewController.swift
//  Passkeys-Sample
//
//  Created by Hans Knöchel on 12.06.22.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
    @IBOutlet var textField: UITextField?
    @IBOutlet var passwordTextField: UITextField?

    @IBAction func onButtonTapped(_ sender: UIButton) {
        performSignIn(userName: (textField?.text) ?? "", password: (passwordTextField?.text) ?? "")
    }

    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Constant.providerId)

    override func viewDidLoad() {
        super.viewDidLoad()
        textField?.text = "hello@me.com"
    }

    private func performSignIn(userName: String, password: String) {
        var urlRequst = URLRequest(url: URL(string: "http://localhost:3000/api/sign-in")!)
        urlRequst.httpMethod = "POST"
        urlRequst.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let httpBody = try JSONSerialization.data(withJSONObject: ["session": ["email": userName, "password": password]], options: [])
            urlRequst.httpBody = httpBody
        } catch let error {
            print(error)
        }

        let urlSession = URLSession(configuration: .default)
        var task: URLSessionDataTask?
        task = urlSession.dataTask(with: urlRequst) { data, response, error in

            do {
                let token = try JSONDecoder().decode(TokenAPIModel.self, from: data!)
                print(String(data: data!, encoding: .utf8))
                print(token)
                currentToken = token.access_token

                guard let data else { return print(error?.localizedDescription) }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "go", sender: nil)
                }
            } catch {
                print(String(data: data!, encoding: .utf8))
                print(error.localizedDescription)

                self.performPasskeySignIn(userName: userName, password: password)
            }
        }
        task?.resume()
    }

    private func performPasskeySignIn(userName: String, password: String) {
        // Fetch the challenge from the server. The challenge needs to be unique for each request.
        // The userID is the identifier for the user's account.

        var urlRequst = URLRequest(url: URL(string: "https://rails-passkey-mobile-demo-90f7328f33ff.herokuapp.com/api/sign-in/challenge")!)
        urlRequst.httpMethod = "POST"
        urlRequst.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let httpBody = try JSONSerialization.data(withJSONObject: ["session": ["email": userName, "password": password]], options: [])
            urlRequst.httpBody = httpBody
        } catch let error {
            print(error)
        }

        let urlSession = URLSession(configuration: .default)
        var task: URLSessionDataTask?
        task = urlSession.dataTask(with: urlRequst) { data, response, error in
            do {
                print(String(data: data!, encoding: .utf8))
                let challengeJson = try JSONDecoder().decode(SignInChallengeAPIModel.self, from: data!)
                let challengeString = challengeJson.challenge

                let challengeData = Data(referencing: NSData(base64Encoded: challengeString.base64urlToBase64()) ?? NSData())

                let signInRequest = self.platformProvider.createCredentialAssertionRequest(challenge: challengeData)

                // Use only ASAuthorizationPlatformPublicKeyCredentialRegistrationRequests or
                // ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequests here.
                let authController = ASAuthorizationController(authorizationRequests: [ signInRequest ] )
                authController.delegate = self
                authController.presentationContextProvider = self
                authController.performRequests()
            } catch {
                print(String(data: data!, encoding: .utf8))
                print(error.localizedDescription)
            }
        }
        task?.resume()
    }

    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: false)
    }
}

// MARK: ASAuthorizationControllerDelegate

extension ViewController : ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            showAlert(with: "Authorized with Passkeys", message: "Create account with credential ID = \(credential.credentialID)")
            // Take steps to handle the registration.
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            showAlert(with: "Authorized with Passkeys", message: "Sign in with credential ID = \(credential.credentialID)")

            let signature = credential.signature
            let userId = credential.userID
            let clientDataJSON = credential.rawClientDataJSON
            let credentialID = credential.credentialID

            var urlRequst = URLRequest(url: URL(string: "https://rails-passkey-mobile-demo-90f7328f33ff.herokuapp.com/api/sign-in/callback")!)
            urlRequst.httpMethod = "POST"
            urlRequst.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let httpBody = try JSONSerialization.data(withJSONObject: [
                    "session": [
                        "email": (textField?.text ?? ""),
                    ],
                    "id": credential.credentialID.base64EncodedString().base64ToBase64url(),
                    "rawId": credential.credentialID.base64EncodedString().base64ToBase64url(),
                    "type":"public-key",
                    "authenticatorAttachment": "platform",
                    "clientExtensionResults": [:],
                    "response": [
                        "authenticatorData": credential.rawAuthenticatorData.base64EncodedString().base64ToBase64url(),
                        "clientDataJSON": clientDataJSON.base64EncodedString().base64ToBase64url(),
                        "signature": credential.signature.base64EncodedString().base64ToBase64url(),
                        "transports": ["internal", "hybrid"]
                    ]
                ], options: [])
                urlRequst.httpBody = httpBody
            } catch let error {
                print(error)
            }

            let urlSession = URLSession(configuration: .default)
            var task: URLSessionDataTask?
            task = urlSession.dataTask(with: urlRequst) { data, response, error in
                do {
                    print(String(data: data!, encoding: .utf8))
                    DispatchQueue.main.async {
//                        self.showAlert(with: "Done", message: "Done")
                        self.performSegue(withIdentifier: "go", sender: nil)
                    }
                } catch {
                    print(String(data: data!, encoding: .utf8))
                    print(error.localizedDescription)
                }
            }
            task?.resume()
            // Take steps to handle the registration.
        } else {
            showAlert(with: "Authorized", message: "e.g. with \"Sign in with Apple\"")
            // Handle other authentication cases, such as Sign in with Apple.
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(with: "Error", message: error.localizedDescription)
    }
}
