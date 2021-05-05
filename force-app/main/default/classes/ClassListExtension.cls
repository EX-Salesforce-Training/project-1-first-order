/*
 * extension for ClassList page
 * Handle informations use to populate ClassList page
 * Control popups
 * Override the save method
 * Version 0.1
 */

public class ClassListExtension {
    
    // popup boolean use to hide or show popup
	public boolean accInfoPopup {get;set;}
    public boolean classAddPopup {get;set;}
    
    // check box that will check all other check box in the adding contact to class popup.
    public boolean topBox {get;set;}
    
    // account of current user
    Account currentUserAcc;
    
    // keep a copy of the primary contact to add classes
    public Contact primaryContact {get;set;}
    
    // contacts related to account
    public List<Contact> relatedContacts {get;set;}
    
    // Key:contactId value:Classes information and contact name gotten from the class roster object.
    public Map<ID, List<Class_Roster__c>> classAndAttendee {get;set;}
    
    // list of contact that was checked marked and ready to be add to class
    public List<AddClassWrapper> contactToAdd;
    
    // keep the class that will be pass to the parameter when add class is click.
    public ID theClass {get;set;}
    
    // class list with start date after today
    public List<Class__c> classListUpdated {get;set;}
    
    public ApexPages.StandardSetController controller {get;set;}
    
    // CONSTRUCTOR
    public ClassListExtension(ApexPages.StandardSetController stc){
        
        // getting all the class for now
        controller = stc;
        controller = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name,
                                                   Class_Price__c, Class_Time__c, Class_Type__c, Day__c, Start_Date__c, Adding__c,
                                                   Instructor__r.Name, Instructor__r.Email, Instructor__r.Phone, Instructor__r.SmallPhotoUrl 
                                                   FROM Class__c]));
        
        // set controller to a specific size, it default to 20
        //controller.setPageSize(20);
        
        // use the filter to get rid of class that is not adding.
       	//controller.setFilterId('00B5Y00000IpQGzUAN');
        
        classListUpdated = controller.getRecords();
        // for the select all contact.
		topBox = false;
        
        // query for the current user account
        // currently using ownerId and specific name, need to change later
        Contact currContact;
        try {
            currContact = [SELECT AccountID FROM Contact WHERE firstName =: UserInfo.getFirstName() AND lastName =: UserInfo.getLastName() LIMIT 1];
        }
        catch (Exception e) {
            currContact = [SELECT AccountID FROM Contact LIMIT 1];
        }
        
        currentUserAcc = [SELECT Id, Name, Primary__c, Primary__r.Name, OwnerId FROM Account WHERE Id=:currContact.AccountID Limit 1];
        
        // use the current account to get all the contacts
        relatedContacts = [SELECT Id, Name, AccountID FROM Contact WHERE AccountID=:currentUserAcc.Id];
                
        // populate map with related contacts
        classAndAttendee = new Map<ID, List<Class_Roster__c>>();
        for(Contact c: relatedContacts){
            if(c.Id == currentUserAcc.Primary__c){
                primaryContact = c;
            }
            classAndAttendee.put(c.Id, new List<Class_Roster__c>());
        }
        
        /* populate map with classes belong to those contacts
        for(Class_Roster__c c: [SELECT Id, Contact__r.id, Class__r.id, Class__r.Name, Class__r.Class_Time__c,  Class__r.Class_Type__c,  Class__r.Day__c FROM Class_Roster__c]){
                classAndAttendee.get(c.Contact__r.id).add(c);
        }*/
        
        // populate contacts to addclasswrapper
        contactToAdd = new List<AddClassWrapper>();
        for(Contact c: relatedContacts){
            AddClassWrapper temp = new AddClassWrapper(c);
            contactToAdd.add(temp);
        }
    }   

    // get contactToAdd, but only return names that have yet to add the class
    public List<AddClassWrapper> GetContactToAdd(){
        List<AddClassWrapper> returnList = new List<AddClassWrapper>();
        
        // check if they already in the class
        for(AddClassWrapper a: contactToAdd){
            boolean alreadyInClass = false;
            for(Class_Roster__c c: classAndAttendee.get(a.con.id)){
                if(c.Class__r.Id == theClass){
                    alreadyInClass = true;
                    break;
                }
            }
            if(!alreadyInClass){
                returnList.add(a);
            }
        }
        
        return returnList;
    }
    
    // account info popup screen control.
    public void CloseAccountInfo(){
        accInfoPopup = false;
    }
    public void ShowAccountInfo(){
        accInfoPopup = true;
    }
    
    // class confirmation popup screen control.
    public void CloseConfirm(){
        classAddPopup = false;
        
        // set top box back to false
        topBox = false;
        
        // reset the checkboxes
        for(addClassWrapper c: contactToAdd){
            c.selected = false;
        }
    }
    public void ShowConfirm(){
        classAddPopup = true;
    }
    
    // use to update all checkbox when top most checkbox are checked or unchecked
    public void CheckOrUncheckAll(){
        for(AddClassWrapper c: contactToAdd){
            c.selected = topBox;
        }
    }
    
    // Wrapper for adding multiple contact to a class
    public class AddClassWrapper{
        
        public Contact con {get;set;}
        public boolean selected {get;set;}
        
        public addClassWrapper(Contact c){
            con = c;
            selected = false;
        }
    }
    // overriding previous and next
 	public void Previous() {
 		controller.previous();
        classListUpdated = controller.getRecords();
 	}
 	public void Next() {
 		controller.next();
        classListUpdated = controller.getRecords();
 	}
    
    // Won't be usign the normal save, will use saveList instead.
    // checking if any contact was selected and creating new records in class roster
    public PageReference SaveList(){
        List<Class_Roster__c> classAdd = new List<Class_Roster__c>();
        Integer count = 0;
        
        // populate list with new class roster for those contact that was selected.
        for(addClassWrapper c: contactToAdd){
            
            // if the checkbox is selected then create new record in the Class Roster
            if(c.selected == true){
                Class_Roster__c temp = new Class_Roster__c(Contact__c=c.con.id, Class__c=theClass);
                classAdd.add(temp);
                count++;
            }
        }
        
        // check if the user select any contact before clicking save.
        if(count == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No contact was selected.'));
        	return null;
        }else{
            closeConfirm();
            insert classAdd;
            PageReference pageRef = new PageReference('/apex/ClassAddConfirmationPage');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    // Sorting goes here, where I sort the class list base on the user clicking the top of the page.
}