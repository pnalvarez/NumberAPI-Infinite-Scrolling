//
//  NumberModel.swift
//  NumberApiPrefetchDemo
//
//  Created by Pedro Alvarez on 14/05/22.
//

struct NumberModel: Decodable {
    let text: String?
    let number: Int?
    let found: Bool?
    let type: String?
}
