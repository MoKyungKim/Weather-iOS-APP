//
//  Date+Formatter.swift
//  WeatherApp
//
//  Created by 김모경 on 2021/07/30.
//

import Foundation

fileprivate let dateFormatter: DateFormatter = {
   let f = DateFormatter()
    f.locale = Locale(identifier: "ko_kr")
    return f
}()

extension Date {
    //날짜 문자열을 리턴하는 속성
    var dateString: String{
        dateFormatter.dateFormat = "M월 d일"
        return dateFormatter.string(from: self)
    }
    
    //시간을 리턴하는 속성
    var timeStirng: String{
        dateFormatter.dateFormat = "HH:00"
        return dateFormatter.string(from: self)
    }
}
