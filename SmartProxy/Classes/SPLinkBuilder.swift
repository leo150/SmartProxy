//
//  SPLinkBuilder.swift
//  SMART
//
//  Created by Лев Соколов on 17/07/16.
//  Copyright © 2016 Mariposa Entertainment Inc. All rights reserved.
//

import Foundation

open class SPLinkBuilder {
	
	public enum Scheme: String {
		case http = "http"
		case ws = "ws"
	}
	
	public enum ServerType: String {
		case development = "Development"
		
		public var address: String {
			switch self {
			case .development:
				return "plan.rdev.ifrog.ru"
			}
		}
		
		init(_ value: String) {
			self = ServerType(rawValue: value) ?? .development
		}
	}
	
	open static let sharedInstance = SPLinkBuilder()
	
	public let serverType: ServerType = .development
	public let apiVersion: Int = 1
	public let isDebugEnabled: Bool = false
	public var urlComponents: URLComponents
	
	private init() {
		urlComponents = URLComponents()
		
		urlComponents.scheme = Scheme.http.rawValue
		urlComponents.host = ServerType.development.address
		urlComponents.port = isDebugEnabled ? 3000 : nil
	}
	
	open func build(_ path: String, queryItems: [URLQueryItem]? = nil, api: Bool = true) -> URL? {
		let apiVersionPath = "/api/v" + "\(apiVersion)"
		let finalPath = api ? "\(apiVersionPath)/\(path)" : path
		
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
