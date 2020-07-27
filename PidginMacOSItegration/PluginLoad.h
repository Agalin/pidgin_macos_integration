//
//  plugin_load.h
//  Pidgin MacOS Integration
//
//  Created by Agalin on 16.08.2018.
//  Copyright © 2018 Agalin. All rights reserved.
//

#ifndef plugin_load_h
#define plugin_load_h

#include <gtk/gtk.h>
#include <glib.h>
#include <plugin.h>
#include <account.h>

void register_callback_with_data(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *, void*), const char* callback, void * data);
void register_callback_to_modify(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *), const char* callback);
void register_callback(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char *, char *, PurpleConversation *, PurpleMessageFlags *), const char* callback);
void register_conversation_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleConversation *, void *), const char* callback, void *data);
void register_buddy_list_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleBuddyList *, void *), const char* callback, void *data);
void register_switch_page_callback(GtkWidget *notebook, const char* callback, GtkWidget *window, gboolean function (GtkWidget *notebook, GtkNotebookPage *notebook_page, int page, GtkWidget *data));
void register_configuration_event_callback(GtkWidget *window, gboolean function (GtkWidget *widget, GdkEvent  *event, gpointer user_data));
void set_menu(GtkWidget *menu);
GtkWindow* to_window(void* obj);

void log_all(const char* category, const char* message);
void log_critical(const char* category, const char* message);

void plugin_load_oc(PurplePlugin *plugin);
void plugin_init_oc(PurplePlugin *plugin);

void (*conv_test(void))(void);
char* get_list_value_string(GtkTreeModel* model, GtkTreeIter* iter, gint column);

struct im_image_data {
    int id;
    GtkTextMark *mark;
};
#endif /* plugin_load_h */
