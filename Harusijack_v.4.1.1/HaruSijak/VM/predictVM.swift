//
//  predictVM.swift
//  HaruSijak
//
//  Created by ji-hwan park on 6/24/24.
//

import Foundation


struct predictVM{
    
    
    
    // Flask 통신을 위한 함수(하차인원)
    func loadData(url : URL) async throws -> [PredictResultJSON]{
        let (data, _ ) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PredictResultJSON].self, from: data)
    }
    

    func loadAlightData(stationName: String, date: String, time: String, stationLine: String, completion: @escaping 
        ([PredictResultJSON]) -> Void) {
        let url = URL(string: "http://127.0.0.1:5000/subway")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "stationName": stationName,
            "date": date,
            "time": time,
            "stationLine": stationLine
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                return
            }
            do {
                let result = try JSONDecoder().decode([PredictResultJSON].self, from: data)
                completion(result)
                } catch {
                    print("Decoding error:", error)
                    completion([])
                }
        }
        task.resume()
    }
}
