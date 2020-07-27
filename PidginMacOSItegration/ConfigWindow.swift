//
//  GtkTree.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation
import Cocoa

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
