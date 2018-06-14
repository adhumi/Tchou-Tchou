import Cocoa
import ServiceManagement

class LaunchView: NSView {
    
    @IBOutlet var startupOpeningCheckbox: NSButton!
    
    override func awakeFromNib() {
        startupOpeningCheckbox.state = isOpeningAtStartup() ? .on : .off
    }

    @IBAction func toggleStartupOpening(_ sender: NSButton) {
        let openAtStartup = sender.state == .on
        
        let launcherAppId = "fr.adhumi.tchou-tchou.launcher"
        UserDefaults.standard.set(openAtStartup, forKey: "OpenAtStartup")
        SMLoginItemSetEnabled(launcherAppId as CFString, sender.state == .on)
    }
    
    func isOpeningAtStartup() -> Bool {
        return UserDefaults.standard.bool(forKey: "OpenAtStartup")
    }
    
}
