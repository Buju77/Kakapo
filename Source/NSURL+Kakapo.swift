//
//  NSURL+Kakapo.swift
//  Kakapo
//
//  Created by Joan Romano on 31/03/16.
//  Copyright © 2016 devlucky. All rights reserved.
//

import Foundation

public typealias URLInfo = (components: [String : String], queryParameters: [String : String])

/// parseUrl: Checks and parses if a given `handleURL` representation matches a `requestURL`. Examples:
///
///
///     `/users/:id` with `/users/1` produces `queryParameters: ["id" : "1"]`
///     `/users/:id/comments` with `/users/1/comments` produces `queryParameters: ["id" : "1"]`
///     `/users/:id/comments/:comment_id` with `/users/1/comments/2?page=2&author=hector` produces `queryParameters: ["id": "1", "comment_id": "2"]` and `params: ["page": "2", "author": "hector"]`
///
/// - Parameter handlerURL: the URL with dynamic paths
/// - Parameter requestURL: the actual URL
/// - Returns: URLParams
func parseUrl(handlerURL: String, requestURL: String) -> URLInfo? {
    var params: [String : String] = [:]
    var queryParameters: [String : String] = [:]
    
    let handlerURLPaths = splitUrl(handlerURL, withSeparator: ":")
    var requestURLSections = splitUrl(requestURL, withSeparator: "?")
    var requestURLParams = requestURLSections[0]
    
    guard splitUrl(handlerURL, withSeparator: "/").count == splitUrl(requestURLParams, withSeparator: "/").count else {
        return nil
    }
    
    for (index, path) in handlerURLPaths.enumerate() {
        guard requestURLParams.rangeOfString(path) != nil else {
            return nil
        }
        
        requestURLParams = replaceUrl(requestURLParams, find: path, with: "")
        let nextPaths = splitUrl(requestURLParams, withSeparator: "/")
        
        if let next = nextPaths.first {
            if let key = splitUrl(handlerURLPaths[index + 1], withSeparator: "/").first {
                requestURLParams = replaceUrl(requestURLParams, find: next, with: key)
                params[key] = next
            }
        }
    }
    
    if requestURLSections.count > 1 {
        let queryParametersUrl = splitUrl(requestURLSections[1], withSeparator: "&")
        for param in queryParametersUrl {
            let values = splitUrl(param, withSeparator: "=")
            queryParameters[values[0]] = values[1]
        }
    }
    
    return (params, queryParameters)
}

private func splitUrl(url: String, withSeparator separator: Character) -> [String] {
    return url.characters.split(separator).map{ String($0) }
}

private func replaceUrl(source: String, find: String, with: String) -> String {
    return source.stringByReplacingOccurrencesOfString(find, withString: with)
}

    