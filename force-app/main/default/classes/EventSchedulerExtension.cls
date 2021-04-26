public class EventSchedulerExtension {
    public List<Event> eventList {get; set;}
    public Event filter {get; set;}
    
    public EventSchedulerExtension(ApexPages.StandardSetController controller) {
        filter = new Event();
    }
    
    public void FindEvents() {
        if (filter.ActivityDate != null)
        	eventList = [SELECT subject FROM Event WHERE ActivityDate =: filter.ActivityDate];
        else
            eventList = [SELECT subject FROM Event];
    }
}