import UIKit
import CoreLocation

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


enum ApiError: Error{
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}

func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping(Result<ParsingType, Error>)-> ()){
    guard let url = URL(string: urlStr)
    else{
        //fatalError("URL 생성 실패")     //앱스토어 출시시, 포함시키면 안됨
        completion(.failure(ApiError.invalidUrl(urlStr)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error{
            //fatalError(error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else{
            //fatalError("invalid response")
            completion(.failure(ApiError.invalidResponse))
            return
        }
        
        guard httpResponse.statusCode == 200 else{
            //fatalError("failed code \(httpResponse.statusCode)")
            completion(.failure(ApiError.failed(httpResponse.statusCode)))
            return
        }
        
        guard let data = data else{
            //fatalError("empty data")
            completion(.failure(ApiError.emptyData))
            return
        }
        
        do{
            let decoder = JSONDecoder()
            let data = try decoder.decode(ParsingType.self, from: data)
        
            completion(.success(data))
        }catch{
            //print(error)
            //fatalError(error.localizedDescription)
            completion(.failure(error))
        }
        
    }
    task.resume()
    
}


//도시 이름으로 요청하는 코드
func fetchForecast(cityName: String, completion: @escaping(Result<Forecast, Error>)-> ()){
    
    let urlStr = "http://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}


//도시의 id로 호출하는 코드
func fetchForecast(cityId: Int, completion: @escaping(Result<Forecast, Error>)-> ()){
    
    let urlStr = "http://api.openweathermap.org/data/2.5/forecast?id=\(cityId)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

//도시의 좌표로 호출하는 코드
func fetchForecast(location: CLLocation, completion: @escaping(Result<Forecast, Error>)-> ()){
    
    let urlStr = "http://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}


//fetchForecast(cityName: "gwangju")

//fetchForecast(cityName: "gwangju") { _ in
//}
//
//fetchForecast(cityId: 1841808){ (result) in
//    switch result{
//    case .success(let weather):
//        dump(weather)
//    case .failure(let error):
//        print(error)
//    }
//
//}
