//
//  ViewController.swift
//  Passkeys-Sample
//
//  Created by Hans Knöchel on 12.06.22.
//

import UIKit
import AuthenticationServices

class RegisterViewController: UIViewController {

    @IBOutlet var textField: UITextField?
    @IBOutlet var passwordTextField: UITextField?

    @IBAction func onSignUpButtonTapped(_ sender: UIButton) {
        signUpWith(userName: (textField?.text) ?? "", password: (passwordTextField?.text) ?? "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textField?.text = "hello@me.com"
    }

    func signUpWith(userName: String, password: String) {
        // Fetch the challenge from the server. The challenge needs to be unique for each request.
        // The userID is the identifier for the user's account.

        var urlRequst = URLRequest(url: URL(string: "https://rails-passkey-mobile-demo-90f7328f33ff.herokuapp.com/api/registrations")!)
        urlRequst.httpMethod = "POST"
        urlRequst.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let httpBody = try JSONSerialization.data(withJSONObject: ["registration": ["email": userName, "password": password]], options: [])
            urlRequst.httpBody = httpBody
        } catch let error {
            print(error)
        }

        let urlSession = URLSession(configuration: .default)
        var task: URLSessionDataTask?
        task = urlSession.dataTask(with: urlRequst) { data, response, error in

            guard let data else { return print(error?.localizedDescription) }
            print(String(data: data, encoding: .utf8))
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "go", sender: nil)
            }
        }
        task?.resume()
    }
}
