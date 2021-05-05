@isTest
public class EventSchedulerExtensionTest {
	
    @testSetup
    private static void SetupExtensionTest() {
        Public_Event__c e1 = new Public_Event__c();
        e1.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(12, 0, 0, 0));
        e1.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(13, 0, 0, 0));
        e1.IsAllDayEvent__c = true;
        e1.Subject__c = 'Birthday Party';
        
        Public_Event__c e2 = new Public_Event__c();
        e2.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(12, 0, 0, 0));
        e2.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(14, 0, 0, 0));
        e2.IsAllDayEvent__c = false;
        e2.Subject__c = 'Private Event';
        
        Insert e1;
        Insert e2;
    }
    
    @isTest
    private static void TP_IsValidEvent() {
        Public_Event__c e = new Public_Event__c();
        e.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(11), Time.newInstance(10, 0, 0, 0));
        e.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(11), Time.newInstance(16, 0, 0, 0));
        e.IsAllDayEvent__c = false;
        e.Subject__c = 'Swim Meet';
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime, EndDateTime, IsAllDayEvent FROM Event]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        ext.filter = new Public_Event__c();
        ext.filter.StartDateTime__c = DateTime.now().addDays(11).Date();
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
		ext.newEvent = new Public_Event__c();
		System.assertEquals(false, ext.IsValidEvent());
        
        //Check no end time
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(5), Time.newInstance(8, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Check StartTime < EndTime
        ext.newEvent.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(5), Time.newInstance(7, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure scheduled time is in advance
        ext.newEvent.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(22, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event spans only 1 day
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(8), Time.newInstance(21, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event begins an hour before closing
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(21, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event occurs during hours of operation
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(7, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(12, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Ensure event doesn't overlap with existing event
        ext.newEvent.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(9), Time.newInstance(15, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        ext.newEvent.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 10, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(15, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(11, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        ext.newEvent.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
        
        //Check all-day event
        ext.newEvent = new Public_Event__c();
        ext.newEvent.IsAllDayEvent__c = true;
        
        //Ensure no events are on the same day
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(13, 0, 0, 0));
        System.assertEquals(false, ext.IsValidEvent());
    }
    
    @isTest
    private static void TP_Close() {
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime__c, EndDateTime__c, IsAllDayEvent__c FROM Public_Event__c]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        ext.successPopup = true;
        ext.Close();
        System.assertEquals(false, ext.successPopup);
    }
    
    @isTest
    private static void TP_Save() {
		Public_Event__c e2 = new Public_Event__c();
        e2.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(14), Time.newInstance(14, 0, 0, 0));
        e2.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(14), Time.newInstance(14, 0, 0, 0));
        e2.IsAllDayEvent__c = false;
        e2.Subject__c = 'Swim Meet';

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime__c, EndDateTime__c, IsAllDayEvent__c FROM Public_Event__c]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        
        ext.newEvent = e2;
        ext.SaveEvent();
        Public_Event__c expected = [SELECT id FROM Public_Event__c WHERE Subject__c =: 'Swim Meet' LIMIT 1];
        
        System.assertEquals(e2.id, expected.id);
		        
    }
    
    @isTest
    private static void TN_Save() {
		Public_Event__c e2 = new Public_Event__c();
        e2.EndDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(14, 0, 0, 0));
        e2.IsAllDayEvent__c = false;
        e2.Subject__c = 'Swim Meet';

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController([SELECT StartDateTime__c, EndDateTime__c, IsAllDayEvent__c FROM Public_Event__c]);
        EventSchedulerExtension ext = new EventSchedulerExtension(ssc);
        
        ext.newEvent = e2;
        ext.SaveEvent();
        System.assertEquals(false, ext.successPopup);
        
        ext.newEvent.StartDateTime__c = DateTime.newInstance(DateTime.now().Date().addDays(10), Time.newInstance(12, 0, 0, 0));
        ext.SaveEvent();
        System.assertEquals(false, ext.successPopup);
    }
}