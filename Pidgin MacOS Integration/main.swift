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
typealias GtkTreePath = OpaquePointer
typealias GtkTreeModel = OpaquePointer

let NULL = 0
let FALSE : gboolean = 0

extension String {
    static func fromC(_ cString: CString) -> String {
        if let str = cString {
            return String(cString: UnsafePointer<CChar>(str))
        }
        else { // TODO: Should return optional or throw
            log_all("macos", "Empty string received.")
            return ""
        }
    }
}

extension PidginConversation {
    var latestImagePath : String? {
        debug("Latest image path.")
        var result : String?
        if let entry = self.entry {
            result = entry.withMemoryRebound(to: GtkIMHtml.self, capacity: 1) {
                (html : UnsafeMutablePointer<GtkIMHtml>) -> String? in
                if let images = html.pointee.im_images {
                    let imageStruct = images.pointee.data.assumingMemoryBound(to: im_image_data.self)
                    let image = html.pointee.funcs.pointee.image_get(imageStruct.pointee.id)
                    if let imagePath = html.pointee.funcs.pointee.image_get_filename(image) {
                        return String(cString: imagePath)
                    }
                }
                return nil
            }
        }
        debug("Latest image path: \(String(describing: result))")
        log_all("macos", "Latest image path: \(String(describing: result))\n")
        return result
    }
}

extension PurpleMessageFlags {
    var containsImages : Bool {
        return self.rawValue & PURPLE_MESSAGE_IMAGES.rawValue > 0
    }
    
    var sentFromRemote : Bool {
        return self.rawValue & PURPLE_MESSAGE_REMOTE_SEND.rawValue > 0
    }
    
    var sent : Bool {
        return self.rawValue & PURPLE_MESSAGE_SEND.rawValue > 0
    }
    
    var received : Bool {
        return self.rawValue & PURPLE_MESSAGE_RECV.rawValue > 0
    }
    var system : Bool {
        return self.rawValue & PURPLE_MESSAGE_SYSTEM.rawValue > 0
    }
    
    var autoResponse : Bool {
        return self.rawValue & PURPLE_MESSAGE_AUTO_RESP.rawValue > 0
    }
    
    var activeOnly : Bool {
        return self.rawValue & PURPLE_MESSAGE_ACTIVE_ONLY.rawValue > 0
    }
    
    var nick : Bool {
        return self.rawValue & PURPLE_MESSAGE_NICK.rawValue > 0
    }
    
    var noLog : Bool {
        return self.rawValue & PURPLE_MESSAGE_NO_LOG.rawValue > 0
    }
    
    var whisper : Bool {
        return self.rawValue & PURPLE_MESSAGE_WHISPER.rawValue > 0
    }
    var error : Bool { return self.rawValue & PURPLE_MESSAGE_ERROR.rawValue > 0 }
    var delayed : Bool { return self.rawValue & PURPLE_MESSAGE_DELAYED.rawValue > 0 }
    var raw : Bool { return self.rawValue & PURPLE_MESSAGE_RAW.rawValue > 0 }
    var notify : Bool { return self.rawValue & PURPLE_MESSAGE_NOTIFY.rawValue > 0 } /**< Message is a notification */
    var noLinkify : Bool { return self.rawValue & PURPLE_MESSAGE_NO_LINKIFY.rawValue > 0 }
    var invisible : Bool { return self.rawValue & PURPLE_MESSAGE_INVISIBLE.rawValue > 0 } /**< Message should not be displayed */
    
    func shouldNotify() -> Bool {
        debug("shouldNotify")
        let toDisplay = (received || system) && !invisible && !sent
        log_all("macos", "Notification should be displayed: \(toDisplay), flags: \(String(self.rawValue, radix: 2))\n")
        return toDisplay
    }
}

