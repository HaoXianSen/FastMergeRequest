//
//  FMRVerify.swift
//  FastMergeRequest
//
//  Created by 郝玉鸿 on 2024/11/13.
//

import Foundation

public class FMRVerify {
    /// URL verify
    public static func validateUrlLegal(url: String) ->Bool {
        let hostRegex = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        let hostTest = NSPredicate(format: "SELF MATCHES %@", hostRegex)
        return hostTest.evaluate(with: url)
    }
    
    /// Email verify
    public static func validateEmail(email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}
