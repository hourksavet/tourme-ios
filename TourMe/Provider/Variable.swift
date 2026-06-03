//
//  Variable.swift
//  PassApp
//
//  Created by Savet on 11/5/19.
//  Copyright © 2019 PassApp Technologies Co., Ltd. All rights reserved.
//

import Foundation

final class Variable {
	
	static let shared: Variable = .init()
	
	var languageKey: String { // Khmer = km, English = en
		get {
			return UserDefaults.standard.object(forKey: "languageKey") as? String ?? "en"
		}
		
		set {
			UserDefaults.standard.set(newValue, forKey: "languageKey")
		}
	}
	
	// Camera permission requested
	var isRequestedCamera: Bool {
		get {
			return UserDefaults.standard.object(forKey: "isRequestedCamera") as? Bool ?? false
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "isRequestedCamera")
		}
	}
}
