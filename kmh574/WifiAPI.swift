import Cocoa

class WifiAPI: NSObject {
    let BASE_URL = "https://recette.pepita.vsct.fr" // Prod: https://wifi.sncf

    func fetchSpeed(completion: ((Double?)->(Void))?) {
        let url = URL(string: BASE_URL + "/router/api/train/gps")!
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

            // {"success":true,"fix":9,"timestamp":1510680380,"latitude":46.52514,"longitude":4.64676,"altitude":12,"speed":70,"heading":0}

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
