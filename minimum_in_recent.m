function minimum = minimum_in_recent(historyClose, dayIndex, time)

minimum = historyClose(dayIndex-time+1);
for day = (dayIndex- time + 2) : (dayIndex-1)
    if historyClose(day) - historyClose(day-1) <= 0
        minimum = historyClose(day);
    else
    end
    
end
end