import UIKit
import CoreLocation
import CoreData

class WeatherViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var SearchTextField: UITextField!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var array_forecasting = [Forecasting]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let request : NSFetchRequest<Forecasting> = Forecasting.fetchRequest()
    
   var timer: Timer?
   var forecast = [List]()
    
        var weathermanager = WeatherManager()
        let locationManager = CLLocationManager()

        override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
            
        //Uncomment the Following Line to check Path of the saved Coredata SQL lite DataBase
        //print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
            
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
            
        //Uncomment following line to automatically fetch data for current location everytime when we open app
        //locationManager.requestLocation()
            
        weathermanager.delegate = self
        SearchTextField.delegate = self
        
        //loading data
        load_data_from_database()
            
            
            //handling exception and responsible for displaying current weather details in both cases
            //1) If App is opening for the first time therefore no data is loaded initially from the database
            if (array_forecasting.isEmpty) {
                city_details(cityname: "London", condition: "sun.max", Current_temp: 24.5, Desc: "clear sky")
                locationManager.requestLocation()
            }
            //2) Data is loaded in array_forecasting and is now used to display current weather details
        else{
                city_details(cityname: array_forecasting[0].city! , condition: array_forecasting[0].condition_name!, Current_temp: array_forecasting[0].current_temp, Desc: array_forecasting[0].desc! )
            }
       
    //Comment The above declared timer variable and the following code to stop fetching live weather data of current location after every 3 hours (10800 seconds)
        timer =  Timer.scheduledTimer(withTimeInterval: 10800.0, repeats: true) { (timer) in
            // Do what you need to do repeatedly
           self.locationManager.requestLocation()
        }
    }

//MARK: -Table View DataSource Methods
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return forecast.count
    return array_forecasting.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell"
            , for: indexPath) as? Weathercell {
          
            let item = array_forecasting[indexPath.row]
                
            let w = WeatherModel(conditionid: item.condition_id  as! Int , cityname: "", temperature: item.max_temp as! Double, description: item.desc!, date: item.date!, forecast: forecast , temp_min: item.min_temp as! Double , temp_max: item.max_temp as! Double)
            cell.configurecell( weather: w )
              // let item = forecast[indexPath.row]
               //print("Check False = : ")
               //let w = WeatherModel(conditionid: item.weather[0].id , cityname: "", temperature: item.main.temp, description: item.weather[0].description, date: item.dt_txt, forecast: forecast, temp_min: item.main.temp_min , temp_max: item.main.temp_max)
                //cell.configurecell( weather: w )
            cell.backgroundColor = .clear
            return cell
        }
       else {
     return Weathercell()
        }
    }
    
//MARK: - CORE DATA Implementation

//This Function Saves Data in an array_forecasting to be saved in the Cordata Sql Lite Database
    func save_data (list : [List],cityname : String , condition: String, Current_temp : Double )
{
    for items in 0..<40
    {
        let data_db = Forecasting(context: self.context)
        data_db.date = list[items].dt_txt
        data_db.condition_id = list[items].weather[0].id as NSNumber
        data_db.max_temp = list[items].main.temp_max as NSNumber
        data_db.min_temp = list[items].main.temp_min as NSNumber
        data_db.desc = list[items].weather[0].description
        data_db.city = cityname
        data_db.condition_name = condition
        data_db.current_temp = Current_temp
        self.array_forecasting.insert(data_db, at: items)
    }
}
    //This Function Saves context for storing Data in Cordata SQL lite Database
    func save_context(){
    do {
        try context.save()
        } catch  {
            print("ERROR IN SAVING CONTEXT \(error) ")
              }
       }
    
    //This Function loads Data from Coredata SQL lite Database
    func load_data_from_database()
    {
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        do {
            try array_forecasting = context.fetch(request)
        } catch {
            print("ERROR IN LOADING CONTEXT \(error) ")
        }
        tableView.reloadData()
    }
    //this function is responsible for updating current weather details from data base initially when the app is opened
    func city_details(cityname : String , condition: String, Current_temp : Double, Desc: String )
    {
        let current_tem = Current_temp
        self.temperatureLabel.text = String (format: "%.1f", current_tem)
        self.cityLabel.text = cityname
        self.DescriptionLabel.text = Desc
        self.conditionImageView.image = UIImage(systemName: condition)
    }
    
    //This Function Deletes Data of previous weather forecast details <(in Coredata SQL lite Database)> every time when new weather is searched; either by city name or by location
    func delete_data ()
    {
        do {
            let array_forecast = try context.fetch(request)
            for data in array_forecast {
            context.delete(data)
        }
    }
        catch {
                   print("ERROR IN LOADING CONTEXT \(error) ")
        }
    }
}
//MARK: - UI TEXT VIEW DELEGATE
extension WeatherViewController : UITextFieldDelegate {
    
    //Search button
    @IBAction func SearchPressed(_ sender: UIButton) {
           SearchTextField.endEditing(true)
        //print(SearchTextField.text!)
       }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           SearchTextField.endEditing(true)
        //print(SearchTextField.text!)
           return true
       }
       func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
           if textField.text != ""{
               return true
           }
           else {
               textField.placeholder = "Type Something"
               return false
           }
       }
       func textFieldDidEndEditing(_ textField: UITextField) {
           let cityName = SearchTextField.text!
           weathermanager.fetchForecastdata(city: cityName)
           SearchTextField.text = ""
       }
}
//MARK: - Weather Manager

//Uses Delegation to update weather data on 'View' after fetching from Api in the 'Model' (WeatherManager)
extension WeatherViewController : WeatherManagerDelegate {
    func didupdateweather (weather : WeatherModel)
       {
           DispatchQueue.main.async {
            
               // below code is responsible for Displaying current weather details everytime when a search is made
               self.temperatureLabel.text = weather.temperaturestring
               self.cityLabel.text = weather.cityname
               self.DescriptionLabel.text = weather.description
               self.conditionImageView.image = UIImage(systemName: weather.conditionName)
               self.forecast = weather.forecast
    
            //The database is updated after every search (either by city name or current location)
            //Mentaining the local data persistence
            if (self.array_forecasting.isEmpty)
            {
                self.delete_data()
                self.save_data(list: self.forecast ,cityname: weather.cityname, condition: weather.conditionName, Current_temp: weather.temperature)
                self.save_context()
                self.load_data_from_database()
            }
            else {
                self.array_forecasting = []
                self.delete_data()
                self.save_data(list: self.forecast, cityname: weather.cityname, condition: weather.conditionName, Current_temp: weather.temperature)
                self.save_context()
                self.load_data_from_database()
               
            }
        }
            
            //self.tableView.reloadData()
       }
    
    //This function is called if there is an error with the cityname or connection and it displays and error alert on the screen
       func errorpoppedup(error: Error) {
        let alert = UIAlertController(title: "Incorrect city name or Poor Connection", message: "Please write correct name of the city or check your Connection", preferredStyle: .alert)
             let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
             })
             alert.addAction(ok)
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
    }
}

//MARK: - CLLocationManagerDelegate
//Implementation of Location to fetch weather data for current location
extension WeatherViewController: CLLocationManagerDelegate {
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weathermanager.fetchForecastWeather(latitude: lat, longitude: lon)
        }
    }
    
    //This function is called if there is an error with the current location or connection and it displays and error alert on the screen
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Poor Location Poor Connection", message: "Please check your phone's location or   check your Connection", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    })
                    alert.addAction(ok)
                    DispatchQueue.main.async(execute: {
                       self.present(alert, animated: true)
               })
    }
}
