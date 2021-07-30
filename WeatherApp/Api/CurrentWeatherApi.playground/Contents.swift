import UIKit
import CoreLocation


struct CurrentWeather: Codable{       //--> Codable로 수정?
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
        //클로저에서 응답을 처리하는 코드는 기본적인 패턴이 있음
        //클로저로 전달되는 여러 파라미터 중 먼저 에러 파라미터를 확인
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
        
        //json 파라미터는 첫번재 파라미터에 저장되어있는데, 여기서는 data
        //data가 optional이니까 일단 optional binding을 이용해서 언래핑
        guard let data = data else{
            //fatalError("empty data")
            completion(.failure(ApiError.emptyData))
            return
        }
        
        //json 디코더를 만든 다음, 서버에서 전달되는 데이터를 파싱
        do{
            let decoder = JSONDecoder()
            let data = try decoder.decode(ParsingType.self, from: data)
        
            completion(.success(data))
            
            //값을 확인하는 코드
            //weather.weather.first?.description
            //weather.main.temp
        }catch{
            //print(error)
            //fatalError(error.localizedDescription)
            completion(.failure(error))
        }
        
        
    }
    task.resume()       //task를 만든 후, 반드시 resume을 호출해야함
    
}


//도시 이름으로 요청하는 코드
func fetchCurrentWeather(cityName: String, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
    
    let urlStr = "http://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}


//도시의 id로 호출하는 코드
func fetchCurrentWeather(cityId: Int, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
    
    let urlStr = "http://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

//도시의 좌표로 호출하는 코드
func fetchCurrentWeather(location: CLLocation, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
    
    let urlStr = "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=c743b6f0525323b2e938723c9ca76ef0&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}


//fetchCurrentWeather(cityName: "gwangju")

//fetchCurrentWeather(cityName: "gwangju") { _ in
//}
//
//fetchCurrentWeather(cityId: 1841808){ (result) in
//    switch result{
//    case .success(let weather):
//        dump(weather)
//    case .failure(let error):
//        print(error)
//    }
//
//}

let location = CLLocation(latitude: 36.348315, longitude: 127.390594)
fetchCurrentWeather(location: location){(result) in
        switch result{
        case .success(let weather):
            dump(weather)
        case .failure(let error):
            print(error)
        }
    
}
