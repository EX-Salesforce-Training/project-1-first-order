@isTest
public class TestEmployeeApplication {

    public static testMethod void testMyController() {
        // new controller with all parameters in the page
        EmployeeApplicationWizard controller = new EmployeeApplicationWizard();
        
        
//==========================Test Page Section====================
        Test.setCurrentPage(controller.step1());
        Test.setCurrentPage(controller.step2());
        Test.setCurrentPage(controller.step3());
        

        
        String Pagecancel = controller.cancel().getURL();
        System.assertEquals('https://aquatic-alchemy-developer-edition.na156.force.com/s/', Pagecancel);
        
//========================Test Data Section======================
        controller.wiz.Phone__c = '1234567890';
        controller.wiz.Email__c = 'john@test.com';
        
        String Pagesave = controller.save().getURL();
        System.assertEquals('https://aquatic-alchemy-developer-edition.na156.force.com/s/', Pagesave);
        
        // Verify that the success page displays

        Employee_Application__c[] apps = [select id, Email__c from Employee_Application__c where Email__c = 'john@test.com'];
        system.debug(apps);
        System.assertEquals('john@test.com', apps[0].Email__c);
    }
}