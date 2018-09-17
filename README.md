## MacOS integration plugin for Pidgin

[Pidgin](https://pidgin.im/) is a multiprotocol communicator based on *libPurple* with GUI created using GTK+. There is no official support for macOS as there is an alternative written using native frameworks - [Adium](https://adium.im/). Sadly, Adium seems to be nearly abandoned. It means that there is no native libPurple client for macOS. This plugin tries make Pidgin feel as native as it is possible.

## Basic Integration

I suggest to create app bundle (or use mine: [Pidgin Bundle](https://github.com/Agalin/pidgin_bundle)) for Pidgin as it adds dock icon and hides Terminal window. It's **REQUIRED** for notifications and possible future translations to work properly.

Homebrew has a formula for *gtk-chtheme* which makes theme change easier - and macOS themes for GTK are easy to find.

## Features

There are currently following features implemented:
* **Menu integration** - all buddy list and conversation menus moved from window to menubar, moved standard macOS options: *preferences*, *about* to application menu.
* **Notification Center integration** - every message received shows native macOS notification and requests attention (jumping dock icon).
* Built-in GTK shortcuts mapped to ⌘-based from ⌃-based (limited to built-in, not Pidgin-defined) through [GTK OSX Application](http://gtk-osx.sourceforge.net/gtk-mac-integration/GtkosxApplication.html). Includes support for ⌘-Q (check issues section).

## Implementation details

Plugin is written in Swift. As Pidgin is written in C, bridging is needed. That's done by Objective-C to Swift bridge. Only things that are really hard or impossible to do via bridging (varargs functions, some type casting like callback registration) is done in Objective-C. It's mostly just an ocasion for the author to learn Swift and Cocoa.

## Issues and TODO

* GTK OSX Application does not provide any way to cleanly deintegrate it from running GTK application. It means that plugin unload leaves Pidgin with some integration intact. Window menus are made visible again and callbacks are deregistered but that's all.
* No configuration support. Plugin is in very early stage of development and at the moment does not support ANY form of configuration. Notification banners can be mutted from system preferences though.
* No clean build procedure. Project is currently hardcoded to Homebrew-installed libraries in specific versions. It should be changed to *pkg-config*.
* No prebuilt libraries - see previous point.
* Protocols are missing icons in Conversation **Send To** menu. They need to be added manually.
* Notifications are displayed for *receiving-im-msg* and *receiving-chat-msg* instead of *displayed-im-msg* and *displayed-chat-msg* (I had some issues with text pointers for this one callback type) which means that filtered messages can still send notifications. **It can lower your privacy!**
* Currently using **NSUserNotification** api which will be deprecated with the release of Mojave.
* Help menu does not stay visible all the time (it's still connected to Buddy List window).
* It seems that preferences menu option is only available for last opened window.
* ⌘-\` seems not to work.
* ⌘-Q seems not to call proper Pidgin termination callbacks. Some settings may be lost when used!
* ~~Application starts in background - that's actually issue with every GTK+ based app.~~ Fixed with correct `Info.plist` entries.
* It's possible to add some kind of Touch Bar support.

## Build/Install

As there are no prebuilt libraries and whole build system is currently a mess, it will require a lot of manual work with includes in XCode project settings.
Homebrew dependencies (those I'm aware of, they should already require other used libraries, like *glib*):
* Pidgin (obviously)
* GTK+ (surprise!)
* gtk-mac-integration
