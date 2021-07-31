//
//  ApiError.swift
//  WeatherApp
//
//  Created by 김모경 on 2021/07/30.
//

import Foundation

enum ApiError: Error{
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}


