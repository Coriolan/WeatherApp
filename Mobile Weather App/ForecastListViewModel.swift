//
//  ForecastListViewModel.swift
//  Mobile Weather App
//
//  Created by Coriolan on 2024-06-26.
//

import CoreLocation
import Foundation
import SwiftUI

let API_KEY = "<INSERT API KEY HERE>"
let LATITUDE = "45.30881786617996"
let LONGITUDE = "-75.89849299121659"

let API_URL_CURRENT_WEATHER = "https://api.openweathermap.org/data/2.5/weather?lat=\(LATITUDE)&lon=\(LONGITUDE)&appid=\(API_KEY)"
let API_URL_FORECAST = "https://api.openweathermap.org/data/2.5/forecast?lat=\(LATITUDE)&lon=\(LONGITUDE)&appid=\(API_KEY)"
let API_URL_COORDINATES_BY_LOCATION = "http://api.openweathermap.org/geo/1.0/direct?q=Kanata&appid=\(API_KEY)"
let API_URL_WEATHER_BY_CITY = "hhttps://api.openweathermap.org/data/2.5/weather?q=Kanata&appid=\(API_KEY)"

class ForecastListViewModel: ObservableObject {
    
    struct AppError: Identifiable {
        var id = UUID().uuidString
        let errorString: String
    }
    
    @Published var forecasts: [ForecastViewModel] = []
    var appError: AppError? = nil
    @Published var isLoading: Bool = false
    @AppStorage("location") var storageLocation: String = ""
    @Published var location: String = ""
    @AppStorage("system") var system: Int = 0 {
        didSet {
            for i in 0..<forecasts.count {
                forecasts[i].system = system
            }
        }
    }
    
    init() {
        location = storageLocation
        getWeatherForecast()
    }
    func getAPIUrl(latitude: Double, longitude: Double) -> String {
        return "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(API_KEY)"
    }
    
    func getWeatherForecast() {
        print("\(#function) \(location)")
        storageLocation = location
        UIApplication.shared.endEditing()
        if location.isEmpty {
            forecasts = []
        }
        else {
            isLoading = true
            let apiService = APIServiceCombine.shared//APIService.shared
            CLGeocoder().geocodeAddressString(location) { [self] placemarks, error in
                if let error = error as? CLError {
                    switch error.code {
                    case .locationUnknown, .geocodeFoundNoResult, .geocodeFoundPartialResult:
                        self.appError = AppError(errorString: "Unable to determine location from this text.")
                        print(">>>ERROR: \(appError?.errorString ?? "generic error")")
                    case .network:
                        self.appError = AppError(errorString: "You do now appear to have a connection.")
                        print(">>>ERROR: \(appError?.errorString ?? "generic error")")
                    default:
                        print(">>>ERROR: \(error.localizedDescription)")
                        self.appError = AppError(errorString: error.localizedDescription)
                    }
                    isLoading = false
                }
                
                if let lat = placemarks?.first?.location?.coordinate.latitude,
                   let lon = placemarks?.first?.location?.coordinate.longitude {
                    apiService.getJSON(urlString: getAPIUrl(latitude: lat, longitude: lon), dateDecodingStrategy: .secondsSince1970) { (result: Result<Forecast, APIServiceCombine.APIError>/*APIService.APIError>*/) in
                        switch result {
                        case .success(let forecast):
                            DispatchQueue.main.async {
                                self.isLoading = false
                                self.forecasts = forecast.list.map({ list in
                                    ForecastViewModel(forecast: list, system: self.system)
                                })
                            }
                        case .failure(let apiError):
                            switch apiError {
                            case .error(let errorString):
                                print(errorString)
                                self.isLoading = false
                                self.appError = AppError(errorString: errorString)
                            }
                        }
                    }
                }
                
            }
        }
    }
}
