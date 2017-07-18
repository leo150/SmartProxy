//
//  SPResponse.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/12/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import Alamofire

public protocol SPParsable: class {
	init(data: Any) throws
	static func parse(data: Any) throws -> Self
}

public protocol SPResponsable {
	func parse (_ rawResponse: DataResponse<Any>,
	            onSuccess: @escaping (SPResponse) -> Void,
	            onError: @escaping (SPError) -> Void)
	
	func processUnprocessableEntity(errorResponse: Dictionary<String, Any>?,
	                                onError: @escaping (SPError) -> Void)
}

open class SPInfo: SPParsable {
	public required init(data: Any) throws { }
	
	public static func parse(data: Any) throws -> Self {
		return try self.init(data: data)
	}
	
	open func produceErrorInfo(_ info: String? = nil,
	                           file: String = #file,
	                           line: Int = #line) -> String
	{
		return "\(file) at line \(line): \(String(describing: info))"
	}
	
	open func getRequiredField<T>(_ json: Dictionary<String, Any>, _ key: String,
	                           logIfFail: Bool = false, method: String? = #function,
	                           file: String? = #file, line: Int = #line) -> T?
	{
		guard let value = json[key] as? T else {
			let errorMsg = "Trying to get value from key \"\(key)\" that not exists. Method: \(String(describing: method)) file: \(String(describing: file)) line: \(line)"
			print(errorMsg)
			return nil
		}
		return value
	}
	
	open func getOptionalField<T>(_ json: Dictionary<String, Any>, _ key: String) -> T? {
		return json[key] as? T
	}
}

open class SPResponse: SPResponsable {
	
	required public init() { }
	
	open func parse (_ rawResponse: DataResponse<Any>,
	                 onSuccess: @escaping (SPResponse) -> Void,
	                 onError: @escaping (SPError) -> Void)
	{ }
	
	open func processUnprocessableEntity(errorResponse: Dictionary<String, Any>?,
	                                     onError: @escaping (SPError) -> Void)
	{
		if let error = errorResponse?["error"] as? String {
			onError(.unprocessableEntity(info: error))
		}
		else {
			onError(.unexpectedFormat(produceErrorInfo()))
		}
	}
	
	open func produceErrorInfo(_ info: String? = nil,
	                             file: String = #file,
	                             line: Int = #line) -> String
	{
		return "\(file) at line \(line): \(String(describing: info))"
	}
	
	open func getRequiredField<T>(_ json: Dictionary<String, Any>, _ key: String,
	                           logIfFail: Bool = false, method: String? = #function,
	                           file: String? = #file, line: Int = #line) -> T?
	{
		guard let value = json[key] as? T else {
			let errorMsg = "Trying to get value from key \"\(key)\" that not exists. Method: \(String(describing: method)) file: \(String(describing: file)) line: \(line)"
			print(errorMsg)
			return nil
		}
		return value
	}
	
	open func getOptionalField<T>(_ json: Dictionary<String, Any>, _ key: String) -> T? {
		return json[key] as? T
	}
}

open class SPDataResponse<I: SPParsable>: SPResponse {
	
	open fileprivate(set) var data: I!
	
	open fileprivate(set) var successCode: Int = 200
	open fileprivate(set) var wrongCredentialsCode: Int = 401
	
	open override func parse (_ rawResponse: DataResponse<Any>,
	                          onSuccess: @escaping (SPResponse) -> Void,
	                          onError: @escaping (SPError) -> Void)
	{
		guard let unpackedResponse = rawResponse.response else {
			onError(.connectionError); return
		}
		
		let statusCode = unpackedResponse.statusCode
		
		switch (statusCode) {
			
		case successCode:
			guard let raw = rawResponse.result.value else {
				onError(.unexpectedFormat(produceErrorInfo())); return
			}
			
			do {
				self.data = try I.parse(data: raw)
			}
			catch let error {
				onError(SPError(error)); return
			}
			
			onSuccess(self)
			
		case wrongCredentialsCode:
			onError(.wrongCredentials)
			
		default:
			onError(.unexpectedStatusCode(statusCode))
		}
	}
}
