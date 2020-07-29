//
//  Callback.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 28/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation


func registerCallbackFor(_ plugin: UnsafeMutablePointer<PurplePlugin>!, onSignal signal: String, with data: UnsafeMutableRawPointer!,callback: (@convention(c)(UnsafeMutablePointer<PurpleAccount>?, UnsafeMutablePointer<CString>?, UnsafeMutablePointer<CString>?, UnsafeMutablePointer<PurpleConversation>?, UnsafeMutablePointer<PurpleMessageFlags>?, UnsafeMutableRawPointer?) -> gboolean)!)
 {
    log_callback("macos", "Registering callback %s for conversation...\n", signal);
    purple_signal_connect(purple_conversations_get_handle(), signal, plugin, unsafeBitCast(callback, to: PurpleCallback.self), data);
    log_all("macos", "Registered");
}

func registerConversationCreatedCallbackFor(_ plugin: UnsafeMutablePointer<PurplePlugin>!, onSignal signal: String, with data: UnsafeMutableRawPointer!,callback: (@convention(c)(UnsafeMutablePointer<PurpleConversation>?, UnsafeMutableRawPointer?) -> gboolean)!)
 {
    log_callback("macos", "Registering callback %s for conversation...\n", signal);
    purple_signal_connect(purple_conversations_get_handle(), signal, plugin, unsafeBitCast(callback, to: PurpleCallback.self), data);
    log_all("macos", "Registered");
}

func registerBuddyListCreatedCallbackFor(_ plugin: UnsafeMutablePointer<PurplePlugin>!, onSignal signal: String, with data: UnsafeMutableRawPointer!,callback: (@convention(c)(UnsafeMutablePointer<PurpleBuddyList>?, UnsafeMutableRawPointer?) -> gboolean)!)
{
    log_callback("macos", "Registering callback %s for conversation...\n", signal);
    purple_signal_connect(pidgin_blist_get_handle(), signal, plugin,  unsafeBitCast(callback, to: PurpleCallback.self), data);
    log_all("macos", "Registered");
}

func registerSwitchPageCallbackFor(_ notebook: UnsafeMutablePointer<GtkWidget>!,in window: UnsafeMutablePointer<GtkWidget>!, onSignal signal: String, callback: (@convention(c)(UnsafeMutablePointer<GtkWidget>?, OpaquePointer?, Int32, UnsafeMutablePointer<GtkWidget>?) -> gboolean)! )
{
    log_callback("macos", "Registering %s callback for window...\n", signal);
    if(g_signal_connect_data (notebook, signal,  unsafeBitCast(callback, to: GCallback.self), window, nil, G_CONNECT_AFTER) != 0){
        log_all("macos", "Success.");
    }
    else {
        log_all("macos", "Failure.");
    }
}

func registerConfigurationEventCallbackFor(_ window: UnsafeMutablePointer<GtkWidget>!, callback: (@convention(c)(UnsafeMutablePointer<GtkWidget>?, UnsafeMutablePointer<GdkEvent>?, gpointer?) -> gboolean)!)
{
    log_all("macos", "Registering configure-event callback for window...");
    if(g_signal_connect_data(window, "configure-event", unsafeBitCast(callback, to: GCallback.self), nil, nil, G_CONNECT_AFTER) != 0) {
        log_all("macos", "Success.");
    }
    else {
        log_all("macos", "Failure.");
    }
}
