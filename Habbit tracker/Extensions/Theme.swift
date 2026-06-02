import SwiftUI

#if canImport(UIKit)
import UIKit
extension Color {
    static var sysGroupedBackground: Color { Color(UIColor.systemGroupedBackground) }
    static var secSysGroupedBackground: Color { Color(UIColor.secondarySystemGroupedBackground) }
}
#elseif canImport(AppKit)
import AppKit
extension Color {
    static var sysGroupedBackground: Color { Color(NSColor.windowBackgroundColor) }
    static var secSysGroupedBackground: Color { Color(NSColor.controlBackgroundColor) }
}
#endif
