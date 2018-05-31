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
        self.title = title
        self.isVisible = title == nil ? false : true
    }
}
