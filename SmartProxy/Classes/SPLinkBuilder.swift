//
//  SPLinkBuilder.swift
//  SMART
//
//  Created by Лев Соколов on 17/07/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation

public struct SPLinkBuilderConfiguration {
	public var host: String = ""
	public var apiVersion: Int = 1
	public var debugEnabled: Bool = false
	
	public init(host: String = "",
	            apiVersion: Int = 1,
	            debugEnabled: Bool = false)
	{
		self.host = host
		self.apiVersion = apiVersion
		self.debugEnabled = debugEnabled
	}
}

open class SPLinkBuilder {
	
	public enum Scheme: String {
		case http = "http"
		case ws = "ws"
	}
	
	public static let shared = SPLinkBuilder()
	
	public var configuration = SPLinkBuilderConfiguration() {
		didSet {
			urlComponents.host = configuration.host
			urlComponents.port = configuration.debugEnabled ? 3000 : nil
		}
	}
	
	public var urlComponents: URLComponents
	
	private init() {
		urlComponents = URLComponents()
	}
	
	open func build(_ path: String,
	                scheme: Scheme? = Scheme.http,
	                queryItems: [URLQueryItem]? = nil,
	                api: Bool = true) -> URL?
	{
		let apiVersionPath = "/api/v" + "\(configuration.apiVersion)"
		let finalPath = api ? "\(apiVersionPath)/\(path)" : path
		
		urlComponents.scheme = scheme?.rawValue
		urlComponents.queryItems = queryItems
		
		var url = urlComponents.url
		
		if let componentsUrl = URL(string: finalPath) {
			for component in componentsUrl.pathComponents {
				if component != "/" {
					url = url?.appendingPathComponent(component)
				}
			}
		}
		
		return url
	}
}
