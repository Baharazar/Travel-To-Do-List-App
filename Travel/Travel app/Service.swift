//
//  Service.swift
//  Weather app
//

//

import Foundation

class Service {
    static var shared = Service()
    
    private init() {}
    
    enum error: Error {
        case badURL
    }
    
    func getData(url: String, query: [String:String]?, completion: @escaping (Result<Data, Error>) -> Void ) {
        var urlComponent = URLComponents(string: url)
        if let query = query {
            urlComponent?.queryItems = query.map({ URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        guard let url = urlComponent?.url else {
            completion(.failure(error.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    
    func fetchWeather(city: String, completion: @escaping (String, Double) -> Void) {
        let apiKey = "ca7c98191039809c1693b5b6c32eaf95"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data),
               let icon = weatherResponse.weather.first?.icon {
                let iconUrl = "https://openweathermap.org/img/wn/\(icon)@2x.png"
                DispatchQueue.main.async {
                    completion(iconUrl, weatherResponse.main.temp)
                }
            }
        }.resume()
    }
}
