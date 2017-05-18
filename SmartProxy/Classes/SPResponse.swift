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
	init?(data: Any)
	static func parse(data: Any) throws -> Self
}

public protocol SPResponsable {
	func parse (_ rawResponse: DataResponse<Any>,
	            onSuccess: @escaping (SPResponse) -> Void,
	            onError: @escaping (SPError) -> Void)
	
	func processUnprocessableEntity(errorResponse: NSDictionary?,
	                                onError: @escaping (SPError) -> Void)
}

class SPInfo: SPParsable {
	required init?(data: Any) { }
	
	static func parse(data: Any) throws -> Self {
		if let info = self.init(data: data) {
			return info
		}
		throw SPError.unimplemented
	}
}

open class SPResponse: SPResponsable {
	
	required public init() { }
	
	open func parse (_ rawResponse: DataResponse<Any>,
	                 onSuccess: @escaping (SPResponse) -> Void,
	                 onError: @escaping (SPError) -> Void)
	{ }
	
	open func processUnprocessableEntity(errorResponse: NSDictionary?,
	                                     onError: @escaping (SPError) -> Void)
	{
		if let error = errorResponse?["error"] as? String {
			onError(.unprocessableEntity(info: error))
		}
		else {
			onError(.unexpectedFormat(produceErrorInfo()))
		}
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
			guard let raw = rawResponse.result.value as? Any else {
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
