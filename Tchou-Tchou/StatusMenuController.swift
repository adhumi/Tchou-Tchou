import Cocoa
import CoreWLAN
import CoreLocation

class StatusMenuController: NSObject, CLLocationManagerDelegate {
    @IBOutlet var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let locationManager = CLLocationManager()

    let wifiAPI = WifiAPI()

    @IBAction func clickedQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    override func awakeFromNib() {
        statusItem.menu = statusMenu
        statusItem.highlightMode = true
        statusItem.configure(with: nil)
        
        locationManager.delegate = self

        refreshSpeed()
    }
       
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if (manager.authorizationStatus == .notDetermined) {
            manager.requestWhenInUseAuthorization()
        }
    }

    @objc func refreshSpeed() {
        #if RELEASE
        guard CWWiFiClient.shared().interface()?.ssid() == "_SNCF_WIFI_INOUI" else {
            self.launchTimer()
            return
        }
        #endif

        wifiAPI.fetchSpeed { speed in
            guard let speed = speed else {
                DispatchQueue.main.async {
                    self.statusItem.configure(with: nil)
                    self.launchTimer()
                }
                return
            }

            let value = NSMeasurement(doubleValue: speed, unit: UnitSpeed.metersPerSecond)
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
