import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let launcherAppId = "fr.adhumi.tchou-tchou.launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        if UserDefaults.standard.value(forKey: "OpenAtStartup") == nil {
            UserDefaults.standard.set(false, forKey: "OpenAtStartup")
        }
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: Notification.Name("fr.adhumi.tchou-tchou.killLauncher"),
                                                         object: Bundle.main.bundleIdentifier!)
        }
    }
    
}
