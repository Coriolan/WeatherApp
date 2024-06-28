//
//  Forecast.swift
//  Mobile Weather App
//
//  Created by Coriolan on 2024-06-25.
//

import Foundation

struct Forecast: Codable {
    
    struct List: Codable {
        let dt: Date
        struct Main: Codable {
            let temp_min: Double
            let temp_max: Double
            let humidity: Int
        }
        let main: Main
        struct Weather: Codable {
            let id: Int
            let description: String
            let icon: String
        }
        let weather: [Weather]
        struct Clouds: Codable {
            let all: Int
        }
        let clouds: Clouds
        let pop: Double
    }
    
    let list: [List]
}
