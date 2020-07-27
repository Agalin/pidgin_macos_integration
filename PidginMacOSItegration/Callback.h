//
//  Callback.h
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#ifndef Callback_h
#define Callback_h

#include <gtk/gtk.h>
#include <plugin.h>
#include <account.h>

void register_callback_with_data(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *, void*), const char* callback, void * data);
void register_callback_to_modify(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char **, char **, PurpleConversation *, PurpleMessageFlags *), const char* callback);
void register_callback(PurplePlugin *plugin, gboolean (*function)(PurpleAccount *, char *, char *, PurpleConversation *, PurpleMessageFlags *), const char* callback);
void register_conversation_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleConversation *, void *), const char* callback, void *data);
void register_buddy_list_created_callback(PurplePlugin *plugin, gboolean (*function)(PurpleBuddyList *, void *), const char* callback, void *data);
void register_switch_page_callback(GtkWidget *notebook, const char* callback, GtkWidget *window, gboolean function (GtkWidget *notebook, GtkNotebookPage *notebook_page, int page, GtkWidget *data));
void register_configuration_event_callback(GtkWidget *window, gboolean function (GtkWidget *widget, GdkEvent  *event, gpointer user_data));
void log_callback(const char* category, const char* message, const char* callback);

#endif /* Callback_h */
