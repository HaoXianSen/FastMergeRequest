//
//  FMRAccountModel.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/10/21.
//

import Foundation

public struct FMRUserModel: Codable {
    var avatar: String = ""
    var id: Int?
    var name: String = ""
    var state: String?
    var userName: String = ""
    var webUrl: String?
    var email: String?
    var privateToken: String?
    var host: String?
    var select: Bool?
    
    enum CodingKeys: String, CodingKey {
        case avatar = "avatar_url"
        case userName = "username"
        case webUrl = "web_url"
        case id
        case name
        case email
        case state
        case privateToken
        case host
        case select
    }
}
