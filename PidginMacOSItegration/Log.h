//
//  Log.h
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

#ifndef Log_h
#define Log_h

void log_all(const char* category, const char* message);
void log_critical(const char* category, const char* message);
void log_callback(const char* category, const char* message, const char* callback);

#endif /* Log_h */
