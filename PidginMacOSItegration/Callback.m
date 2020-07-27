//
//  Callback.m
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callback.h"
#import "Log.h"
#import "pidgin/gtkblist.h"


void register_callback_with_data(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *, void*), const char* callback, void* data) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), data);
    log_all("macos", "Registered");
}

void register_callback_to_modify(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *), const char* callback) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), nil);
    log_all("macos", "Registered");
}

void register_callback(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char *, char *, PurpleConversation *, PurpleMessageFlags *), const char* callback) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), nil);
    log_all("macos", "Registered");
}

void register_conversation_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleConversation *, void *), const char* callback, void *data) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), data);
    log_all("macos", "Registered");
}

void register_buddy_list_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleBuddyList *, void *), const char* callback, void *data) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(pidgin_blist_get_handle(), callback, plugin, PURPLE_CALLBACK(function), data);
    log_all("macos", "Registered");
}

void register_switch_page_callback(GtkWidget *notebook, const char* callback, GtkWidget *window, gboolean function (GtkWidget *notebook, GtkNotebookPage *notebook_page, int page, GtkWidget *data)) {
    log_callback("macos", "Registering %s callback for window...\n", callback);
    if(g_signal_connect_after(G_OBJECT(notebook), callback, G_CALLBACK(function), window)) {
        log_all("macos", "Success.");
    }
    else {
        log_all("macos", "Failure.");
    }
}

void register_configuration_event_callback(GtkWidget *window, gboolean function (GtkWidget *widget, GdkEvent  *event, gpointer user_data)) {
    log_all("macos", "Registering configure-event callback for window...");
    if(g_signal_connect_after(G_OBJECT(window), "configure-event", G_CALLBACK(function), NULL)) {
        log_all("macos", "Success.");
    }
    else {
        log_all("macos", "Failure.");
    }
}
