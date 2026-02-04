# HomeKeep 🏡

A simple, elegant, offline-first home maintenance reminder app for iOS.

HomeKeep helps you remember routine home maintenance tasks. Select from a preloaded library of 20 common tasks or create your own custom tasks, set a frequency, and receive reminders when tasks are due.

## Features

- 📋 **Preloaded Task Library** — 20 common maintenance tasks ready to add
- ✏️ **Custom Tasks** — Create your own with custom icons and frequencies
- 🔴🟡🟢 **Smart Dashboard** — Tasks sorted by urgency (overdue, due soon, good)
- 🔔 **Local Notifications** — Reminders before tasks are due
- 🧩 **Widgets** — Home Screen and Lock Screen widgets
- 📱 **Fully Offline** — No accounts, no backend, all data on device
- 🎨 **Native Apple Design** — Clean, minimal, satisfying to use

## Tech Stack

- SwiftUI + SwiftData
- iOS 18+
- WidgetKit
- UNUserNotificationCenter
- StoreKit 2

## Architecture

Clean MVVM structure:

```
HomeKeep/
├── Models/          — SwiftData models, enums, preloaded task library
├── ViewModels/      — Dashboard, TaskLibrary view models
├── Views/           — SwiftUI views organized by screen
├── Services/        — Notification & StoreKit managers
└── Utilities/       — Haptics, theming
```

## Building

1. Open `HomeKeep.xcodeproj` in Xcode
2. Select your target device/simulator
3. Hit ⌘R

Requires Xcode 16+ and iOS 18+ SDK.

## License

MIT
