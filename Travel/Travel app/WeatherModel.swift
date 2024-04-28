//
//  WeatherModel.swift
//  Weather app
//


import Foundation

struct WeatherResponse: Decodable {
    let weather: [Weather]
    let main: Main
}

struct Weather: Decodable {
    let icon: String
}

struct Main: Decodable {
    let temp: Double
}
