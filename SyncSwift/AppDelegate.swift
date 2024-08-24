import Cocoa


@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
        }

        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

//    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
//        return true
//    }

    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "Sync", action: #selector(doSync), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Copy", action: #selector(doCopy), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "List Remote", action: #selector(doListRemote), keyEquivalent: "l"))
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
            runRcloneCommand(["sync", source, destination])
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
            runRcloneCommand(["copy", source, destination])
        }
    }

    @objc func doListRemote() {
        let alert = NSAlert()
        alert.messageText = "List Remote"
        alert.informativeText = "Enter remote name:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input

        if alert.runModal() == .alertFirstButtonReturn {
            let remote = input.stringValue
            runRcloneCommand(["lsd", remote])
        }
    }

    func runRcloneCommand(_ arguments: [String]) {
        let task = Process()
        task.launchPath = "/opt/homebrew/bin/rclone"
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            let alert = NSAlert()
            alert.messageText = "Rclone Output"
            alert.informativeText = output
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
