//
//  ViewController.swift
//  a3_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-03-11.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var history:[Weather] = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
        self.history         = Singleton.getInstance().getHistory()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath) as! TableViewCell
        
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: TimeZone.current.identifier) {
            calendar.timeZone = timeZone
        }
        
        let current:Weather     = history[indexPath.row]
        let hour:Int            = calendar.component(.hour, from: current.time)
        let minute:Int          = calendar.component(.minute, from: current.time)
        
        cell.tempLabel.text     = "\(current.temperature)°C"
        cell.windLabel.text     = "Wind: \(current.wind)kph from \(current.windDirection)"
        cell.citytimeLabel.text = "\(current.location) at \(hour):\(minute / 10 != 0 ? "\(minute)" : "0\(minute)")"

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

