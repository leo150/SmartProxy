//
//  SPConfiguration.swift
//  Pods
//
//  Created by Lev Sokolov on 8/24/17.
//
//

import Foundation

public class SPConfiguration {
	static let shared = SPConfiguration()
	
	private init() {}
	
	public var retryAttempts: Int = 0
	
	public var retryErrorCodes: [CountableClosedRange<Int>] = []
	
	public var notRetryErrorCodes: [Int] = []
	
	public var printResponse: Bool = false
}
