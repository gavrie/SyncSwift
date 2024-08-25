import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    
    var remotes: [String] = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
        }
        
        constructMenu()
        
        // Hide the dock icon and prevent the app from appearing in the Dock or App Switcher
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "Sync", action: #selector(doSync), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Copy", action: #selector(doCopy), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "List Remotes", action: #selector(doListRemotes), keyEquivalent: "l"))
        
        // Create a nested menu
        let advancedMenu = NSMenu()
        let advancedMenuItem = NSMenuItem(title: "Advanced", action: nil, keyEquivalent: "")
        advancedMenuItem.submenu = advancedMenu
        
        advancedMenu.addItem(NSMenuItem(title: "Check", action: #selector(doSync), keyEquivalent: "k"))
        advancedMenu.addItem(NSMenuItem(title: "Mount", action: #selector(doSync), keyEquivalent: "m"))
        
        menu.addItem(advancedMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func doSync() {
        let alert = NSAlert()
        alert.messageText = "Sync"
        alert.informativeText = "Enter source and destination paths:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let sourceInput = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        sourceInput.placeholderString = "Source path"
        let destInput = NSTextField(frame: NSRect(x: 0, y: 28, width: 200, height: 24))
        destInput.placeholderString = "Destination path"
        
        alert.accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 58))
        alert.accessoryView?.addSubview(sourceInput)
        alert.accessoryView?.addSubview(destInput)
        
        if alert.runModal() == .alertFirstButtonReturn {
            let source = sourceInput.stringValue
            let destination = destInput.stringValue
            let _ = RcloneOperations.sync(source: source, destination: destination)
        }
    }
    
    @objc func doCopy() {
        let alert = NSAlert()
        alert.messageText = "Copy"
        alert.informativeText = "Enter source and destination paths:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let sourceInput = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        sourceInput.placeholderString = "Source path"
        let destInput = NSTextField(frame: NSRect(x: 0, y: 28, width: 200, height: 24))
        destInput.placeholderString = "Destination path"
        
        alert.accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 58))
        alert.accessoryView?.addSubview(sourceInput)
        alert.accessoryView?.addSubview(destInput)
        
        if alert.runModal() == .alertFirstButtonReturn {
            let source = sourceInput.stringValue
            let destination = destInput.stringValue
            let _ = RcloneOperations.copy(source: source, destination: destination)
        }
    }
    
    func fetchRemotes() {
        print("foo1")
        RcloneOperations.apiClient.fetchRemotes { result in
            DispatchQueue.main.async {
                print("foo2")
                switch result {
                case .success(let remotes):
                    print("foo3")
                    print(remotes) //self.remotes = remotes
                case .failure(let error):
                    print("foo4")
                    let output = "Error fetching remotes: \(error.localizedDescription)"
                    print(output)
                }
            }
        }
        print("foo5")
    }
    
    @objc func doListRemotes() {
        print("foo")
        fetchRemotes()
        
        /*
        let alert = NSAlert()
        alert.messageText = "List Remotes"
        alert.informativeText = "Enter remote name:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
//            let remote = input.stringValue
//            let _ = RcloneOperations.list(remote: remote)
        }
        */
    }
    
}
