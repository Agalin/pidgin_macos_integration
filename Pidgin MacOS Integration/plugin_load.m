//
//  test.m
//  Pidgin MacOS Integration
//
//  Created by Agalin on 11.08.2018.
//  Copyright © 2018 Agalin. All rights reserved.
//

#import "plugin_load.h"
#import <Foundation/Foundation.h>
#import "Pidgin_MacOS_Integration-Swift.h"

void log_callback(const char* category, const char* message, const char* callback);

static Plugin* instance;
static PurplePlugin* pplugin;

void plugin_load_oc(PurplePlugin *plugin) {
    log_critical("macos", "Load\n");
    instance = [[Plugin alloc]init];
    pplugin = plugin;
    [instance pluginLoadWithPlugin:plugin];
}

void plugin_unload_oc(PurplePlugin *plugin) {
    log_critical("macos", "Unload\n");
    [instance pluginUnloadWithPlugin:plugin];
    instance = nil;
    pplugin = nil;
}

void plugin_init_oc(PurplePlugin *plugin) {
    log_critical("macos", "Init\n");
//    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
}

void register_callback_with_data(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *, void*), const char* callback, void* data) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), data);
    log_all("macos", "Registered\n");
}

void register_callback_to_modify(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *), const char* callback) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), nil);
    log_all("macos", "Registered\n");
}

void register_callback(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char *, char *, PurpleConversation *, PurpleMessageFlags *), const char* callback) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), nil);
    log_all("macos", "Registered\n");
}

void register_conversation_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleConversation *, void *), const char* callback, void *data) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(purple_conversations_get_handle(), callback, plugin, PURPLE_CALLBACK(function), data);
    log_all("macos", "Registered\n");
}

void register_buddy_list_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleBuddyList *, void *), const char* callback, void *data) {
    log_callback("macos", "Registering callback %s for conversation...\n", callback);
    purple_signal_connect(pidgin_blist_get_handle(), callback, plugin, PURPLE_CALLBACK(function), data);
    log_all("macos", "Registered\n");
}

void log_callback(const char* category, const char* message, const char* callback) {
    purple_debug_info(category, message, callback);
}

void log_all(const char* category, const char* message)
{
    purple_debug_info(category, "%s", message);
}

void log_critical(const char* category, const char* message)
{
    purple_debug(PURPLE_DEBUG_FATAL, category, "%s", message);
}

void set_menu(GtkWidget *menu){
    gtkosx_application_set_menu_bar(gtkosx_application_get(), GTK_MENU_SHELL(menu));
}

GtkWindow* to_window(void* obj) {
    return GTK_WINDOW(obj);
}


