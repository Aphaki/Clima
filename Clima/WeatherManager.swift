//
//  WeatherManager.swift
//  Clima
//
//  Created by Sy Lee on 2023/03/22.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
//    let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(Constants.API_KEY)&units=metric"
//    let baseURL = "https://api.openweathermap.org/data/2.5/weather?lat=37.33&lon=126.58&appid=\(Constants.API_KEY)"
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(Constants.API_KEY)&units=metric"
        print("fetchWeather(lat:,lon:) Request URL: \(urlString)")
        
        performRequest(with: urlString)
        
        
    }
    
    func fetchWeather(city: String) {
        let urlString = "\(baseURL)?q=\(city)&appid=\(Constants.API_KEY)&units=metric"
        print("fetchWeather(city:) Request URL: \(urlString)")
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, urlResponse, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
                
            }
            task.resume()
        }
    } // performRequest()
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    } //parseJSON()
    
    
}

