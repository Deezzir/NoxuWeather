//
//  Weather.swift
//  a3_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-03-11.
//

import Foundation
import UIKit

struct Weather: Codable {
    var location:String      = "Cupertino"
    var windDirection:String = "N"
    var condition:String     = ""
    var iconSrc:String       = ""
    var humidity:Int         = 0
    var temperature:Double   = 0.0
    var wind:Double          = 0.0
    var time:Date            = Date()
    
    //Mappings
    enum CodingKeys: String, CodingKey {
        case current, location
    }
    
    enum LocationCodingKeys: String, CodingKey {
        case location = "name"
    }
    
    enum CurrentCodingKeys: String, CodingKey {
        case temperature   = "temp_c"
        case wind          = "wind_kph"
        case windDirection = "wind_dir"
        case condition, humidity
    }
    
    enum ConditionCodingKeys:String, CodingKey {
        case condition = "text"
        case iconSrc   = "icon"
    }
    
    func encode(to encoder: Encoder) throws {}
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let response       = try decoder.container(keyedBy: CodingKeys.self)
        
        let location       = try response.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        self.location      = try location.decodeIfPresent(String.self, forKey: .location) ?? ""
        
        let current        = try response.nestedContainer(keyedBy: CurrentCodingKeys.self, forKey: .current)
        self.temperature   = try current.decodeIfPresent(Double.self, forKey: .temperature) ?? 0.0
        self.wind          = try current.decodeIfPresent(Double.self, forKey: .wind) ?? 0.0
        self.windDirection = try current.decodeIfPresent(String.self, forKey: .windDirection) ?? "No wind direction"
        self.humidity      = try current.decodeIfPresent(Int.self, forKey: .humidity) ?? 0
        
        let condition      = try current.nestedContainer(keyedBy: ConditionCodingKeys.self, forKey: .condition)
        self.condition     = try condition.decode(String.self, forKey: .condition)
        self.iconSrc       = try condition.decode(String.self, forKey: .iconSrc)
        
    }
}
