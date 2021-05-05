# **CLass List Page**

## **Page Information**

* Visualforce page on Class__c created for customer.

* It display classes and their related information and allow adding those classes.

* Classes can be add to themselves and other contacts on the account.

* Additionally contact and their class information are to available on the page.

## **Components**

* Visualforce Page:
  * ClassList: the main page with all the functionality.
  * ClassAddConfirmationPage: a page that user are redirect to after adding a class.

* Extension:
  * ClassListExtension: handles the main page functionality.
 
* Controller:
  * ClassAddConfimationPageController: only redirect the user back to main page.

____

# **Visualforce Page**

### **ClassList**

* Header
  * Sticky made with inline styling in top div
  * Use slds-grid to put it into place
  * Heading area to the left utilized slds-media to put the icons next to text
  * My Class button to view contacts on the account, and the classes each contact belong to
  * Previous & Next button just can the previous and next function in extension

* Main Content
  * Keep a table of the classes and its information
  * Format of some columns are controlled by the pageBlock, such as Class_Time__C
  * There is a button to add the class to the left

* Footer
  * Just button to go previous and next page

* Popup
  * 2 popups one for the my class button, and the other is for add class button
  * My Class
   * Display primary account holder
   * Display all people on the account and the class they are taking
  * Add Class
   * Display some messages
   * Mid section hold all current contact on the account
   * Check box to add multiple contact to the class at once
   * Top checkbox to select or deslect all other checkbox
   * Warning error at the top of mid section when save is clicked without putting any checkmark

* Missing Feature
   * My Class button gives trouble when putting on customer portal so currently does not display the class of each contacts

### **ClassAddConfirmationPage**

* Just a popup looking page to send user back to the class list

* Missing Feature
  * Home button just go back to class list rather than the home page

# **Extension**

### **ClassListExtension**

* Constructor
   * Query for all classes -> StandardSetController
     * Use setFilterID(List View Filter ID) to specify filter of use on the list
     * use getRecords() to update classListUpdated to actually populate class List with classes
   * Query for Account of the current user, using their userInfo.getUserId() with either their contact ID or Account ID -> currentUserAcc
     * Not sure which ID to use for digital experience, might cause trouble with null access if no Account gotten
   * Query for all related contact on the current user account -> relatedContacts
   * Query for all current class roster item -> classAndAttendee
     * Use classAndAttendee map to populate my class popup
     * The query can probably be optimize with a subquery for only class from the related contacts.
   * Populate class wrapper with all contacts -> contactToAdd
     * a wrapper class that hold a contact, and a boolean for whether or not they should be added to class
     * Use this to know which contact will be added to the class that the user clicked on

* GetContactToAdd
  * Call by the add class button 
  * Return list of contact that have yet to add the current class

* CloseAccountInfo & ShowAccountInfo
  * Call by the my class button
  * Just control whether getter and setter of accInfoPopup to
  * Rerender call on popup, while setting popup to true so that it render the popup

* CloseConfirm & ShowConfirm
  * Call by the add class button
  * Control popup
  * Close confirm also set topBox to false, so the select all checkbox don't start out as true
  * Also reset all contact to add, so that way every new click of add class start fresh

* CheckOrUncheckAll
  * Call by clicking on top checkbox inside add class popup
  * Set all contactToAdd member to false or true, base on the top box

* Previous & Next
  * Call by previous and next button
  * Use controller previous() and next() button to go to the next set of records then set the classListUpdated to that new set
  * Button also rerender the page class list

* SaveList
  * Call by the save button on add class popup
  * Put all the contact in the contactToAdd into a list if their checkbox and marked
  * A count is keep
    * if count is 0 no box were checked, error message instead of adding
    * else we close confirm to get rid of checkbox and insert the class_roster we made
    * redirect off of the page because a refresh after adding will cause a resubmit
   
# **Controller**

### **ClassAddConfirmationPageController**

* Only have one function to redirect back to the class list page

  
