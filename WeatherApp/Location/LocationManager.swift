//
//  LocationManager.swift
//  WeatherApp
//
//  Created by 김모경 on 2021/07/31.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    private override init(){            //초기화
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers    //정확도 설정
        
        super.init()
        
        manager.delegate = self
    }
    
    let manager: CLLocationManager
    
    //외부에서 호출하는 메서드
    func updateLocation(){
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            //예전 버전 사용하던 방식
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
        
    }
    
    
}

extension LocationManager: CLLocationManagerDelegate{
    
    //사용 허가를 요청하는 메서드
    private func requestAuthorization(){
        //권한을 요청할때는 매니저가 제공하는 메서드로 호출되어야함   //=> 2가지 경우 나뉨
        manager.requestWhenInUseAuthorization()
    }
    
    //현재 위치를 요청하는 메서드
    private func requestCurrentLocation(){
        //=> 2가지 경우가 있음 (지속적/1회성)
        manager.requestLocation()
    }
    
    //delegate 메서드
    //허가 상태가 바뀌면 호출되는 메서드
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        
        case .authorizedAlways, .authorizedWhenInUse:   //사용자가 위치정보 사용할 수 있게 허용한 상태라면
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    //14.0버전 이전의 상태도 작동해야하니까 이전 버전의 delegate도 추가
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:   //사용자가 위치정보 사용할 수 있게 허용한 상태라면
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    //새로운 위치 정보가 호출되면, 반복적으로 호출됨
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last)
    }
    
    
    //에러가 발생하면 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
}
