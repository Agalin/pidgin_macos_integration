//
//  test.m
//  Pidgin MacOS Integration
//
//  Created by Agalin on 11.08.2018.
//  Copyright © 2018 Agalin. All rights reserved.
//

#import "PluginLoad.h"
#import <Foundation/Foundation.h>
#import "PidginMacOSIntegration-Swift.h"
#import "Log.h"

static Plugin* instance;

GtkWidget* get_config_frame(PurplePlugin* plugin) {
    return [Plugin getConfigFrame:plugin];
}

PidginPluginUiInfo ui_info = {
    get_config_frame,
    0,
    
    /* padding */
    NULL,
    NULL,
    NULL,
    NULL
};

void plugin_load_oc(PurplePlugin *plugin) {
    log_critical("macos", "Load\n");
    instance = [[Plugin alloc]init];
    [instance pluginLoadWithPlugin:plugin];
}

void plugin_init_oc(PurplePlugin *plugin) {
    log_critical("macos", "Init\n");
//    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
}
