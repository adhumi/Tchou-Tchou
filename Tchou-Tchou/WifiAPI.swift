import Cocoa

class WifiAPI: NSObject {
    var supportedSystems = [
        [
            "ssid" : "_SNCF_WIFI_INOUI",
            "base" : "https://wifi.sncf",
            "endpoint" : "/router/api/train/gps"
        ],
        [
            "ssid" : "WIFIonICE",
            "base" : "https://iceportal.de/",
            "endpoint" : "/api1/rs/status"
        ]
    ]
    
    override init() {
        if let baseURL = UserDefaults.standard.string(forKey: "DebugWifiAPIBaseURL") {
            self.supportedSystems[0]["base"] = baseURL
        }
    }
    
    func fetchSpeed(system: String, completion: ((Double?)->(Void))?) {
        var currentSystem = supportedSystems[0]
        for (supportedSystem) in supportedSystems {
            if supportedSystem["ssid"] == system {
                currentSystem = supportedSystem as [String : String]
            }
        }
        let url = URL(string: currentSystem["base"]! + currentSystem["endpoint"]!)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                NSLog("API error: \(error)")
                completion?(nil)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                NSLog("Protocol error")
                completion?(nil)
                return
            }
            
            guard response.statusCode == 200 else {
                NSLog("API error: \(response.statusCode)")
                completion?(nil)
                return
            }
            
            guard let data = data else {
                NSLog("No data")
                completion?(nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                NSLog("Parsing error")
                completion?(nil)
                return
            }
            
            guard let content = json as? [String: AnyObject] else {
                NSLog("Parsing error")
                completion?(nil)
                return
            }
            
            // JSON format:
            // {"success":true,"fix":9,"timestamp":1510680380,"latitude":46.52514,"longitude":4.64676,"altitude":12,"speed":70,"heading":0}
            
            guard let speed = content["speed"] as? Double else {
                NSLog("Parsing error")
                completion?(nil)
                return
            }
            
            completion?(speed)
        }
        task.resume()
    }
}

