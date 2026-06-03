//
//  TileServer.swift
//  TourMe
//
//  Created by Savet on 27/8/25.
//

//import Swifter
//import FMDB
/*
class TileServer {
	static let shared = TileServer()
	let server = HttpServer()
	var database: FMDatabase?

	func start() {
		guard let mbtilesPath = Bundle.main.path(forResource: "cambodia", ofType: "mbtiles") else {
			print("MBTiles not found")
			return
		}

		database = FMDatabase(path: mbtilesPath)
		database?.open()

		server["/tiles/:z/:x/:y.pbf"] = { request in
			guard
				let zStr = request.params[":z"], let z = Int(zStr),
				let xStr = request.params[":x"], let x = Int(xStr),
				let yStr = request.params[":y"], let y = Int(yStr)
			else {
				return .notFound
			}

			let flippedY = (1 << z) - 1 - y // TMS → XYZ flip
			let sql = "SELECT tile_data FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?"

			if let rs = self.database?.executeQuery(sql, withArgumentsIn: [z, x, flippedY]),
			   rs.next(),
			   let data = rs.data(forColumn: "tile_data") {
				return HttpResponse.raw(200, "OK", ["Content-Type": "application/x-protobuf"]) { writer in
					try writer.write(data)
				}
			}

			return .notFound
		}

		try? server.start(8080, forceIPv4: true)
		print("Swifter running on http://127.0.0.1:8080/")
	}

	func stop() {
		server.stop()
		database?.close()
	}
}
*/
