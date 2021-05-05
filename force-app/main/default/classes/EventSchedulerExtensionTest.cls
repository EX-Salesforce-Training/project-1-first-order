@isTest
public class EventSchedulerExtensionTest {
	
    @testSetup
    private static void SetupExtensionTest() {
        Event e1 = new Event();
        e1.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(12, 0, 0, 0));
        e1.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        e1.IsAllDayEvent = true;
        e1.Subject = 'Subject 1';
        e1.IsPrivate = true;
        e1.DurationInMinutes = 60 * 24;
        
        Event e2 = new Event();
        e2.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(12, 0, 0, 0));
        e2.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(14, 0, 0, 0));
        e2.IsAllDayEvent = false;
        e2.Subject = 'Subject 2';
        e2.IsPrivate = true;
        e2.DurationInMinutes = 60 * (e2.EndDateTime.Hour() - e2.StartDateTime.Hour()) + e2.EndDateTime.Minute() - e2.StartDateTime.Minute();
        
        Insert e1;
        Insert e2;
    }
    
    @isTest
    private static void TP_IsValidEvent() {
        Event e = new Event();
        e.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(11), Time.newInstance(10, 0, 0, 0));
        e.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(11), Time.newInstance(16, 0, 0, 0));
        e.IsAllDayEvent = false;
        e.Subject = 'Subject Example';
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime, EndDateTime, IsAllDayEvent FROM Event]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        ext.filter = new Event();
        ext.filter.ActivityDate = DateTime.now().addDays(11).Date();
        ext.FindEvents();
        
        ext.newEvent = e;
        System.assertEquals(true, ext.IsValidEvent());
    }
    
    @isTest
    private static void TN_IsValidEvent() {
		ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime, EndDateTime, IsAllDayEvent FROM Event]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        
        //Begin checking partial day event
        //Check with null event
        ext.newEvent = null;
        System.assertEquals(false, ext.IsValidEvent());
        
        //Check with empty event
		ext.newEvent = new Event();
		System.assertEquals(false, ext.IsValidEvent());
        
        //Check no end time
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(5), Time.newInstance(8, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Check StartTime < EndTime
        ext.newEvent.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(5), Time.newInstance(7, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure scheduled time is in advance
        ext.newEvent.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(22, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event spans only 1 day
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(8), Time.newInstance(21, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event begins an hour before closing
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(21, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event occurs during hours of operation
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(7, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(12, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event doesn't overlap with existing event
        ext.newEvent.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(15, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        ext.newEvent.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 10, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(15, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(11, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Check all-day event
        ext.newEvent = new Event();
        ext.newEvent.IsAllDayEvent = true;
        
        //Ensure no events are on the same day
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
    }
    
    @isTest
    private static void TP_Close() {
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime, EndDateTime, IsAllDayEvent FROM Event]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        ext.successPopup = true;
        ext.Close();
        System.assertEquals(false, ext.successPopup);
    }
    
    @isTest
    private static void TP_Save() {
		Event e2 = new Event();
        e2.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(14), Time.newInstance(12, 0, 0, 0));
        e2.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(14), Time.newInstance(14, 0, 0, 0));
        e2.IsAllDayEvent = false;
        e2.Subject = 'Expected';
        e2.IsPrivate = true;
        e2.DurationInMinutes = 60 * (e2.EndDateTime.Hour() - e2.StartDateTime.Hour()) + e2.EndDateTime.Minute() - e2.StartDateTime.Minute();

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime, EndDateTime, IsAllDayEvent FROM Event]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        
        ext.newEvent = e2;
        ext.Save();
        Event expected = [SELECT id FROM Event WHERE Subject =: 'Expected'];
        
        System.assertEquals(e2.id, expected.id);
		        
    }
    
    @isTest
    private static void TN_Save() {
		Event e2 = new Event();
        e2.EndDateTime = DateTime.newInstance(DateTime.now().Date().addDays(14), Time.newInstance(14, 0, 0, 0));
        e2.IsAllDayEvent = false;
        e2.Subject = 'Expected';
        e2.IsPrivate = true;

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime, EndDateTime, IsAllDayEvent FROM Event]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        
        ext.newEvent = e2;
        ext.Save();
        System.assertEquals(false, ext.successPopup);
        
        ext.newEvent.StartDateTime = DateTime.newInstance(DateTime.now().Date().addDays(14), Time.newInstance(12, 0, 0, 0));
        ext.newEvent.DurationInMinutes = 0;
        ext.Save();
        System.assertEquals(false, ext.successPopup);
    }
}