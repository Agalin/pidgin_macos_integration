//
//  main.swift
//  Pidgin MacOS Integration
//
//  Created by Agalin on 11.08.2018.
//  Copyright © 2018 Agalin. All rights reserved.
//
import Darwin
import Foundation
import Cocoa

typealias CString = UnsafeMutablePointer<CChar>?

extension String {
    static func fromC(_ cString: CString) -> String {
        return String(cString: UnsafePointer<CChar>(cString!))
    }
}

func toPtr<T : AnyObject>(_ obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func fromPtr<T : AnyObject>(_ ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func debug(_ message: String) {
    #if DEBUG
    fputs(message, __stderrp)
    if(message.last != "\n")
    {
        fputs("\n", __stderrp)
    }
    #endif
}

func tryCast<T : AnyObject>(_ ptr: UnsafeMutableRawPointer?) -> T? {
    if(ptr == nil)
    {
        debug("Received invalid pointer.\n")
        return nil
    }
    return fromPtr(ptr!)
}

func forEachInList(_ list: UnsafeMutablePointer<GList>?, function: (UnsafeMutablePointer<GList>) -> ()) {
    var element = list
    while(element != nil) {
        function(element!)
        element = element!.pointee.next
    }
}

@objc class Plugin : NSObject, NSUserNotificationCenterDelegate {
    var instance: UnsafeMutablePointer<PurplePlugin>?
    static let callbacks = ["receiving-im-msg", "receiving-chat-msg", /*"received-im-msg", "received-chat-msg",*/ "displayed-im-msg", "displayed-chat-msg"]
    var app : UnsafeMutablePointer<GtkosxApplication>
    var selfPtr : UnsafeMutableRawPointer?
    var appReady = false
    
    lazy var aboutItem = getMenuItem(type: .About)
    lazy var helpItem = getMenuItem(type: .Help)
    lazy var preferencesItem = getMenuItem(type: .Preferences)
    lazy var defaultQuitItem = getMenuItem(type: .Quit)
    lazy var separatorItem = gtk_separator_menu_item_new()
    
    enum MenuItem {
        case About
        case Preferences
        case Help
        case Quit
    }
    
    override init() {
        debug("Initialization\n")
        let array : [CVarArg] = []
        let list = getVaList(array)
        g_object_new_valist(gtkosx_application_get_type(), nil, list)
        app = gtkosx_application_get()
    }
    
    @objc func pluginLoad(plugin: UnsafeMutablePointer<PurplePlugin>) {
        debug("Load\n")
        selfPtr = toPtr(self)
        debug("selfPtr: \(String(describing: selfPtr))")
        instance = plugin
        
        connectMessageCallbacks()
        setBuddyListMenu()
        setConversationMenu()
    }
    
    func setApplicationReady() {
        if(!appReady) {
            gtkosx_application_ready(app)
            appReady = true
        }
    }
    
    func connectMessageCallbacks() {
        for c in Plugin.callbacks {
            register_callback_with_data(instance!, {account, sender, message, conv, flags, data in
                if let selfRef : Plugin = tryCast(data) {
                    return selfRef.handleReceivedMessage(account: account, sender: sender, message: message, conv: conv, flags: flags)
                }
                return 0
            }, c, selfPtr!)
        }
    }
    
    func syncMenuBar(_ menu: UnsafeMutablePointer<GtkWidget>?, visible: Bool) {
        if(visible) {
            set_menu(menu)
            setSharedMenuItems()
            gtk_widget_hide(menu)
            setApplicationReady()
        }
        else {
            gtk_widget_show(menu)
        }
    }
    
    func getMenuItem(type: MenuItem) -> UnsafeMutablePointer<GtkWidget> {
        let buddyListWindow = pidgin_blist_get_default_gtk_blist()!
        let itemFactory = buddyListWindow.pointee.ift
        switch type {
        case .About:
            let about = gtk_item_factory_get_item(itemFactory, "/Help/About")
            return about!
        case .Help:
            let help = gtk_item_factory_get_item(itemFactory, "/Help")
            return help!
        case .Preferences:
            let preferences = gtk_item_factory_get_item(itemFactory, "/Tools/Preferences")
            return preferences!
        case .Quit:
            let quit = gtk_item_factory_get_item(itemFactory, "/Buddies/Quit")
            return quit!
        }
    }
    
    func setSharedMenuItems() {
        gtkosx_application_set_about_item(app, aboutItem)
        gtkosx_application_insert_app_menu_item(app, preferencesItem, 1)
        gtkosx_application_insert_app_menu_item(app,  separatorItem, 1)
        helpItem.withMemoryRebound(to: GtkMenuItem.self, capacity: 1) {
            help in gtkosx_application_set_help_menu(app, help)
        }
        gtkosx_application_set_window_menu(app, nil)
        gtk_widget_hide(defaultQuitItem)
    }
    
    func setBuddyListMenu() {
        let blistMenu = gtk_widget_get_parent(pidgin_blist_get_default_gtk_blist()!.pointee.menutray)
        if(blistMenu != nil){
            syncMenuBar(blistMenu, visible: true)
        }
        register_buddy_list_created_callback(instance, {blist, data in
            if let selfRef : Plugin = tryCast(data) {
                return selfRef.handleBuddyListCreated(list: blist)
            }
            return 0
        }, "gtkblist-created", selfPtr!)
    }
    
    func setConversationMenuForEachWindow(visible: Bool) {
        debug("Conversation menu for each window: \(visible)")
        forEachInList(pidgin_conv_windows_get_list()) {element in
            let window = element.pointee.data.assumingMemoryBound(to: PidginWindow.self)
            let menu = window.pointee.menu.menubar
            syncMenuBar(menu, visible: visible)
        }
    }
    
    func setConversationMenu() {
        setConversationMenuForEachWindow(visible: true)
        register_conversation_created_callback(instance, {conversation, data in
            if let selfRef : Plugin = tryCast(data) {
                return selfRef.handleConversationCreated(conversation: conversation)
            }
            return 0
        }, "conversation-created", selfPtr!)
    }
    
    func unsetMenu() {
        if let blistMenu = gtk_widget_get_parent(pidgin_blist_get_default_gtk_blist()?.pointee.menutray) {
            gtk_widget_show(blistMenu)
            gtk_widget_show(defaultQuitItem)
        }
        setConversationMenuForEachWindow(visible: false)
    }
    
    @objc func pluginUnload(plugin: UnsafeMutablePointer<PurplePlugin>) {
        unsetMenu()
        purple_signals_disconnect_by_handle(plugin);
    }
    
    func handleConversationCreated(conversation: UnsafeMutablePointer<PurpleConversation>?) -> gboolean {
        let pidginConversation = conversation?.pointee.ui_data.assumingMemoryBound(to: PidginConversation.self)
        let conversationWindow = pidgin_conv_get_window(pidginConversation)
        let menu = conversationWindow?.pointee.menu.menubar
        syncMenuBar(menu, visible: true)
        return 0
    }
    
    func handleBuddyListCreated(list: UnsafeMutablePointer<PurpleBuddyList>?) -> gboolean {
        let pidginBlist = list?.pointee.ui_data.assumingMemoryBound(to: PidginBuddyList.self)
        let blistMenu = gtk_widget_get_parent(pidginBlist!.pointee.menutray)
        syncMenuBar(blistMenu, visible: true)
        gtkosx_application_attention_request(app, CRITICAL_REQUEST)
        return 0
    }
    
    func handleReceivedMessage(account: UnsafeMutablePointer<PurpleAccount>?, sender: UnsafeMutablePointer<CString>?, message: UnsafeMutablePointer<CString>?, conv: UnsafeMutablePointer<PurpleConversation>?, flags: UnsafeMutablePointer<PurpleMessageFlags>?) -> gboolean {
        
        let buddy = purple_find_buddy(account, sender!.pointee);
        let senderName = buddy != nil ? (buddy!.pointee.alias != nil) ? String(cString: buddy!.pointee.alias!) : String(cString: buddy!.pointee.name!) : String(cString: sender!.pointee!)
        let protocolName = String(cString: purple_account_get_protocol_name(account))
        
        let notification = NSUserNotification()
        notification.title = senderName // TODO: Add conversation name / conversation type for chat
//        notification.subtitle = "Test" // TODO: Add protocol name
        notification.subtitle = protocolName
        
//        notification.soundName = NSUserNotificationDefaultSoundName
        notification.informativeText = String.fromC(message!.pointee)
 
        if let image = getIcon(for: buddy) {
            notification.contentImage = NSImage(byReferencingFile: image)
        }
//        NSUserNotificationCenter.default.delegate = self as NSUserNotificationCenterDelegate
        NSUserNotificationCenter.default.deliver(notification)
        gtkosx_application_attention_request(gtkosx_application_get(), INFO_REQUEST)
        return 0
    }
    
    func getIcon(for buddy: UnsafeMutablePointer<PurpleBuddy>?) -> String? {
        if let icon = purple_buddy_get_icon(buddy)
        {
            let iconPath = purple_buddy_icon_get_full_path(icon);
            if(iconPath != nil){
                return String.fromC(iconPath)
            }
        }
        return nil
    }
    
//    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
//        return true
//    }
    
    func userNotificationCenter(_: NSUserNotificationCenter, didDeliver: NSUserNotification) {
        
    }

    func userNotificationCenter(_: NSUserNotificationCenter, didActivate: NSUserNotification) {
        
    }
    

}
