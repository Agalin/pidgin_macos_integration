//
//  main.c
//  Pidgin MacOS Integration
//
//  Created by Agalin on 11.08.2018.
//  Copyright © 2018 Agalin. All rights reserved.
//

#include "main.h"

#define PURPLE_PLUGINS

#include <glib.h>

#include "notify.h"
#include "gtkplugin.h"
#include "plugin.h"
#include "version.h"

#include "plugin_load.h"

extern PurplePluginUiInfo ui_info;

static gboolean
plugin_load(PurplePlugin *plugin) {
    plugin_load_oc(plugin);
    return TRUE;
}

static gboolean plugin_unload(PurplePlugin *plugin) {
    return FALSE;
}

static PurplePluginInfo info = {
    PURPLE_PLUGIN_MAGIC,
    PURPLE_MAJOR_VERSION,
    PURPLE_MINOR_VERSION,
    PURPLE_PLUGIN_STANDARD,
    PIDGIN_PLUGIN_TYPE,
    0,    // flags - PURPLE_PLUGIN_FLAG_INVISIBLE
    NULL, // dependencies - set at runtime!
    PURPLE_PRIORITY_DEFAULT,
    
    "gtk-agalin-macos_integration",
    "MacOS Integration",
    "0.1.1",
    
    "MacOS shell integration for Pidgin",
    "MacOS shell integration for Pidgin. Provides integration with Cocoa through GTK OSX Application module. Adds support for native message notifications, attention requests, moves menu to top menubar as in native app, moves some menu options like preferences or about to standard macOS locations.",
    "Agalin",
    "https://github.com/Agalin/pidgin_macos_integration",
    
    plugin_load,
    plugin_unload,
    NULL, // plugin_destroy
    
    &ui_info, // ui-specific struct - PidginPluginUiInfo
    NULL, // PurplePluginLoaderInfo or PurplePluginProtocolInfo
    NULL, // PurplePluginUiInfo
    NULL, // plugin actions, GList *function_name(PurplePlugin *plugin, gpointer context)
          // It must return a GList of PurplePluginActions.
    NULL, // reserved
    NULL, // reserved
    NULL, // reserved
    NULL  // reserved
};

static void
init_plugin(PurplePlugin *plugin)
{
    plugin_init_oc(plugin);
}

PURPLE_INIT_PLUGIN(macos_test, init_plugin, info)
