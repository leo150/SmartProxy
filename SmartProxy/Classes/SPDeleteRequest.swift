//
//  SPDeleteRequest.swift
//  SMART
//
//  Created by Lev Sokolov on 2/15/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SPDeleteRequest<TResponse: SPResponse>: SPPostRequest<TResponse> {
	
	public override init() {
		super.init()
	}
	
	public override init(withAccessToken accessToken : String) {
		super.init(withAccessToken: accessToken)
	}
	
	internal override func setupUrlRequest(_ urlRequest : NSMutableURLRequest) {
		
		super.setupUrlRequest(urlRequest)
		urlRequest.httpMethod = "DELETE"
	}
}