-- No license
-- Disclaim: this script has no guarantee of anything

-- Refresh a Safari window, given the window index
-- Index start from 1
-- Do nothing if the given window index doesn't exist
to refreshSafariWindow(windowIdx)
    log "[refreshSafariWindow]"
    log windowIdx
    tell application "Safari"
        set oldURL to URL of tab 1 of window windowIdx
        try
          tell tab 1 of window windowIdx
              do JavaScript "location.reload();"
          end tell
        on error number -1719
          log "[refreshSafariWindow] No such window"
          -- I found Safari may report closed Privacy window still exist
        end try
    end tell

    log "[refreshSafariWindow] wait 8 seconds for refreshes to finish"
    delay 8
    log "[refreshSafariWindow] wait 8 finished"

    tell application "Safari"
        set newURL to URL of tab 1 of window windowIdx
    end tell
    return oldURL = newURL
end refreshSafariWindow

-- Amazon Fresh
-- Return the number of dom element for select Amazon delivery time slot given a Safari window index.
-- CSS selector is `div.ufss-slotselect-container > div.ufss-available`
-- Return the number of dom element in string
to getAmazonNumberOfTimeSlot(windowIdx)
    tell application "Safari"
        set theURL to URL of tab 1 of window windowIdx
        log "[debug]"
        log theURL

        if theURL starts with "https://www.amazon.com" then
            log "[debug] match amazon"
        else
            log "[debug] return 0"
            return "0"
        end if

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
end getAmazonNumberOfTimeSlot

-- Prime Now
-- This is my best guess of how to check Prime now slot
to getPrimeNowInnerFormOfDeliverySlotForm(windowIdx)
    tell application "Safari"
        set theURL to URL of tab 1 of window windowIdx
        log "[debug]"
        log theURL

        if theURL starts with "https://primenow.amazon.com" then
            log "[debug] match primenow"
        else
            log "[debug] return null"
            return "null"
        end if

        tell tab 1 of window windowIdx
            set jsContent to do JavaScript "document.querySelectorAll('#delivery-slot-form > div')[0]?.getAttribute('role') + '' || 'null';"
            log jsContent
            try
                set resultContent to jsContent
            on error number -2753
                set resultContent to "null"
            end try
        end tell
    end tell

    return resultContent
end getPrimeNowInnerFormOfDeliverySlotForm

-- Return true iff there are more than zero available slot
to checkHasSlotInWindow(windowIdx)
    log "[checkHasSlotInWindow]"
    log windowIdx
    set slotCnt to getAmazonNumberOfTimeSlot(windowIdx)
    set hasSlot to slotCnt is not "0"

    log "After check Amazon"
    log hasSlot 

    if not hasSlot then
        set tryPrimeNow to getPrimeNowInnerFormOfDeliverySlotForm(windowIdx)
        set hasSlot to tryPrimeNow is not "null"
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

to notifyURLChange()
    display notification "有网页离开了购物车，请检查" with title "偷菜" subtitle "" sound name "Ping"
end notifyAvailableSlot


to main()
    set numberOfWindow to numberOfSafariWindows()
    log "[main] number of Safari window"
    log numberOfWindow

    set hasAtLeastOneSlot to false

    repeat while hasAtLeastOneSlot = false
        log "[main] Another round of loop"
        set t to (time string of (current date))
        log t


        set refreshWindowIndex to 1

        repeat while refreshWindowIndex <= numberOfWindow
            set urlIsSame to refreshSafariWindow(refreshWindowIndex)
            log "[debug] urlIsSame"
            log urlIsSame

            if not urlIsSame then
                notifyURLChange()
                return 0
            end if

            set hasSlotInWindow to checkHasSlotInWindow(refreshWindowIndex)
            set hasAtLeastOneSlot to hasSlotInWindow
            
            if hasSlotInWindow then
                set alertTimes to 10
                repeat alertTimes times
                    notifyAvailableSlot()
                    delay 10
                end repeat
                
                set t to (time string of (current date))
                log t

                return 0
            end if
            
            set refreshWindowIndex to refreshWindowIndex + 1
        end repeat
        log "[main] wait 10 seconds after check all windows"
        delay 10
        log "[main] wait 10 seconds finish"
    end repeat

    set t to (time string of (current date))
    log t

    return 0

end main

main()
