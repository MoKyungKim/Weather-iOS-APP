//
//  Forecast.swift
//  WeatherApp
//
//  Created by 김모경 on 2021/07/30.
//

import Foundation

struct Forecast: Codable{
    
    let cod: String
    let message: Int
    let cnt: Int
    
    struct ListItem: Codable{
        let dt: Int
        
        struct Main: Codable{
            let temp: Double
        }
        let main: Main
        
        struct Weather: Codable{
            let description: String
            let icon: String
        }
        let weather: [Weather]
        
    }
    let list: [ListItem]
}


//데이터를 저장할 구조체
struct ForecastData {
    let date: Date
    let icon: String
    let weather: String
    let temperature: Double
}
