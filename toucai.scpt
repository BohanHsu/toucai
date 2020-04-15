-- No license
-- Disclaim: this script has no guarantee of anything

-- Refresh a Safari window, given the window index
-- Index start from 1
-- Do nothing if the given window index doesn't exist
to refreshSafariWindow(windowIdx)
    log "[refreshSafariWindow]"
    log windowIdx
    tell application "Safari"
        try
          tell tab 1 of window windowIdx
              do JavaScript "location.reload();"
          end tell
        on error number -1719
          log "[refreshSafariWindow] No such window"
          -- I found Safari may report closed Privacy window still exist
        end try
    end tell
end refreshSafariTab

-- Return the number of dom element for select Amazon delivery time slot given a Safari window index.
-- CSS selector is `div.ufss-slotselect-container > div.ufss-available`
-- Return the number of dom element in string
to getNoSlotWarningContent(windowIdx)
    tell application "Safari"
        tell tab 1 of window windowIdx
            set jsContent to do JavaScript "document.querySelectorAll('div.ufss-slotselect-container > div.ufss-available').length + '';"
            try 
                set warningContent to jsContent
            on error number -2753
                set warningContent to "nowarning"
            end try
        end tell
    end tell

    return warningContent
end getH4Content

-- Return true iff there are more than zero available slot
to checkHasSlotInWindow(windowIdx)
    set slotCnt to getNoSlotWarningContent(windowIdx)
    set hasSlot to slotCnt is not "0"

    log "[checkHasSlotInWindow]"
    log windowIdx
    log hasSlot 
    
    return hasSlot
end checkHasSlotInWindow

-- Check number of Safari window, I found it may return closed window as available.
to numberOfSafariWindows()
    tell application "Safari"
        set wincount to number of window
    end tell
    return wincount
end numberOfSafariWindows

-- Send a system notification
to notifyAvailableSlot()
    display notification "快去买菜！！！" with title "偷菜" subtitle "" sound name "Ping"
end notifyAvailableSlot


to main()
    set numberOfWindow to numberOfSafariWindows()
    log "[main] number of Safari window"
    log numberOfWindow

    set windowIndex to 1
    set hasAtLeastOneSlot to false

    repeat while hasAtLeastOneSlot = false
        log "[main] Another round of loop"

        set refreshWindowIndex to 1

        repeat while refreshWindowIndex <= numberOfWindow
            refreshSafariWindow(refreshWindowIndex)
            set refreshWindowIndex to refreshWindowIndex + 1
        end repeat

        log "[main] wait 10 seconds for refreshes to finish"
        delay 10
        log "[main] wait 10 finished"

        repeat while windowIndex < numberOfWindow
            set hasSlotInWindow to checkHasSlotInWindow(windowIndex)
            set hasAtLeastOneSlot to (hasAtLeastOneSlot or hasSlotInWindow)
            set windowIndex to windowIndex + 1
        end repeat
        log "[main] hasAtLeastOneSlot"
        log hasAtLeastOneSlot
        
        
        if not hasAtLeastOneSlot then
          delay 10 
        end if
    end repeat

    set alertTimes to 3
    repeat alertTimes times
        notifyAvailableSlot()
        delay 10
    end repeat

    return 0

end main

main()
