//
//  Menu.m
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"
#import <gtkosxapplication.h>

void set_menu(GtkWidget *menu){
    gtkosx_application_set_menu_bar(gtkosx_application_get(), GTK_MENU_SHELL(menu));
}
