//
//  SPGetRequest.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/15/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class SPGetRequest<TResponse: SPResponse>: SPRequest<TResponse> {
	
	public override init() {
		super.init()
	}
	
	public override init(withAccessToken accessToken: String) {
		super.init(withAccessToken: accessToken)
	}
	
	open var httpBody: JSON? {
		get {
			return nil
		}
	}
	
	open override var method: HTTPMethod {
		return .get
	}
	
	open override var encoding: ParameterEncoding {
		return httpBody ?? super.encoding
	}
}
