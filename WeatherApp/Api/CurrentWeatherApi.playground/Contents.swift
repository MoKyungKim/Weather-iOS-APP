import UIKit
import CoreLocation

struct CurrentWeather: Codable{
    //키의 이름, 타입이 동일해야함
    
    let dt: Int
    
    struct Weather: Codable{
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    let weather: [Weather]
    
    struct Main: Codable{    //필요한 키만 추가하면 됨 (모든 키를 추가할 필요 X)
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
    
    let main: Main
    
}

///
enum ApiError: Error{
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}

func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping(Result<ParsingType, Error>)-> ()){
    guard let url = URL(string: urlStr) else {
        //fatalError("URL 생성 실패")
        completion(.failure(ApiError.invalidUrl(urlStr)))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error{
            //fatalError(error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
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
            
            completion(.success(data))  //성공 => 파싱된 데이터를 전달
            
            //weather.weather.first?.description
            //weather.main.temp
        }
        catch{
            //print(error)
            //fatalError(error.localizedDescription)
            completion(.failure(error))
        }
    }
    task.resume()
}

//도시 이름으로 요청하는 코드
func fetchCurrentWeather(cityName: String, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
    
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

//도시의 id로 호출하는 코드
func fetchCurrentWeather(cityId: Int, completion: @escaping(Result<CurrentWeather, Error>)-> ()) {
    
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

//도시의 좌표로 호출하는 코드
func fetchCurrentWeather(location: CLLocation, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
    
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}



// <출력 확인>
//fetchCurrentWeather(cityName: "seoul") { _ in }
//
//fetchCurrentWeather(cityId: 1835847) { (result) in
//    switch result{
//    case .success(let weather):
//        dump(weather)
//    case .failure(let error):
//        print(error)
//    }
//}
//
let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
fetchCurrentWeather(location: location){(result) in
        switch result{
        case .success(let weather):
            dump(weather)
        case .failure(let error):
            print(error)
        }

}

