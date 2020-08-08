import Foundation
import SwiftUI

@available(macOS, introduced: 11)
extension Scene {
  public func clearCommands() -> some Scene {
    self
      .commands {
        // File
        FileCommands()
        // Edit
        UndoRedoCommands()
        PasteboardCommands()
        // View
        SidebarCommands()
        ToolbarCommands()
        AppVisibilityCommands()
        // Window
        WindowListCommands()
        WindowSizeCommands()
        WindowArrangementCommands()
        // Help
        HelpCommands()
      }
  }
}

@available(macOS, introduced: 11)
struct FileCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .newItem) {}
  }
}

@available(macOS, introduced: 11)
struct AppVisibilityCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .appVisibility) {}
  }
}

@available(macOS, introduced: 11)
struct UndoRedoCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .undoRedo) {}
  }
}

@available(macOS, introduced: 11)
struct PasteboardCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .pasteboard) {}
  }
}

@available(macOS, introduced: 11)
struct ToolbarCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .toolbar) {}
  }
}

@available(macOS, introduced: 11)
struct SidebarCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .sidebar) {}
  }
}

@available(macOS, introduced: 11)
struct WindowListCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .windowList) {}
  }
}

@available(macOS, introduced: 11)
struct WindowSizeCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .windowSize) {}
  }
}

@available(macOS, introduced: 11)
struct WindowArrangementCommands : Commands
{
  var body: some Commands {
    CommandGroup(replacing: .windowArrangement) {}
  }
}

@available(macOS, introduced: 11)
struct HelpCommands : Commands {
  var body: some Commands {
    CommandGroup(replacing: .help) {}
  }
}
