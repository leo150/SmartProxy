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
	
	public var debugPort: Int? = nil
	
	public init(host: String = "",
	            apiVersion: Int = 1,
	            debugPort: Int? = nil)
	{
		self.host = host
		self.apiVersion = apiVersion
		self.debugPort = debugPort
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
			urlComponents.port = configuration.debugPort
		}
	}
	
	public var urlComponents: URLComponents
	
	private init() {
		urlComponents = URLComponents()
	}
	
	@available(*, deprecated)
	open func build(_ path: String,
	                scheme: Scheme? = Scheme.http,
	                queryItems: [URLQueryItem]? = nil,
	                api: Bool = true) -> URL?
	{
		return self.build(path.components(separatedBy: "/"),
		                  scheme: scheme,
		                  queryItems: queryItems)
	}
	
	open func build(_ pathComponents: [String],
	                scheme: Scheme? = Scheme.http,
	                queryItems: [URLQueryItem]? = nil) -> URL?
	{
		urlComponents.scheme = scheme?.rawValue
		urlComponents.queryItems = queryItems
		
		var url = urlComponents.url
		
		for component in pathComponents {
			if component.characters.count == 0 || component == "/" { continue }
			
			if component == "v" {
				let version = "\(configuration.apiVersion)"
				url = url?.appendingPathComponent(component + version)
			}
			else {
				url = url?.appendingPathComponent(component)
			}
		}
		
		return url
	}
	
	//MARK: Support
	
	public var socketCableUrl: URL {
		urlComponents.scheme = Scheme.ws.rawValue
		urlComponents.queryItems = nil
		return urlComponents.url!.appendingPathComponent("cable")
	}
}
