//
//  ViewController.swift
//  Passkeys-Sample
//
//  Created by Hans Knöchel on 12.06.22.
//

import UIKit
import AuthenticationServices

class AddPasskeyViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
    @IBOutlet var labelTextField: UITextField?

    @IBAction func onButtonTapped(_ sender: UIButton) {
        performAddPasskey(label: (labelTextField?.text) ?? "")
    }

    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Constant.providerId)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func performAddPasskey(label: String) {
        // Fetch the challenge from the server. The challenge needs to be unique for each request.
        // The userID is the identifier for the user's account.

        var urlRequst = URLRequest(url: URL(string: "https://rails-passkey-mobile-demo-90f7328f33ff.herokuapp.com/api/registrations/challenge")!)
        urlRequst.httpMethod = "POST"
        urlRequst.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequst.setValue( "Bearer \(currentToken ?? "")", forHTTPHeaderField: "Authorization")

        let urlSession = URLSession(configuration: .default)
        var task: URLSessionDataTask?
        task = urlSession.dataTask(with: urlRequst) { data, response, error in

            do {
                print(String(data: data!, encoding: .utf8))
                let challengeJson = try JSONDecoder().decode(RegisterChallengeAPIModel.self, from: data!)
                let challengeString = challengeJson.challenge
                let userIdString = challengeJson.user.id

                let challengeData = Data(referencing: NSData(base64Encoded: challengeString.base64urlToBase64()) ?? NSData())
                let userID = Data(referencing: NSData(base64Encoded: userIdString.base64urlToBase64()) ?? NSData())

                let registrationRequest = self.platformProvider.createCredentialRegistrationRequest(challenge: challengeData,
                                                                                                    name: challengeJson.user.name, userID: userID)

                // Use only ASAuthorizationPlatformPublicKeyCredentialRegistrationRequests or
                // ASAuthorizationSecurityKeyPublicKeyCredentialRegistrationRequests here.
                let authController = ASAuthorizationController(authorizationRequests: [ registrationRequest ] )
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

extension AddPasskeyViewController : ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
//            showAlert(with: "Authorized with Passkeys", message: "Create account with credential ID = \(credential.credentialID)")

            print(String(data: credential.rawClientDataJSON, encoding: .utf8))
            print(String(data: credential.credentialID, encoding: .utf8))
            print(String(data: credential.rawAttestationObject!, encoding: .utf8))
//            print(credential.rawAttestationObject?.base64EncodedString().base64ToBase64url())

            let clientDataJSON = credential.rawClientDataJSON
            let credentialID = credential.credentialID

            var urlRequst = URLRequest(url: URL(string: "https://rails-passkey-mobile-demo-90f7328f33ff.herokuapp.com/api/registrations/callback")!)
            urlRequst.httpMethod = "POST"
            urlRequst.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequst.setValue( "Bearer \(currentToken ?? "")", forHTTPHeaderField: "Authorization")

            do {
                let httpBody = try JSONSerialization.data(withJSONObject: [
                    "credential_label": (labelTextField?.text ?? ""),
                    "id": credential.credentialID.base64EncodedString().base64ToBase64url(),
                    "rawId": credential.credentialID.base64EncodedString().base64ToBase64url(),
                    "type":"public-key",
                    "authenticatorAttachment": "platform",
                    "clientExtensionResults": [:],
                    "response": [
                        "clientDataJSON": clientDataJSON.base64EncodedString().base64ToBase64url(),
                        "attestationObject": credential.rawAttestationObject?.base64EncodedString().base64ToBase64url(),
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
                        self.performSegue(withIdentifier: "go2", sender: nil)
                    }
                } catch {
                    print(String(data: data!, encoding: .utf8))
                    print(error.localizedDescription)
                }
            }
            task?.resume()
            // Take steps to handle the registration.
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            showAlert(with: "Authorized with Passkeys", message: "Sign in with credential ID = \(credential.credentialID)")
            let signature = credential.signature
            let clientDataJSON = credential.rawClientDataJSON

            // Take steps to verify the challenge by sending it to your server tio verify
        } else {
            showAlert(with: "Authorized", message: "e.g. with \"Sign in with Apple\"")
            // Handle other authentication cases, such as Sign in with Apple.
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(with: "Error", message: error.localizedDescription)
    }
}

extension String {
    func base64ToBase64url() -> String {
        self
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    func base64urlToBase64() -> String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
}

