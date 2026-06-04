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
		   let mbtilesPath = Bundle.main.path(forResource: "cambodia", ofType: "mbtiles") {
			// 1️⃣ Read the base style
			var styleText = try! String(contentsOfFile: stylePath)

			// 2️⃣ Inject the actual mbtiles path
			styleText = styleText.replacingOccurrences(of: "{mbtiles_path}", with: mbtilesPath)

			// 3️⃣ Create a guaranteed existing temp directory
			let tempDir = FileManager.default.temporaryDirectory
			let tempStyleURL = tempDir.appendingPathComponent("style-runtime\(String(describing: style != nil ? style : "")).json")

			// 4️⃣ Write the file safely
			try! styleText.write(to: tempStyleURL, atomically: true, encoding: .utf8)
			super.init(frame: .zero, styleURL: tempStyleURL)
			return
		}
		super.init(frame: .zero, styleURL: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		attributionButton.frame = logoView.frame
		bringSubviewToFront(attributionButton)
		attributionButton.tintColor = .clear
	}
}
