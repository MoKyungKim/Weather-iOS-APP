//
//  WeatherDataSource.swift
//  WeatherApp
//
//  Created by 김모경 on 2021/07/30.
//

import Foundation
import CoreLocation

class WeatherDataSource {
    static let shared = WeatherDataSource()
    private init(){
        
        //LocationManager가 전달하는 notification observer를 추가
        
        //notification이 전달되면 api를 요청
        
        NotificationCenter.default.addObserver(forName: LocationManager.currentLocationDidUpdate, object: nil, queue: .main) {
            (noti) in
            
            if let location = noti.userInfo?["location"] as? CLLocation{
                self.fetch(location: location){
                    //fetch가 완료되면 ui를 업데이트해야함
                    
                    NotificationCenter.default.post(name: Self.weatherInfoDidUpdate, object: nil)
                }
            }
        }
    }
    
    static let weatherInfoDidUpdate = Notification.Name(rawValue: "weatherInfoDidUpdate")   //날씨 정보 업데이트 notification
    
    
    var summary: CurrentWeather?            //현재 날씨 저장
    var forecastList = [ForecastData]()     //예보 데이터 저장
    
    let apiQueue = DispatchQueue(label: "ApiQueue", attributes: .concurrent)    //api를 요청할 때 사용할 디스패치큐를 저장
                                                                                //concurrent 옵션을 추가해서 최대한 많은 작업을 처리
    let group = DispatchGroup() //2개의 api 요청을 하나의 논리적인 그룹으로 묶어줄때 사용함
    
    //외부에서 호출하는 메소드를 추가
    //좌표를 받는 버전만 추가
    func fetch(location: CLLocation, completion: @escaping () -> ()) {
        group.enter()
        apiQueue.async {
            self.fetchCurrentWeather(location: location){ (result) in
                switch result{
                case .success(let data):
                    self.summary = data
                default:
                    self.summary = nil
                }
                
                self.group.leave()
            }
        }
        
        group.enter()
        apiQueue.async {
            self.fetchForecast(location: location){ (result) in
                switch result{
                case .success(let data):
                    self.forecastList = data.list.map{
                        let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
                        let icon = $0.weather.first?.icon ?? ""
                        let weather = $0.weather.first?.description ?? "알 수 없음"
                        let temperature = $0.main.temp
                        
                        return ForecastData(date: dt, icon: icon, weather: weather, temperature: temperature)
                    }
                default:
                    self.forecastList = []
                }
                
                self.group.leave()
            }
        }
        
        group.notify(queue: .main){ //그룹에 포함된 모든 작업이 끝날때까지 대기 . 끝나는 시점은 모든 작업이 leave를 호출하는 시점임
            completion()
        }
    }
}
    
//
extension WeatherDataSource{
    
    private func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping(Result<ParsingType, Error>)-> ()){
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
    private func fetchCurrentWeather(cityName: String, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
        
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

    //도시의 id로 호출하는 코드
    private func fetchCurrentWeather(cityId: Int, completion: @escaping(Result<CurrentWeather, Error>)-> ()) {
        
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

    //도시의 좌표로 호출하는 코드
    private func fetchCurrentWeather(location: CLLocation, completion: @escaping(Result<CurrentWeather, Error>)-> ()){
        
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

}


extension WeatherDataSource {
    
    //도시 이름으로 요청하는 코드
    private func fetchForecast(cityName: String, completion: @escaping(Result<Forecast, Error>)-> ()){
        
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

    //도시의 id로 호출하는 코드
    private func fetchForecast(cityId: Int, completion: @escaping(Result<Forecast, Error>)-> ()) {
        
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?id=\(cityId)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

    //도시의 좌표로 호출하는 코드
    private func fetchForecast(location: CLLocation, completion: @escaping(Result<Forecast, Error>)-> ()){
        
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
    
}
    

