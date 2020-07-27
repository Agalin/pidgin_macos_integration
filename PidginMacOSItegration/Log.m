//
//  Log.m
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <debug.h>
#import "Log.h"

void log_all(const char* category, const char* message)
{
    purple_debug_info(category, "%s\n", message);
}

void log_critical(const char* category, const char* message)
{
    purple_debug(PURPLE_DEBUG_FATAL, category, "%s\n", message);
}

void log_callback(const char* category, const char* message, const char* callback) {
    purple_debug_info(category, message, callback);
}
