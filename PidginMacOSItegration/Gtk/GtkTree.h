//
//  GtkTree.h
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#ifndef GtkTree_h
#define GtkTree_h

#include <gtk/gtk.h>

char* get_list_value_string(GtkTreeModel* model, GtkTreeIter* iter, gint column);

#endif /* GtkTree_h */
