public class EventSchedulerExtension {
    public List<Event> eventList {get; set;}
    public Event filter {get; set;}
    
    public EventSchedulerExtension(ApexPages.StandardSetController controller) {
        
    }
    
    public void FindEvents() {
        eventList = [SELECT subject FROM Event];
    }
}