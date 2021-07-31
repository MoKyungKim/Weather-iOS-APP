//
//  Double+Fomatter.swift
//  WeatherApp
//
//  Created by 김모경 on 2021/07/30.
//

import Foundation

//공용 포매터
fileprivate let temperatureFomatter: MeasurementFormatter = {
   let f = MeasurementFormatter()
    f.locale = Locale(identifier: "ko_kr")
    f.numberFormatter.maximumFractionDigits = 1     //소수점이 0이면 출력하지 않고, 나머지의 경우는 한 자리만 출력
    f.unitOptions = .temperatureWithoutUnit         //기온 문자열은 뒤나 c, f 추가 되지 않도록 함
    
    return f
}()

extension Double{
    //여기서 Double을 기온 문자열로 바꾸는 속성을 추가
    var temperatureString: String{
        let temp = Measurement<UnitTemperature>(value: self, unit: .celsius)
        return temperatureFomatter.string(from: temp)
    }
}
