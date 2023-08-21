//
//  PasskeyResultAPIModel.swift
//  Passkeys-Sample
//
//  Created by Bliss on 21/8/23.
//

import Foundation

struct PasskeyResultAPIModel: Decodable {

    let status: String

    var success: Bool { status == "ok" }
}
