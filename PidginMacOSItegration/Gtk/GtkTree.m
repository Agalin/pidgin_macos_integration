//
//  GtkTree.m
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GtkTree.h"

char* get_list_value_string(GtkTreeModel* model, GtkTreeIter* iter, gint column) {
    gchar* value = NULL;
    gtk_tree_model_get_value(model, iter, column, value);
    g_free(value);
    gtk_tree_model_get(model, iter, 0, value, -1);
    return value;
}
