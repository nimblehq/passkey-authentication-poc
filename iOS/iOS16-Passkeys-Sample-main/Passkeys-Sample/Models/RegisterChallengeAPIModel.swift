//
//  RegisterChallengeAPIModel.swift
//  Passkeys-Sample
//
//  Created by Bliss on 21/8/23.
//

import Foundation

struct RegisterChallengeAPIModel: Decodable {

    struct User: Decodable {

        let id: String
        let name: String
    }

    let user: User
    let challenge: String
}
