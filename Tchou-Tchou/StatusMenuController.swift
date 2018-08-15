import Cocoa
import CoreWLAN

class StatusMenuController: NSObject {
    @IBOutlet var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let wifiAPI = WifiAPI()
    
    @IBAction func clickedQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        statusItem.highlightMode = true
        statusItem.configure(with: nil)
        
        refreshSpeed()
    }
    
    @objc func refreshSpeed() {
        let supportedNetworks = [
            [
                "ssid" : "_SNCF_WIFI_INOUI",
                "unit" : UnitSpeed.metersPerSecond
            ],
            [
                "ssid" : "WIFIonICE",
                "unit" : UnitSpeed.kilometersPerHour
            ]
        ]
        let supportedSsids = supportedNetworks.flatMap { supportedNetwork in supportedNetwork["ssid"] } as! [String]
        let currentSsid = CWWiFiClient.shared().interface()?.ssid()
        #if RELEASE
            guard supportedSsids.contains(currentSsid) else {
                self.launchTimer()
                return
            }
        #endif
        
        wifiAPI.fetchSpeed(system: currentSsid!) { speed in
            guard let speed = speed else {
                DispatchQueue.main.async {
                    self.statusItem.configure(with: nil)
                    self.launchTimer()
                }
                return
            }
            
            var unit = UnitSpeed.kilometersPerHour
            for (network) in supportedNetworks {
                if network["ssid"] as? String == currentSsid {
                    unit = network["unit"] as! UnitSpeed
                }
            }
            let value = NSMeasurement(doubleValue: speed, unit: unit)
            let formatter = MeasurementFormatter()
            formatter.numberFormatter.maximumFractionDigits = 1
            
            DispatchQueue.main.async {
                self.statusItem.configure(with: formatter.string(from: value as Measurement<Unit>))
                self.launchTimer()
            }
        }
    }
    
    func launchTimer() {
        self.perform(#selector(refreshSpeed), with: nil, afterDelay: 5)
    }
}

extension NSStatusItem {
    func configure(with title: String?) {
        if let title = title {
            button?.font = button?.font?.fixedWidthDigitsFont
            button?.title = title
            isVisible = true
        } else {
            isVisible = false
        }
    }
}