// FIXME: Rename to camelcase.
func view_selection_func (selection : UnsafeMutablePointer<GtkTreeSelection>!, model : GtkTreeModel!, path : GtkTreePath!, path_currently_selected : gboolean, userdata : gpointer!) -> gboolean {
    var iter = GtkTreeIter(stamp: 0, user_data: nil, user_data2: nil, user_data3: nil)
    let result = gtk_tree_model_get_iter(model, &iter, path)
    if (result == 1)
    {
        let index = Int(String(cString: gtk_tree_model_get_string_from_iter(model, &iter)))
        if let i = index {
            let n = Plugin.notificationSounds[i]
            //        gtk_tree_model_get_value(model, &iter, 0, name)
            //        gtk_tree_model_get(model, &iter, "Sound", name, -1)
            if (path_currently_selected == FALSE)
            {
                log_all("macos", "\(n) is going to be selected.")
//                let file = n.1.isEmpty ? n.0 : "\(n.1)/\(n.0)"
                let file = n.0
                purple_prefs_set_string(Plugin.Preferences.NotificationSound.path, file)
                NSSound(named: file)?.play()
            }
            else
            {
                log_all("macos", "\(n) is going to be unselected.")
            }
        }
    }
    else {
        log_critical("macos", "Selected nonexistent sound!")
    }
    return 1
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
    log_all("macos", message)
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
enum GTypes : UInt {
    case G_TYPE_INVALID = 0b0 // 0 << 2
    case G_TYPE_NONE = 0b100 // 1 << 2
    case G_TYPE_INTERFACE = 0b1000 // 2 << 2
    case G_TYPE_CHAR = 0b1100 // 3 << 2
    case G_TYPE_UCHAR = 0b10000 // 4 << 2
    case G_TYPE_BOOLEAN = 0b10100 // 5 << 2
    case G_TYPE_INT = 0b11000 // 6 << 2
    case G_TYPE_UINT = 0b11100 // 7 << 2
    case G_TYPE_LONG = 0b100000 // 8 << 2
    case G_TYPE_ULONG = 0b100100 // 9 << 2
    case G_TYPE_INT64 = 0b101000 // 10 << 2
    case G_TYPE_UINT64 = 0b101100 // 11 << 2
    case G_TYPE_ENUM = 0b110000 // 12 << 2
    case G_TYPE_FLAGS = 0b110100 // 13 << 2
    case G_TYPE_FLOAT = 0b111000 // 14 << 2
    case G_TYPE_DOUBLE = 0b111100 // 15 << 2
    case G_TYPE_STRING = 0b1000000 // 16 << 2
    case G_TYPE_POINTER = 0b1000100 // 17 << 2
    case G_TYPE_BOXED = 0b1001000 // 18 << 2
    case G_TYPE_PARAM = 0b1001100 // 19 << 2
    case G_TYPE_OBJECT = 0b1010000 // 20 << 2
    case G_TYPE_VARIANT = 0b1010100 // 21 << 2
}
    
@objc class Plugin : NSObject, NSUserNotificationCenterDelegate, NSApplicationDelegate {
    var instance: UnsafeMutablePointer<PurplePlugin>?
    static let callbacks = ["receiving-im-msg", "receiving-chat-msg", /*"received-im-msg", "received-chat-msg",*/ "displayed-im-msg", "displayed-chat-msg"]
    var app : UnsafeMutablePointer<GtkosxApplication>
    var selfPtr : UnsafeMutableRawPointer?
    var appReady = false
    var attentionRequests = Set<Int>()
    let requestSemaphore = DispatchSemaphore(value: 1)
    
    lazy var aboutItem = getMenuItem(type: .About)
    lazy var helpItem = getMenuItem(type: .Help)
    lazy var preferencesItem = getMenuItem(type: .Preferences)
    lazy var defaultQuitItem = getMenuItem(type: .Quit)
    lazy var separatorItem = gtk_separator_menu_item_new()
    
    static var notificationSounds = getSystemNotificationSounds()
    var selectedNotification : String?
    
    var configuredWindows = Set<UnsafeMutablePointer<GtkWidget>?>()
    
    enum DefaultSounds : String {
        case Default
        case None
    }
    
    enum Preferences : String {
        case Prefix = "" // Prefix as separate function/computed property? Then no "/" needed.
        case NotificationSound = "/notification_sound"
        
        var path : String { return "/plugins/macos\(self.rawValue)" }
    }
    
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
        super.init()
        initPreferences()
    }
    
    @objc func pluginLoad(plugin: UnsafeMutablePointer<PurplePlugin>) {
        debug("Load\n")
        selfPtr = toPtr(self)
        debug("selfPtr: \(String(describing: selfPtr))")
        instance = plugin
        
        connectMessageCallbacks()
        setBuddyListMenu()
        setConversationMenu()
        log_all("macos", "Sounds: \(Plugin.notificationSounds)")
        log_all("macos", "Default sound: \(NSUserNotificationDefaultSoundName)")
        NSApp.delegate = self
    }
    
    func initPreferences() {
        purple_prefs_add_none(Preferences.Prefix.path)
        purple_prefs_add_string(Preferences.NotificationSound.path, "\(DefaultSounds.Default)")
    }
    
    func loadPreferences() {
        selectedNotification = String(cString: purple_prefs_get_string(Preferences.NotificationSound.path)!)
    }
    
    // Based on copy of get_config_frame of convcolors.c official Pidgin plugin source (version 2.13)
    // Some original comments still there.
    @objc class func getConfigFrame(_ plugin: UnsafeMutablePointer<PurplePlugin>?) -> UnsafeMutablePointer<GtkWidget>?
    {
        // TODO: CLeanup variables.
        // FIXME: Split function?
        var ret : UnsafeMutablePointer<GtkWidget>?
        var vbox : UnsafeMutablePointer<GtkWidget>?
        var vbox2 : UnsafeMutablePointer<GtkBox>?
        var sw : UnsafeMutablePointer<GtkWidget>?
        var button : UnsafeMutablePointer<GtkWidget>?
        var sg : UnsafeMutablePointer<GtkSizeGroup>?
        var iter : GtkTreeIter
        var event_view : UnsafeMutablePointer<GtkTreeView>?
        var event_store : UnsafeMutablePointer<GtkListStore>?
        var rend : UnsafeMutablePointer<GtkCellRenderer>?
        var col : UnsafeMutablePointer<GtkTreeViewColumn>?
        var sel : UnsafeMutablePointer<GtkTreeSelection>?
        var path : GtkTreePath?
        var hbox : UnsafeMutablePointer<GtkWidget>?
        
        ret = gtk_vbox_new(0, PIDGIN_HIG_CAT_SPACE);
        ret?.withMemoryRebound(to: GtkContainer.self, capacity: 1) { (r : UnsafeMutablePointer<GtkContainer>?) in
            gtk_container_set_border_width (r, guint(PIDGIN_HIG_BORDER))
        }
        
        sg = gtk_size_group_new(GTK_SIZE_GROUP_HORIZONTAL)
        
        pidgin_make_frame(ret, "Notifications")?.withMemoryRebound(to: GtkBox.self, capacity: 1) {
            vbox2 = $0
        }
        gtk_box_pack_start(vbox2, gtk_vbox_new(0, PIDGIN_HIG_BOX_SPACE), 0, 0, 0)
        vbox = pidgin_make_frame(ret, "Notification Sound")
        
        // The following is an ugly hack to make the frame expand so the sound events list is big enough to be usable
        vbox?.pointee.parent.withMemoryRebound(to: GtkBox.self, capacity: 1) { (p : UnsafeMutablePointer<GtkBox>?) in
            gtk_box_set_child_packing(p, vbox, 1, 1, 0, GTK_PACK_START)
        }
        vbox?.pointee.parent.pointee.parent.withMemoryRebound(to: GtkBox.self, capacity: 1) { (p : UnsafeMutablePointer<GtkBox>?) in
            gtk_box_set_child_packing(p, vbox?.pointee.parent, 1, 1, 0, GTK_PACK_START)
        }
        vbox?.pointee.parent.pointee.parent.pointee.parent.withMemoryRebound(to: GtkBox.self, capacity: 1) { (p : UnsafeMutablePointer<GtkBox>?) in
            gtk_box_set_child_packing(p, vbox?.pointee.parent.pointee.parent, 1, 1, 0, GTK_PACK_START);
        }
        
        /* SOUND SELECTION */
        var types = [GTypes.G_TYPE_STRING, GTypes.G_TYPE_STRING].map{$0.rawValue}
        event_store = gtk_list_store_newv(gint(types.count) , &types)
        iter = GtkTreeIter(stamp: 0, user_data: nil, user_data2: nil, user_data3: nil)
        for sound in notificationSounds {
            gtk_list_store_append (event_store, &iter)
            var gvalue = GValue()
            g_value_init(&gvalue, GTypes.G_TYPE_STRING.rawValue)
            
            g_value_set_string(&gvalue, sound.0)
            gtk_list_store_set_value(event_store, &iter, 0, &gvalue)
            
            g_value_set_string(&gvalue, sound.1)
            gtk_list_store_set_value(event_store, &iter, 1, &gvalue)
        }
        
        gtk_tree_view_new_with_model(OpaquePointer(event_store))?.withMemoryRebound(to: GtkTreeView.self, capacity: 1) {
            event_view = $0
        }
        
        sel = gtk_tree_view_get_selection (event_view)
        // FIXME: Select current sound as default.
        gtk_tree_selection_set_mode(sel, GTK_SELECTION_BROWSE)
        // TODO: Support preview by selection/double click
//        g_signal_connect (G_OBJECT (sel), "changed", G_CALLBACK (prefs_sound_sel), NULL);
//        path = gtk_tree_path_new_first()
//        gtk_tree_selection_select_path(sel, path)
//        gtk_tree_path_free(path)
        gtk_tree_selection_set_select_function(sel, view_selection_func, nil, nil)

        // TODO: Do something with FALSE, TRUE, NULL predefined values.
        let TRUE : gboolean = 1
        rend = gtk_cell_renderer_text_new()
        col = gtk_tree_view_column_new()
        gtk_tree_view_column_set_title(col, "Sound")
        gtk_tree_view_column_pack_start(col, rend, TRUE)
        gtk_tree_view_column_add_attribute(col, rend, "text", 0)
        gtk_tree_view_append_column (event_view, col)
        
        col = gtk_tree_view_column_new()
        gtk_tree_view_column_set_title(col, "Directory")
        gtk_tree_view_column_pack_start(col, rend, TRUE)
        gtk_tree_view_column_add_attribute(col, rend, "text", 1)
        gtk_tree_view_append_column (event_view, col)

        event_store?.withMemoryRebound(to: GObject.self, capacity: 1) { o in
            g_object_unref(o)
        }
        
        vbox?.withMemoryRebound(to: GtkBox.self, capacity: 1) { (b : UnsafeMutablePointer<GtkBox>) in
            event_view?.withMemoryRebound(to: GtkWidget.self, capacity: 1) { (e : UnsafeMutablePointer<GtkWidget>) in
                gtk_box_pack_start(b, pidgin_make_scrollable(e, GTK_POLICY_NEVER, GTK_POLICY_AUTOMATIC, GTK_SHADOW_IN, -1, 100), TRUE, TRUE, 0)
            }
            hbox = gtk_hbox_new(FALSE, PIDGIN_HIG_BOX_SPACE);
            gtk_box_pack_start(b, hbox, FALSE, FALSE, 0);
        }

        // Are there any buttons needed? Commented code left as example.
//        button = gtk_button_new_with_mnemonic(_("_Reset"));
//        g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(reset_sound), NULL);
//        gtk_box_pack_start(GTK_BOX(hbox), button, FALSE, FALSE, 1);
        
        gtk_widget_show_all(ret)
        g_object_unref(sg)
        
        // FIXME: Dealocate objects?
        return ret
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
        let blist = pidgin_blist_get_default_gtk_blist()
        if(blist != nil){
            let blistMenu = gtk_widget_get_parent(blist!.pointee.menutray)
            if(blistMenu != nil){
                syncMenuBar(blistMenu, visible: true)
            }
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
        register_conversation_created_callback(instance, {conversation, data in
            if let selfRef : Plugin = tryCast(data) {
                return selfRef.handleConversationDestroyed(conversation: conversation)
            }
            return 0
        }, "deleting-conversation", selfPtr!)
    }
    
    func unsetMenu() {
        if let blistMenu = gtk_widget_get_parent(pidgin_blist_get_default_gtk_blist()?.pointee.menutray) {
            gtk_widget_show(blistMenu)
            gtk_widget_show(defaultQuitItem)
        }
        setConversationMenuForEachWindow(visible: false)
    }
    
    static func forceRedraw(widget: UnsafeMutablePointer<GtkWidget>?) {
        gtk_widget_queue_draw(widget)
        while (gtk_events_pending () != 0)
        {
            gtk_main_iteration()
        }
    }
    
    func registerRedrawCallbacks(conversationWindow: UnsafeMutablePointer<PidginWindow>?) {
        let window = conversationWindow?.pointee.window
        register_configuration_event_callback(window, { window, event, data in
            debug("Redraw")
            gtk_widget_queue_draw(window)
            return FALSE
        })
        let callbacks = ["switch_page", "page-added", "page-removed"]
        for cb in callbacks {
            register_switch_page_callback(conversationWindow?.pointee.notebook, cb, window) { (notebook, page, page_index, window) -> gboolean in
                debug("Redraw")
                Plugin.forceRedraw(widget: window)
                return FALSE
            }
            
        }
    }
    
    func handleConversationDestroyed(conversation: UnsafeMutablePointer<PurpleConversation>?) -> gboolean {
        debug("Handling destroyed conversation")
        let pidginConversation = conversation?.pointee.ui_data.assumingMemoryBound(to: PidginConversation.self)
        let conversationWindow = pidgin_conv_get_window(pidginConversation)
        Plugin.forceRedraw(widget: conversationWindow?.pointee.window)
        return 0
    }
    
    func handleConversationCreated(conversation: UnsafeMutablePointer<PurpleConversation>?) -> gboolean {
        let pidginConversation = conversation?.pointee.ui_data.assumingMemoryBound(to: PidginConversation.self)
        let conversationWindow = pidgin_conv_get_window(pidginConversation)
        let menu = conversationWindow?.pointee.menu.menubar
        syncMenuBar(menu, visible: true)
        if configuredWindows.insert(conversationWindow?.pointee.window).inserted {
            debug("Configuring new window. Current count: \(configuredWindows.count)")
            registerRedrawCallbacks(conversationWindow: conversationWindow)
        }
        else {
            debug("Window already registered.")
        }
        Plugin.forceRedraw(widget: conversationWindow?.pointee.window)
        return 0
    }
    
    func handleBuddyListCreated(list: UnsafeMutablePointer<PurpleBuddyList>?) -> gboolean {
        let pidginBlist = list?.pointee.ui_data.assumingMemoryBound(to: PidginBuddyList.self)
        let blistMenu = gtk_widget_get_parent(pidginBlist!.pointee.menutray)
        syncMenuBar(blistMenu, visible: true)
        gtkosx_application_attention_request(app, CRITICAL_REQUEST)
        return 0
    }
    
    func requestAttention() {
        requestSemaphore.wait()
        attentionRequests.insert(NSApp.requestUserAttention(.informationalRequest))
        requestSemaphore.signal()
    }
    
    func handleReceivedMessage(account: UnsafeMutablePointer<PurpleAccount>?, sender: UnsafeMutablePointer<CString>?, message: UnsafeMutablePointer<CString>?, conv: UnsafeMutablePointer<PurpleConversation>?, flags: UnsafeMutablePointer<PurpleMessageFlags>?) -> gboolean {
        if(NSApp.isActive) {
            log_all("macos", "Pidgin is active, skipping notification.")
            return 0
        }
        if(!(flags?.pointee.shouldNotify() ?? false)){ return 0 }
        
        let buddy = purple_find_buddy(account, sender!.pointee);
        let senderName = buddy != nil ? (buddy!.pointee.alias != nil) ? String(cString: buddy!.pointee.alias) : buddy!.pointee.server_alias != nil ? String(cString: buddy!.pointee.server_alias) : String(cString: buddy!.pointee.name) : sender!.pointee != nil ? String(cString: sender!.pointee!) : "Unknown"
        let protocolName = String(cString: purple_account_get_protocol_name(account))
        if(flags != nil)
        {
            let withImages = flags!.pointee.containsImages
            log_all("macos", "Message contains images: \(withImages)")
            log_all("macos", "Conversation name: \(String(describing: conv?.pointee.name)), title: \(String(describing: conv?.pointee.title))")
        }
        let isChat = conv?.pointee.type == PURPLE_CONV_TYPE_CHAT
        let notification = NSUserNotification()
        notification.title = senderName
        let chatName = String.fromC(conv?.pointee.title ?? conv?.pointee.name)
        notification.subtitle = isChat ? "\(chatName.isEmpty ? "Group Chat" : chatName) - \(protocolName)" : protocolName
        
        if let sound = purple_prefs_get_string(Preferences.NotificationSound.path) {
            if let defaultSound = DefaultSounds(rawValue: String(cString: sound)) {
                switch(defaultSound) {
                case .Default: notification.soundName = NSUserNotificationDefaultSoundName
                case .None: notification.soundName = nil
                }
            }
            else {
                notification.soundName = String(cString: sound)
            }
//            sound.deallocate()
        }
        notification.informativeText = String.fromC(message?.pointee)
        
        if let image = getIcon(for: buddy) {
            notification.contentImage = NSImage(byReferencingFile: image)
        }
        //        NSUserNotificationCenter.default.delegate = self as NSUserNotificationCenterDelegate
        log_all("macos", "Notification sound: \(notification.soundName ?? "None")")
        NSUserNotificationCenter.default.deliver(notification)
        requestAttention()
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
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return !NSApp.isActive
    }
    
    func userNotificationCenter(_: NSUserNotificationCenter, didDeliver: NSUserNotification) {
        
    }
    
    func userNotificationCenter(_: NSUserNotificationCenter, didActivate: NSUserNotification) {
        
    }
    
    static func getSystemNotificationSounds() -> [(String, String)] {
        // TODO: Include bundle directory.
        // TODO: Extract as class level? SHould it be in separate class/file? Is there any way to get all files from NSSound?
        let defaultSoundsPaths = ["/System/Library/Sounds", "/Library/Sounds", ("~/Library/Sounds" as NSString).expandingTildeInPath as String]
        // TODO: Better file format verification.
        // let supportedExtensions = ["aiff", "wav", "caf"] // Seems to differ from NSSound supported files.

        let fileManager = FileManager.default
        var files = [(String, String)]()
        
        for soundsPath in defaultSoundsPaths {
            let toAdd = try? fileManager.contentsOfDirectory(atPath: soundsPath)
            if let filesToAdd = toAdd {
                // Can absolute path even work? If not, should higher level (closer to user's home and bundle) files mask built-in?
                files.append(contentsOf: filesToAdd.filter{!($0 as NSString).pathExtension.isEmpty }.map{(($0 as NSString).deletingPathExtension, soundsPath)})
                log_all("macos", "Files retrieved from \(soundsPath): \(filesToAdd.count)")
            }
            else {
                log_all("macos", "Error while retrieving files from \(soundsPath).")
            }
        }
        // TODO: Think about better representation.
        return [("\(DefaultSounds.None)", ""), ("\(DefaultSounds.Default)", "")] + files.sorted(by: <)
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        debug("Is active!")
        requestSemaphore.wait()
        let requests = attentionRequests
        attentionRequests = Set()
        requestSemaphore.signal()
        debug("Clearing attention requests: \(requests)")
        for id in requests
        {
            NSApp.cancelUserAttentionRequest(id)
        }
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        debug("Is inactive!")
    }
}
