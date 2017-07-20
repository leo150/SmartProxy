//
//  SPPutRequest.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/15/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import Alamofire

open class SPPutRequest<TResponse: SPResponse>: SPPostRequest<TResponse> {
	
	public override init() {
		super.init()
	}
	
	public override init(withAccessToken accessToken : String) {
		super.init(withAccessToken: accessToken)
	}
	
	open override var method: HTTPMethod {
		return .put
	}
}
