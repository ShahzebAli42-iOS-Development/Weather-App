

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didupdateweather(weather: WeatherModel)
    func errorpoppedup(error: Error)
}

struct WeatherManager {
    let weatherForecastUrl = "https://api.openweathermap.org/data/2.5/forecast?appid=75a7e2b3dda1986acf06879ce354861b&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchForecastdata(city:String)
    {
        let urlString = "\(weatherForecastUrl)&q=\(city)"
        request(urlstring: urlString)
    }
    
    func fetchForecastWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
           let urlString = "\(weatherForecastUrl)&lat=\(latitude)&lon=\(longitude)"
        request(urlstring: urlString)
       }
    
    //creating an URL Session
    func request(urlstring: String)
    {
        //1. Create a URL
        if let url = URL(string: urlstring) {
            //2. Create  a URL Session
            let session = URLSession(configuration: .default)
            //3. Give Url session a task
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            //4. Start the task
            task.resume()
        }
    }
    
    //Handle api response data
    func handle(data: Data?, response: URLResponse?, error: Error?)
    {
        if error != nil{
            //print(error!)
            self.delegate?.errorpoppedup(error: error!)
            return
        }
        else {
            if let safedata = data {
                // PARSING API RESPONSE
                if let weather = parseJSON(weatherdata: safedata) {
                    self.delegate?.didupdateweather(weather: weather)
                    
                }
            }
        }
    }
    
    //parsing JSON response from api
    func parseJSON (weatherdata: Data ) -> WeatherModel?
    {
        //Javascript Object Notation JSON
        let decode = JSONDecoder()
        do {
            
            let decoded_data = try decode.decode(BreakdownJsonStructure.self, from: weatherdata)
    
            var totallist = [decoded_data.list[0]]
            for items in 1..<40{
                totallist.append(decoded_data.list[items])
            }
            
            let city_temperature = totallist[0].main.temp
            let description_weather = totallist[0].weather[0].description
            let weather_id = totallist[0].weather[0].id
            let name = decoded_data.city.name
            let time_date = totallist[0].dt_txt
  
            let weather = WeatherModel(conditionid: weather_id, cityname: name, temperature: city_temperature, description: description_weather, date: time_date, forecast: totallist, temp_min: 0.0, temp_max: 0.0)
            
            return weather
            }
            
         catch {
            self.delegate?.errorpoppedup(error: error)
            return nil
        }
    }
}


