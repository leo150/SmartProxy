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
	
	open var pathComponents: [String] {
		return []
	}
	
	open var queryItems: [URLQueryItem]? {
		return nil
	}
	
	open var absoluteUrl: URL? {
		return SPLinkBuilder.shared.build(pathComponents, queryItems: queryItems)
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
	
	open var retryAttempts: Int {
		return SPConfiguration.shared.retryAttempts
	}
	
	open var retryErrorCodes: [CountableClosedRange<Int>] {
		return SPConfiguration.shared.retryErrorCodes
	}
	
	open var notRetryErrorCodes: [Int] {
		return SPConfiguration.shared.notRetryErrorCodes
	}
	
	open func send(_ onSuccess: @escaping ((TResponse) -> Void),
	               onError: @escaping ((SPError) -> Void),
	               onAnyway: @escaping (() -> Void) = {  }) -> SPRequestInfo?
	{
		guard let absoluteUrl = absoluteUrl else {
			onError(.connectionError)
			onAnyway()
			return nil
		}
		
		print("url: \(absoluteUrl)")
		
		return send(attempt: 0, onSuccess: onSuccess, onError: onError, onAnyway: onAnyway)
	}
	
	@discardableResult
	private func send(attempt: Int,
	                  onSuccess: @escaping ((TResponse) -> Void),
	                  onError: @escaping ((SPError) -> Void),
	                  onAnyway: @escaping (() -> Void) = {  },
	                  requestInfo: SPRequestInfo? = nil) -> SPRequestInfo?
	{
		guard let absoluteUrl = absoluteUrl else {
			onError(.connectionError)
			onAnyway()
			return nil
		}
		
		let request = sessionManager.request(absoluteUrl,
		                                     method: method,
		                                     encoding: encoding,
		                                     headers: headers)
			.responseString { response in
				
				if SPConfiguration.shared.printResponse {
					if let statusCode = response.response?.statusCode {
						print("code: \(statusCode)")
					}
					
					print("response:")
					if let value = response.result.value {
						print(value)
					}
					else {
						print("empty")
					}
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
			}
			.responseJSON { response in
				let sSelf = self
				
				if
					let urlError = response.result.error as? URLError,
					urlError.errorCode == URLError.Code.cancelled.rawValue
				{
					onAnyway(); return
				}
				
				let responseParser = TResponse()
				
				func onParseSuccess (_ response: SPResponse) {
					onSuccess(response as! TResponse)
				}
				
				func onParseError(_ error: SPError) {
					if let statusCode = response.response?.statusCode {
						if attempt >= sSelf.retryAttempts {
							onError(error)
						}
						else if sSelf.notRetryErrorCodes.contains(statusCode) {
							onError(error)
						}
						else {
							for range in sSelf.retryErrorCodes {
								if range.contains(statusCode) {
									sSelf.send(attempt: attempt + 1, onSuccess: onSuccess,
										onError: onError, onAnyway: onAnyway, requestInfo: requestInfo)
									return
								}
							}
							
							onError(error)
						}
					}
					else {
						onError(error)
					}
				}
				
				responseParser.parse(response, onSuccess: onParseSuccess, onError: onParseError)
				
				onAnyway()
		}
		
		if let requestInfo = requestInfo {
			requestInfo.updateRequest(request)
		}
		else {
			return SPRequestInfo(with: request)
		}
		
		return nil
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
