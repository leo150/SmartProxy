//
//  SPGetRequest.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/15/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

open class SPGetRequest<TResponse: SPResponse>: SPRequest<TResponse> {
	
	public override init() {
		super.init()
	}
	
	public override init(withAccessToken accessToken: String) {
		super.init(withAccessToken: accessToken)
	}
	
	internal var httpBody: JSON? {
		get {
			return nil
		}
	}
	
	internal override func setupUrlRequest(_ urlRequest: NSMutableURLRequest) {
		
		super.setupUrlRequest(urlRequest)
		
		if let unpackedHttpBody = self.httpBody {
			do {
				urlRequest.httpBody = try unpackedHttpBody.rawData()
			}
			catch {
				print("Could not read http body")
			}
		}
		
		urlRequest.httpMethod = "GET"
	}
}
