//
//  GtkWindow.m
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GtkWindow.h"

GtkWindow* to_window(void* obj) {
    return GTK_WINDOW(obj);
}
