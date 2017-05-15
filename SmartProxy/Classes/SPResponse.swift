//
//  SPResponse.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/12/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import Alamofire

open class SPResponse {
	
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
