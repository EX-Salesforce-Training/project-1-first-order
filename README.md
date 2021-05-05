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

## **ClassList**

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

## **ClassAddConfirmationPage**

* Just a popup looking page to send user back to the class list

* Missing Feature
 * Home button just go back to class list rather than the home page

# **Extension**

* Constructor
  * StandardSetController are set
    * Use
