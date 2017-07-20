//
//  SPRequest.swift
//  SMART
//
//  Created by Vadim Vnukov on 2/12/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation
import Alamofire

open class SPRequest <TResponse: SPResponse> {
	
	internal fileprivate(set) var accessToken: String?
	
	//MARK: External
	open var sessionManager = Alamofire.SessionManager.default
	
	public init() { }
	
	public init (withAccessToken accessToken: String) {
		self.accessToken = accessToken
	}
	
	@available(*, deprecated, message: "Use pathComponents instead")
	open var path: String {
		return ""
	}
	
	open var pathComponents: [String] {
		return []
	}
	
	open var queryItems: [URLQueryItem]? {
		return nil
	}
	
	public var absoluteUrl: URL? {
		get {
			return SPLinkBuilder.shared.build(path, queryItems: queryItems, api: true)
		}
	}
	
	open var headers: HTTPHeaders? {
		return [
		"Content-Type": "application/json",
		"X-API-KEY": accessToken ?? ""
		]
	}
	
	open var parameters: Parameters? {
		return nil
	}
	
	open var encoding: ParameterEncoding {
		return URLEncoding.default
	}
	
	open var method: HTTPMethod {
		return .options
	}
	
	open func send(_ onSuccess: @escaping ((TResponse) -> Void),
	               onError: @escaping ((SPError) -> Void),
	               onAnyway: @escaping (() -> Void) = { _ in }) -> SPRequestInfo?
	{
		guard let absoluteUrl = absoluteUrl else {
			onError(.connectionError)
			onAnyway()
			return nil
		}
		
		print("url: \(absoluteUrl)")
		
		let request = sessionManager.request(absoluteUrl,
		                                     method: method,
		                                     encoding: encoding,
		                                     headers: headers)
			.responseString { response in
				print("response:")
				if let value = response.result.value {
//					print(value)
				}
				else {
					print("empty")
				}
				
				//Simulator only
				#if (arch(i386) || arch(x86_64)) && os(iOS)
					if let statusCode = response.response?.statusCode {
						if [400, 404, 500].contains(statusCode) {
							if let resultValue = response.result.value {
								self.saveResponse(text: resultValue)
							}
						}
					}
				#endif
			} .responseJSON { response in
				if let urlError = response.result.error as? URLError {
					if urlError.errorCode == URLError.Code.cancelled.rawValue {
						onAnyway()
						return
					}
				}
				
				let responseParser = TResponse()
				
				func onParseSuccess (_ response : SPResponse) {
					onSuccess(response as! TResponse)
				}
				
				responseParser.parse(response, onSuccess : onParseSuccess, onError : onError)
				
				onAnyway()
		}
		return SPRequestInfo(with: request)
	}
	
	fileprivate func saveResponse(text: String) {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.dateFormat = "dd-MMM-yyy_hh-mm-ss"
		let fileName = "\(dateFormatter.string(from: Date())).html"
		
		let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
		guard let logsPath = documentsPath.appendingPathComponent("logs") else { return }
		do {
			try FileManager.default.createDirectory(at: logsPath, withIntermediateDirectories: true, attributes: nil)
			
			let filePath = logsPath.appendingPathComponent(fileName)
			try text.write(to: filePath, atomically: false, encoding: .utf8)
			print("Save respose to \(filePath.absoluteString)")
		} catch let error as NSError {
			NSLog("Unable to save respose \(error.debugDescription)")
		}
	}
}
