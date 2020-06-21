
import Foundation

//Responsible for setting the Api response into this weather Model to communicate with the Controller
class WeatherModel {
    
    var conditionid : Int = 0
    var cityname : String = ""
    var temperature : Double = 0.0
    var description : String = ""
    var date : String = ""
    var forecast : [List] = []
    var temp_min : Double = 0.0
    var temp_max : Double = 0.0
        
 // Computed property
    var temperaturestring : String {
        return String (format: "%.1f", temperature)
    }

    var min_temperaturestring : String {
            return String (format: "%.2f", temp_min)
        }
    
    var max_temperaturestring : String {
        return String (format: "%.2f", temp_max)
    }

    
 // Computed Property
    var conditionName : String {
        
        if conditionid>=200 && conditionid<=232
        {
            return "cloud.bolt"
        }
        if conditionid>=300 && conditionid<=321
        {
            return "cloud.drizzle"
        }
        if conditionid>=500 && conditionid<=531
        {
            return "cloud.rain"
        }
        if conditionid>=600 && conditionid<=622
        {
            return "cloud.snow"
        }
        if conditionid>=701 && conditionid<=781
        {
            return "cloud.fog"
        }
        if conditionid==800
        {
            return "sun.max"
        }
        if conditionid>=801 && conditionid<=804
        {
            return "cloud.bolt"
        }
        else {
            return "cloud"
        }
    }
    
    init(conditionid: Int , cityname: String, temperature: Double, description: String, date: String, forecast: [List], temp_min: Double , temp_max: Double)
    {
        self.conditionid = conditionid
        self.cityname = cityname
        self.temperature = temperature
        self.description = description
        self.date = date
        self.forecast = forecast
        self.temp_min = temp_min
        self.temp_max = temp_max
    }
}
