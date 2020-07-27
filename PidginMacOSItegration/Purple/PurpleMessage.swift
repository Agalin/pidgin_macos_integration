//
//  PurpleEnum.swift
//  PidginMacOSIntegration
//
//  Created by Agalin on 27/07/2020.
//  Copyright © 2020 Agalin. All rights reserved.
//

import Foundation

extension PurpleMessageFlags {
    var containsImages : Bool {
        return self.rawValue & PURPLE_MESSAGE_IMAGES.rawValue > 0
    }
    
    var sentFromRemote : Bool {
        return self.rawValue & PURPLE_MESSAGE_REMOTE_SEND.rawValue > 0
    }
    
    var sent : Bool {
        return self.rawValue & PURPLE_MESSAGE_SEND.rawValue > 0
    }
    
    var received : Bool {
        return self.rawValue & PURPLE_MESSAGE_RECV.rawValue > 0
    }
    var system : Bool {
        return self.rawValue & PURPLE_MESSAGE_SYSTEM.rawValue > 0
    }
    
    var autoResponse : Bool {
        return self.rawValue & PURPLE_MESSAGE_AUTO_RESP.rawValue > 0
    }
    
    var activeOnly : Bool {
        return self.rawValue & PURPLE_MESSAGE_ACTIVE_ONLY.rawValue > 0
    }
    
    var nick : Bool {
        return self.rawValue & PURPLE_MESSAGE_NICK.rawValue > 0
    }
    
    var noLog : Bool {
        return self.rawValue & PURPLE_MESSAGE_NO_LOG.rawValue > 0
    }
    
    var whisper : Bool {
        return self.rawValue & PURPLE_MESSAGE_WHISPER.rawValue > 0
    }
    var error : Bool { return self.rawValue & PURPLE_MESSAGE_ERROR.rawValue > 0 }
    var delayed : Bool { return self.rawValue & PURPLE_MESSAGE_DELAYED.rawValue > 0 }
    var raw : Bool { return self.rawValue & PURPLE_MESSAGE_RAW.rawValue > 0 }
    var notify : Bool { return self.rawValue & PURPLE_MESSAGE_NOTIFY.rawValue > 0 } /**< Message is a notification */
    var noLinkify : Bool { return self.rawValue & PURPLE_MESSAGE_NO_LINKIFY.rawValue > 0 }
    var invisible : Bool { return self.rawValue & PURPLE_MESSAGE_INVISIBLE.rawValue > 0 } /**< Message should not be displayed */
    
    func shouldNotify() -> Bool {
        debug("shouldNotify")
        let toDisplay = (received || system) && !invisible && !sent
        log_all("macos", "Notification should be displayed: \(toDisplay), flags: \(String(self.rawValue, radix: 2))\n")
        return toDisplay
    }
}
