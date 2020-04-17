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
end refreshSafariWindow

-- Return the number of dom element for select Amazon delivery time slot given a Safari window index.
-- CSS selector is `div.ufss-slotselect-container > div.ufss-available`
-- Return the number of dom element in string
to getNumberOfTimeSlot(windowIdx)
    tell application "Safari"
        tell tab 1 of window windowIdx
            set jsContent to do JavaScript "document.querySelectorAll('div.ufss-slotselect-container > div.ufss-available').length + '';"
            try 
                set cntContent to jsContent
            on error number -2753
                set cntContent to "nowarning"
            end try
        end tell
    end tell

    return cntContent
end getNumberOfTimeSlot

-- This is my best guess of how to check Prime now slot
to getInnerFormOfDeliverySlotForm(windowIdx)
    tell application "Safari"
        tell tab 1 of window windowIdx
            set jsContent to do JavaScript "document.querySelectorAll('#delivery-slot-form > div')[0]?.getAttribute('role') + '' || 'undefined';"
            try
                set resultContent to jsContent
            on error number -2753
                set resultContent to "undefined"
            end try
        end tell
    end tell

    return resultContent
end getInnerFormOfDeliverySlotForm

-- Return true iff there are more than zero available slot
to checkHasSlotInWindow(windowIdx)
    set slotCnt to getNumberOfTimeSlot(windowIdx)
    set hasSlot to slotCnt is not "0"

    log "[checkHasSlotInWindow]"
    log windowIdx
    log "After check Amazon"
    log hasSlot 

    if not hasSlot then
        set tryPrimeNow to getInnerFormOfDeliverySlotForm(windowIdx)
        set hasSlot to tryPrimeNow is not "undefined"
        log "After check Prime Now"
        log hasSlot
    end if
    
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


        set checkWindowIndex to 1
        repeat while checkWindowIndex <= numberOfWindow
            set hasSlotInWindow to checkHasSlotInWindow(checkWindowIndex)
            set hasAtLeastOneSlot to (hasAtLeastOneSlot or hasSlotInWindow)
            set checkWindowIndex to checkWindowIndex + 1
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

    set t to (time string of (current date))
    log t

    return 0

end main

main()
