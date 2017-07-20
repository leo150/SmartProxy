//
//  ServerProxyHelper.swift
//  SMART
//
//  Created by Лев Соколов on 06/07/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
//import RFISO8601DateTime

extension JSON: ParameterEncoding {
	public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
		var urlRequest = try urlRequest.asURLRequest()
		
		do {
			urlRequest.httpBody = try rawData()
		}
		catch {
			print("ParameterEncoding: rawData() fail")
		}
		
		if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
			urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		}
		
		return urlRequest
	}
}

//public func produceErrorInfo(_ info: String? = nil, file: String = #file, line: Int = #line) -> String { return "\(file) at line \(line): \(info)"}
//
//public func getRequiredField<T>(_ json: NSDictionary, _ key: String, logIfFail: Bool = false, method: String? = #function, file: String? = #file, line: Int = #line) -> T? {
//	guard let value = json[key] as? T else {
//		let errorMsg = "Trying to get value from key \"\(key)\" that not exists. Method: \(method) file: \(file) line: \(line)"
//		print(errorMsg)
//		return nil
//	}
//	return value
//}

//public func getOptionalField<T>(_ json: NSDictionary, _ key: String) -> T? {
//	return json[key] as? T
//}
//
//public extension Date {
//	static func parseServerDateString(_ str: String) throws -> Date {
//		if let date = Date.parseDateString(str) {
//			return date
//		}
//		throw SPError.unexpectedFormat(produceErrorInfo())
//	}
//	
//	internal func serverDateFormatted() -> String {
//		let dateFormatter = DateFormatter()
//		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
//		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
//		
//		return dateFormatter.string(from: self)
//	}
//}
//
//internal func printWarning(_ text: String) {
//	print("Warning: \(text)")
//}
