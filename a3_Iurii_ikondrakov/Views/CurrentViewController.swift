//
//  CurrentViewController.swift
//  a3_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-03-11.
//

import UIKit
import MapKit
import CoreLocation

class CurrentViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var cityLabel:      UILabel!
    @IBOutlet weak var tempLabel:      UILabel!
    @IBOutlet weak var windLabel:      UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var image:          UIImageView!
    @IBOutlet weak var humidityLabel:  UILabel!
    
    let locationManager:CLLocationManager = CLLocationManager()
    var env:NSDictionary?                 = NSDictionary()
    var currWeather:Weather               = Weather()
    var timer:Timer?                      = nil
        
    var index:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "Env", ofType: "plist") {
            env = NSDictionary(contentsOfFile: path)
        } else {
            print("ERROR: Could not find 'Env.plist' file")
            return
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate        = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
        
        //Update weather every 10 min
        timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { timer in
            print("\nINFO: Updating at \(timer.fireDate)")
            self.getWeather(city: self.currWeather.location)
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        let okAction        = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }

    @IBAction func historyBtn(_ sender: Any) {
        guard let historyScreen = storyboard?
                .instantiateViewController(withIdentifier: "history")
                as? HistoryViewController
        else {
            print("ERROR: Could not find History Screen")
            return
        }
        
        self.navigationController?
            .pushViewController(historyScreen, animated: true)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        currWeather.time = Date()
        
        showAlert(message: "The Report was succesfully saved")
        Singleton.getInstance().insertItem(item: currWeather)
    }
    
    private func updateWeather() {
        cityLabel.text      = currWeather.location
        conditionLabel.text = currWeather.condition
        tempLabel.text      = "\(currWeather.temperature)°C"
        humidityLabel.text  = "\(currWeather.humidity)%"
        windLabel.text      = "\(currWeather.wind)kph from \(currWeather.windDirection)"
        
    }
    
    private func decodeJSON(from:Data) -> Weather {
        var item:Weather = Weather()
        do {
            let decoder = JSONDecoder()
            item = try decoder.decode(Weather.self, from: from)
        } catch let error {
            print("ERROR: Could not decode Weather Data")
            print("Error Details: \(error)")
        }
        return item
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location
        else {
            print("ERROR: Could not acquire current location")
            return
        }
        fetchCity(from: location) { city, error in
            if let error = error {
                print("ERROR: Could not not acquire city name from the current location")
                print("Error Details: \(String(describing: error))")
                return
            }
            if let city = city {
                self.getWeather(city: city)
            }
        }
    }
    
    private func getWeather(city:String) {
        if(env != nil) {
            let apiEndpoint = env?.object(forKey: "weather_end_point") ?? ""
            let apiKey      = env?.object(forKey: "weather_api_key") ?? ""
            let apiRequest  = "\(apiEndpoint)?key=\(apiKey)&q=\(city.replacingOccurrences(of: " ", with: "+"))&aqi=no"
            
            guard let apiRequestUrl = URL(string: apiRequest) else {
                print("ERROR: Could not create API Request URL")
                return
            }
            
            fetch(from: apiRequestUrl) {data, response, error in
                if let error = error {
                    print("ERROR: Could not fetch the weather for city: \(city)")
                    print("Error Details: \(error)")
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.currWeather = self.decodeJSON(from: data)
                        self.getIcon(url: "https:\(self.currWeather.iconSrc)")
                        self.updateWeather()
                    }
                }
            }
        } else {
            print("ERROR: Could not acquire api key and endpoint")
        }
    }
    
    private func getIcon(url:String) {
        guard let imgUrl = URL(string: url) else {
            print("ERROR: Could not create Image URL")
            return
        }
        
        fetch(from: imgUrl) { (data, response, error) -> () in
            if let error = error {
                print("ERROR: Could not fetch the condition image")
                print("Error Details: \(error)")
                return
            }
            if let data = data {
                DispatchQueue.main.async {
                    self.image.image = UIImage(data: data)
                }
            }
        }
    }
    
    private func fetchCity(from location:CLLocation, completion: @escaping (_ city:String?, _ error:Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale.init(identifier: "en")) {
            placemarks, error in
            completion(placemarks?.first?.locality, error)
        }
    }
    
    private func fetch(from url:URL, completion:@escaping (_ data:Data?, _ respone:URLResponse?, _ error:Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
