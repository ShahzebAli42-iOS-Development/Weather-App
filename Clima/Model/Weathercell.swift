

import Foundation
import UIKit

//Responsible to generate cells of the table view
class Weathercell : UITableViewCell {
    @IBOutlet weak var weatherimage: UIImageView!
    @IBOutlet weak var Daylabel: UILabel!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var maxtemp: UILabel!
    @IBOutlet weak var mintemp: UILabel!
    
    func configurecell(weather : WeatherModel )
    {
        weatherimage.image = UIImage(systemName: weather.conditionName)
        descriptionlabel.text =  weather.description
        
        let x = String(weather.date.suffix(8))
        let y = String(x.prefix(2))
        let weather_time = y
        let date = String(weather.date.prefix(10))
        let day_num = getDayOfWeek(date)!
        if Int(weather_time)! >= 12 {
              Daylabel.text = get_Name_of_Day(day_number: day_num) + ":" + weather_time + "pm"
        }
        else {
              Daylabel.text = get_Name_of_Day(day_number: day_num) + ":" + weather_time + "am"
        }
        mintemp.text = weather.min_temperaturestring
        maxtemp.text = weather.max_temperaturestring
    }
    //Return Number of Week Day
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    //Returns Name of Day
    func get_Name_of_Day(day_number: Int )->String {
        
        if day_number == 2 {
            return "Monday"
        }
        
        if day_number == 3 {
            return "Tuesday"
        }
        
        if day_number == 4 {
            return "Wednesday"
        }
        
        if day_number == 5 {
            return "Thursday"
        }
        
        if day_number == 6 {
            return "Friday"
        }
        
        if day_number == 7 {
            return "Saturday"
        }
        else {
            return "Sunday"
        }
    }
}
