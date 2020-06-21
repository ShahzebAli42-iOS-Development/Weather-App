
import Foundation


//To capture Api response in the exact manner as generated by the api
struct BreakdownJsonStructure:  Decodable {
    let list : [List]
    let city : City
}

struct List:  Decodable {
    let main : Main
    let weather : [Weather]
    let dt_txt : String
}

struct City : Decodable{
    let name : String
}
struct Main : Decodable {
    let temp : Double
    let temp_min : Double
    let temp_max : Double
}
struct Weather : Decodable {
    let description : String
    let id : Int
}
