//
//  SPError.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/15/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation

public enum SPError: Error {
	case connectionError
	case unexpectedFormat(String)
	case unexpectedStatusCode(Int)
	case wrongCredentials
	case unprocessableEntity(info: String)
	
	public init(_ error: Error) {
		self = error as? SPError ?? .unexpectedFormat("\(error)")
	}
	
	func toNSError() -> NSError {
		return NSError(domain: errorDomain(), code: -1, userInfo: errorUserInfo())
	}
	
	func errorDomain() -> String {
		return "SPError"
	}
	
	func errorUserInfo() -> Dictionary<String, String>? {
		var resultInfo = Dictionary<String,String>()
		
		resultInfo["errorName"] = "\(self)"
		switch self {
		case .unexpectedFormat(let info):
			resultInfo["error"] = info
			
		case .unexpectedStatusCode(let code):
			resultInfo["statusCode"] = "\(code)"
			
		case .unprocessableEntity(let info):
			resultInfo["error"] = "\(info)"
			
		default: break
		}
		
		return resultInfo
	}
	
	public var description: String {
		switch self {
		case .connectionError:
			return "Connection error. Please try again."
			
		case .wrongCredentials:
			return "Your session has expired. Please log in again."
			
		case .unprocessableEntity(let info):
			return info
			
		case .unexpectedStatusCode,
		     .unexpectedFormat:
			return "Internal error. Please try again later."
			
		}
	}
}
