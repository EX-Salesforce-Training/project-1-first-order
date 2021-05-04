@isTest
public class ClassListTester {
	
    
    @testSetup
    static void setup(){
        Profile p = [SELECT id FROM profile WHERE name = 'Cleaner'];
        User instructor = new User(LastName = 'user 1', 
                                 Username = 'user.1@sfdc.com', 
                                 Email = 'usersf@gmail.com', 
                                 Alias = 'test', 
                                 Phone = '0000000000',
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = p.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert(instructor);
        Account acc = new Account(Name = 'Test1');
        insert acc;
        
        List<Contact> conList = new List<Contact>();
        // control number of contacts on the account.
        for(Integer i = 0; i < 100; i++){
            Contact con = new Contact(LastName = 'TestPerson '+i, AccountId=acc.Id);
            conList.add(con);
        }
        insert conList;
        
        acc.Primary__c=conList[0].Id;
        update acc;
        
        Time time1 = Time.newInstance(10, 0, 0, 0);
        DateTime dt1 = DateTime.newInstance(Date.today(), time1);
        
        List<Class__c> classList= new List<Class__c>();
        // control number of classes.
        for(Integer i = 0; i <= 40; i++){
            Integer dayOfWeek = math.mod(i,7);
            Class__c cla;
            switch on dayOfWeek{
                when 0 {
                    cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Sunday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);
                }
                when 1 {
                    cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Monday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);
                }
                when 2 {
                    cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Tuesday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);
                }
                when 3 {
                    cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Wednesday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);
                }
                when 4 {
                    cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Thursday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);
                }
                when 5 {
                    cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Friday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);
                }
                when 6 {
					cla = new Class__c(Class_Type__c='Group', Class_Price__c='$75', Class_Time__c=time1, Day__c='Saturday', Start_Date__c=dt1.addDays(i), Instructor__c=instructor.id);                    
                }
            }
            
            classList.add(cla);
        }
        
        insert classList;
        
        
    }
    
    // test if we can add a bunch of ppl into a class
    @isTest
    public static void testPositiveBulk(){
        
        PageReference pageRef = Page.ClassList;
        Test.setCurrentPage(pageRef);
        
        List<Class__c> classList = [SELECT Id, Name, Class_Price__c, Class_Time__c, Class_Type__c, Day__c, Start_Date__c, 
                                                   Instructor__r.Name, Instructor__r.Email, Instructor__r.Phone, Instructor__r.SmallPhotoUrl 
                                                   FROM Class__c
                                                   WHERE Start_Date__c > LAST_N_DAYS:1];
        
        // pass list to controller 
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(classList);
        
        // make an instance of the class extension
        ClassListExtension testPage = new ClassListExtension(ssc);
        
        // test the previous and next button
        // Use a set, and insert the classes into it
        Set<Class__c> classesTest1 = new Set<Class__c>();
        List<Class__c> classesTest2 = new List<Class__c>();
        classesTest1.addAll(testPage.classListUpdated);
        classesTest2.addAll(testPage.classListUpdated);
        
        // go to the next page
        testPage.next();
        // add 20 record from the next page into the set
        classesTest1.addAll(testPage.classListUpdated);
        // go back
        testPage.previous();
		
        // check if the set have all 40 different classes
        System.assertEquals(40, classesTest1.size());
        
        // check if the previous return to the first page by checking all the member from our list
        for(Integer i = 0; i < 20; i++){
            if(classesTest2[i].id != testPage.classListUpdated[i].id){
                System.assert(false);
            }
        }
        
	        
        // check if all the popup getter/setter are working correctly.
        System.assertEquals(null, testPage.classAddPopup);
        testPage.showConfirm();
        System.assertEquals(true, testPage.classAddPopup);
        testPage.closeConfirm();
        System.assertEquals(false, testPage.classAddPopup);
        
        System.assertEquals(null, testPage.accInfoPopup);
        testPage.showAccountInfo();
        System.assertEquals(true, testPage.accInfoPopup);
		testPage.closeAccountInfo();
        System.assertEquals(false, testPage.accInfoPopup);
        
        // check if the primary contact on the account is correct
        Contact contact1 = [SELECT ID, LastName FROM Contact WHERE LastName='TestPerson 0'];
        System.assert(testPage.primaryContact.id == contact1.id);
        
        // set the class that the user want to add
        testPage.theClass = classList[0].id;
        
        
        // here we test to see if we will get contacts that are not added to a class.
        // since we haven't added anyone we should get however many contacts there are in the account
        System.assert(testPage.getContactToAdd().size() == 100);
            
        // Check if our checkorUncheckAll method work
       	testPage.topBox = true;
        testPage.checkOrUncheckAll();
        
        // now go through the contactToAdd and see if they are all checked.
        for(ClassListExtension.AddClassWrapper c: testPage.contactToAdd){
            if(c.selected == false){
                System.assert(false);
            }
            
        }
        
        // call the method saveList, it should add all contact into the same class
        // also keep the new page that was redirected to when saveList is call;
      	PageReference newPage = testPage.saveList();
        
        // First check if on page save, redirect happens correctly.
        System.assertEquals('/apex/ClassAddConfirmationPage', newPage.getUrl());
        
        // get the class roster it should have however many contact we put in the class
        List<Class_Roster__c> testClassRoster = [Select ID, Contact__c, Class__c FROM Class_Roster__c];
        
        // count the number of ppl added
        System.assert(testClassRoster.size() == 100); 
        
        // go to the confirmation screen and try to go back.
        Test.setCurrentPage(newPage);
        
        ClassAddConfimationPageController secondTestPage = new ClassAddConfimationPageController();
        // use the go back function to redirect back to class list page
        newPage = secondTestPage.goBackToClassList();
        
        // check if the return happen
        System.assertEquals('/apex/ClassList', newPage.getUrl());
        
        // go back to the class list page
        Test.setCurrentPage(newPage);
        
        // Instantiate a new testPage
        testPage = new ClassListExtension(ssc);
        
        // set theClass to class[0]
        testPage.theClass = classList[0].id;
        
        // get the contactToAdd while the theClass is on classList[0]
        // we should get back only the people that have not added the class, which at this point is 0
        System.assert(testPage.getContactToAdd().size() == 0);
        
    }
    
    @isTest
    public static void testNegative(){
        // the only thing the user can do is press save when no contact are selected.
        // So I will test if my apexpage.addmessage work.
        PageReference pageRef = Page.ClassList;
        Test.setCurrentPage(pageRef);
        List<Class__c> classList = [SELECT Id, Name, Class_Price__c, Class_Time__c, Class_Type__c, Day__c, Start_Date__c, 
                                                   Instructor__r.Name, Instructor__r.Email, Instructor__r.Phone, Instructor__r.SmallPhotoUrl 
                                                   FROM Class__c
                                                   WHERE Start_Date__c > LAST_N_DAYS:1];
        
        // pass list to controller 
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(classList);
        
        // make an instance of the class extension
        ClassListExtension testPage = new ClassListExtension(ssc);
        
        // user click on add class
        testPage.theClass = classList[0].id;
        
        // then clicking save without ever select any contact
        testPage.saveList();
        
        // apexpages.getmessages return a list of message
        ApexPages.Message[] warningMessages = ApexPages.getMessages();
        // if there is any message
        System.assert(warningMessages.size() != 0);
        
        // check if message is both warning and the summary is what I set
        // otherwise fail the assert.
        for(ApexPages.Message apm: warningMessages){
            if(apm.getSeverity() != ApexPages.Severity.WARNING || apm.getSummary() != 'No contact was selected.'){
                System.assert(false);
            }
        }
    }
    
}