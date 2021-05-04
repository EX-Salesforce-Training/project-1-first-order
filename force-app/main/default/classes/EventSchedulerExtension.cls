public class EventSchedulerExtension {
    public List<Event> eventList {get; set;}
    private List<Event> allEvents;
    public Event filter {get; set;}
    public Event newEvent {get; set;}
    public boolean successPopup {get; set;}
    
    public EventSchedulerExtension(ApexPages.StandardSetController controller) {
        successPopup = false;
        filter = new Event();
        newEvent = new Event();
        newEvent.IsPrivate = true;
        
        FindEvents();
        allEvents = eventList;
    }
    
    //Saves the event to the database
    public void Save() {
        if (!IsValidEvent())
            return;
        
        //Insert the event if it's valid
        try {
            Insert newEvent;
            allEvents.add(newEvent);
            successPopup = true;
        } 
        catch(DMLException e) {
            ApexPages.addMessages(e);
        }
    }
    
    //Closes the success popup
    public void Close() {
        successPopup = false;
        
        //Setup for the next event to be entered
        newEvent = new Event();
        newEvent.IsPrivate = true;
    }
    
    //Finds relevant events in the database
    public void FindEvents() {
        if (filter.ActivityDate != null)
            eventList = [SELECT subject, StartDateTime, EndDateTime, IsAllDayEvent FROM Event WHERE ActivityDate =: filter.ActivityDate AND IsPrivate = false];
        else
            eventList = [SELECT subject, StartDateTime, EndDateTime, IsAllDayEvent FROM Event WHERE IsPrivate = true];
    }
    
    //Checks whether an event is valid by checking against the current event list
    public boolean IsValidEvent() {
        
        //A null event is not valid
        if (newEvent == null)
            return false;
        
        DateTime newStart = newEvent.StartDateTime;
        DateTime newEnd = newEvent.EndDateTime;
        
        //Enforce all events to have a start time
        if (newStart == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Event must have a start date.'));
            return false;
        }
        
        //Only all day events can be missing an end time
        if (newEnd == null && !newEvent.IsAllDayEvent) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Partial day events must have an end.'));
            return false;
        }
        
        //An all day event should have an end date equal to the start date
        if (newEvent.IsAllDayEvent) {
            newEvent.EndDateTime = newEvent.StartDateTime;
            newEnd = newStart;
        }
        
        //Ensure start date is after end date
        if (newStart > newEnd) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'End date must be after start date.'));
            return false;
        }
        
        //Ensure event is being scheduled in advance
        DateTime eventCutoff = DateTime.now().addDays(7);
        if (newStart.day() < eventCutoff.day()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Event must be scheduled a week in advance.'));
            return false;            
        }
        
        //Enforce events only occuring for 1 day
        if (newStart.day() != newEnd.day()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Events may only span 1 day.'));
            return false;
        }
        
        //Ensure event time is during hours of operation
        if (newStart.hour() >= 19) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Events must begin an hour before close.'));
            return false;
        }
        
        if (newStart.hour() < 10 || newEnd.hour() >= 20) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Events must take place during business hours.'));
            return false;
        }
        
        for (Event e : allEvents) {
            System.debug(e.EndDateTime.Day());
            //If there's an all day event on the new event day or an event on a new all-day event, throw the errors
            if (e.IsAllDayEvent && (e.StartDateTime.Day() == newStart.day() || e.StartDateTime.Day() == newEnd.day())) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Event conflicts with an all-day event, choose another day.'));
                return false;
            }
            if(newEvent.IsAllDayEvent) {
                if (newStart.day() == e.StartDateTime.day() || newStart.day() == e.EndDateTime.Day()) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An events is already scheduled for this day.'));
                    return false;
                }
            }
            
            //If the start or end times conflict with existing events, catch and report
            boolean invalidStartDate = newStart == e.StartDateTime || (newStart >= e.StartDateTime && newStart <= e.EndDateTime);
            boolean invalidEndDate = newEnd == e.EndDateTime || (newEnd >= e.StartDateTime && newEnd <= e.EndDateTime);
            boolean overlapping = newEnd >= e.EndDateTime && newStart <= e.StartDateTime;
            if (invalidStartDate) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date conflicts with an existing event.'));
                return false;
            }
            if (invalidEndDate) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date conflicts with an existing event.'));
                return false;
            }
            if (overlapping) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Event overlaps existing event.'));
                return false;
            }
        }
        
        //If we have yet to return that means there are no conflicts
        return true;
    }
}