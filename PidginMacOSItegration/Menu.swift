//
//  Menu.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 29/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

func setMenu(_ menu: UnsafeMutablePointer<GtkWidget>!) {
    gtkosx_application_set_menu_bar(gtkosx_application_get(), unsafeBitCast(menu, to: UnsafeMutablePointer<GtkMenuShell>?.self));
}
