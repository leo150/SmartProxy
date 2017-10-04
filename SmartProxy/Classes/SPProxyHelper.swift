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
