//
//  ToureMeMapView.swift
//  TourMe
//
//  Created by Savet on 11/9/25.
//

import MapLibre


class ToureMeMapView: MLNMapView {
	
	init(style: String? = nil) {
		if let stylePath = Bundle.main.path(forResource: style != nil ? style! :"map-style-default", ofType: "json"),
		   let styleText = try? String(contentsOfFile: stylePath),
		   let tempStyleURL = Self.makeRuntimeStyleURL(styleText: styleText, cacheKey: style ?? "map-style-default") {
			super.init(frame: .zero, styleURL: tempStyleURL)
			return
		}
		super.init(frame: .zero, styleURL: nil)
	}

	func applyStyleJSON(_ styleText: String, cacheKey: String = UUID().uuidString) {
		guard let tempStyleURL = Self.makeRuntimeStyleURL(styleText: styleText, cacheKey: cacheKey) else {
			return
		}
		styleURL = tempStyleURL
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static func makeRuntimeStyleURL(styleText: String, cacheKey: String) -> URL? {
		guard let mbtilesPath = Bundle.main.path(forResource: "cambodia", ofType: "mbtiles") else {
			return nil
		}
		let resolvedStyleText = styleText.replacingOccurrences(of: "{mbtiles_path}", with: mbtilesPath)
		let tempDir = FileManager.default.temporaryDirectory
		let safeKey = cacheKey.replacingOccurrences(of: "/", with: "-")
		let tempStyleURL = tempDir.appendingPathComponent("style-runtime-\(safeKey).json")
		do {
			try resolvedStyleText.write(to: tempStyleURL, atomically: true, encoding: .utf8)
			return tempStyleURL
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		attributionButton.frame = logoView.frame
		bringSubviewToFront(attributionButton)
		attributionButton.tintColor = .clear
	}
}
