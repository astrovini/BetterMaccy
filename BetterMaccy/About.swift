import Cocoa

class About {
  private var links: NSMutableAttributedString {
    let string = NSMutableAttributedString(
      string: "GitHub│Report an Issue",
      attributes: [NSAttributedString.Key.foregroundColor: NSColor.labelColor]
    )
    addLink(string, to: "GitHub", url: "https://github.com/astrovini/BetterMaccy")
    addLink(string, to: "Report an Issue", url: "https://github.com/astrovini/BetterMaccy/issues")
    return string
  }

  private var forkCredit: NSMutableAttributedString {
    let string = NSMutableAttributedString(
      string: "A fork of Maccy by Alex Rodionov ❤️",
      attributes: [NSAttributedString.Key.foregroundColor: NSColor.labelColor]
    )
    addLink(string, to: "Maccy", url: "https://github.com/p0deje/Maccy")
    return string
  }

  private var credits: NSMutableAttributedString {
    let credits = NSMutableAttributedString(string: "",
                                            attributes: [NSAttributedString.Key.foregroundColor: NSColor.labelColor])
    credits.append(links)
    credits.append(NSAttributedString(string: "\n\n"))
    credits.append(forkCredit)
    credits.setAlignment(.center, range: NSRange(location: 0, length: credits.length))
    return credits
  }

  private func addLink(_ string: NSMutableAttributedString, to substring: String, url: String) {
    let range = (string.string as NSString).range(of: substring)
    if range.location != NSNotFound {
      string.addAttribute(.link, value: url, range: range)
    }
  }

  @objc
  func openAbout(_ sender: NSMenuItem?) {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey.credits: credits])
  }
}
