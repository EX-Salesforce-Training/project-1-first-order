/*
 * extension for ClassList page
 * Handle informations use to populate ClassList page
 * Control popups
 * Override the save method
 */

public class ClassListExtension {
    
    // popup boolean use to hide or show popup
	public boolean accInfoPopup {get;set;}
    public boolean classAddPopup {get;set;}
    public boolean signedUpPopup {get;set;}
    
    // account of current user, the primary account
    public Account currentUserAcc;
    
    // keep a copy of the primary contact to add classes
    public Contact primaryContact {get;set;}
    
    // contacts related to account
    public List<Contact> relatedContacts {get;set;}
    
    // Key:contactId value:Classes information and contact name gotten from the class roster object.
    public Map<ID, List<Class_Roster__c>> classAndAttendee {get;set;}
    
    // list of contact that was checked marked and ready to be add to class
    public List<AddClassWrapper> contactToAdd {get;set;}
    
    // keep the class that will be pass to the parameter when add class is click.
    public ID theClass {get;set;}
    
    
    // CONSTRUCTOR
    public ClassListExtension(ApexPages.StandardSetController stc){
        // set the standardsetcontroller up with a query of all the classes
        // and information about the instructor of those classes.
        stc = new ApexPages.StandardSetController([SELECT Id, Name,
                                                   Class_Price__c, Class_Time__c, Class_Type__c, Day__c, Start_Date__c, 
                                                   Instructor__r.Name, Instructor__r.Email, Instructor__r.Phone, Instructor__r.SmallPhotoUrl FROM Class__c]);
        
        // query for the current user account
        // currently using ownerId and specific name, need to change later
        currentUserAcc = [SELECT Id, Name, Primary__c, Primary__r.Name, OwnerId FROM Account WHERE OwnerId=:UserInfo.getUserId() AND Name='Customer Test Account' Limit 1];
        
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
        
        // populate map with classes belong to those contacts
        for(Class_Roster__c c: [SELECT Id, Contact__r.id, Class__r.Name, Class__r.Class_Time__c,  Class__r.Class_Type__c,  Class__r.Day__c FROM Class_Roster__c]){
            classAndAttendee.get(c.Contact__r.id).add(c);
        }
        
        // populate contacts to addclasswrapper
        contactToAdd = new List<AddClassWrapper>();
        for(Contact c: relatedContacts){
            AddClassWrapper temp = new AddClassWrapper(c);
            contactToAdd.add(temp);
        }
    }
    
    // GETTER AND SETTER
    // get the current user account to create new class roster item
    // and view current classes on the account.
    public Account getCurrentUserAcc(){
        return currentUserAcc;
    } 
    
    // get contactToAdd, but only return names that have yet to add the class
    public List<AddClassWrapper> getContactToAdd(){
        List<AddClassWrapper> returnList = new List<AddClassWrapper>();
        
        for(AddClassWrapper a: contactToAdd){
            if(classAndAttendee.get(a.con.id) == null){
                
            }
        }
        return returnList;
    }
    
    // account info popup screen control.
    public void closeAccountInfo(){
        accInfoPopup = false;
    }
    public void showAccountInfo(){
        accInfoPopup = true;
    }
    
    // add class confirmation popup screen control.
    public void closeConfirm(){
        classAddPopup = false;
        // reset the checkboxes
        for(addClassWrapper c: contactToAdd){
            c.selected = false;
        }
    }
    public void showConfirm(){
        classAddPopup = true;
    }
    
    // WRAPPER
    // Wrapper for adding multiple contact to a class
    class AddClassWrapper{
        
        public Contact con {get;set;}
        public boolean selected {get;set;}
        
        public addClassWrapper(Contact c){
            con = c;
            selected = false;
        }
    }
    
    //OVERRIDDING
    //creating new records in class roster
    public void save(){
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
        if(count == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No contact was selected.'));
        }else{
            // to exit the popup of class confirm
            closeConfirm();
            
            insert classAdd;
        }
    }
}