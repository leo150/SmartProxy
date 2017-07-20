//
//  SPRequestInfo.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/18/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import Alamofire

open class SPRequestInfo {
	
	fileprivate var _request: Request
	
	//TODO: implement Progress
	open var progress: Progress {
		get {
			return Progress()
		}
	}
	
	public init(with request: Request) {
		self._request = request
	}
	
	open func cancel () {
		self._request.cancel()
	}
	
	open func suspend() {
		self._request.suspend()
	}
	
	open func resume() {
		self._request.resume()
	}
	
	open func progress(_ closure: ((Int64, Int64, Int64) -> Void)?) {
		
	}
}

