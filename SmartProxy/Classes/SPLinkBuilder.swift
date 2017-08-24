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
	
	public var port: Int? = nil
	
	public init(host: String = "",
	            port: Int? = nil,
	            apiVersion: Int = 1)
	{
		self.host = host
		self.apiVersion = apiVersion
		self.port = port
	}
}

open class SPLinkBuilder {
	
	public enum Scheme: String {
		case http = "http"
		case https = "https"
		case ws = "ws"
	}
	
	public static let shared = SPLinkBuilder()
	
	public var configuration = SPLinkBuilderConfiguration() {
		didSet {
			urlComponents.host = configuration.host
			urlComponents.port = configuration.port
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
	
	/// Builds a URL with provided components.
	///
	/// - Parameters:
	///   - pathComponents: Path components for a URL
	///   - host: Host for a URL. If nil than host will be taken from `configuration`.
	///   - port: Port for a URL. If nil than port will be taken from `configuration`.
	///   - scheme: Scheme for a URL. Default is http.
	///   - queryItems: Array of query items for this URL, in the order in which they 
	///     appear in the original query string.
	open func build(_ pathComponents: [String],
	                host: String? = nil,
	                port: Int? = nil,
	                scheme: Scheme? = Scheme.http,
	                queryItems: [URLQueryItem]? = nil) -> URL?
	{
		urlComponents.host = host ?? configuration.host
		urlComponents.port = port ?? configuration.port
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
