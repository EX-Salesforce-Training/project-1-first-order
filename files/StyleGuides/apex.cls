/*--------------------------------------------------------
 * Title: Apex Style Guide and Account Extender
 * Usage: provides functionality for the visualforce style guide page
 * Authors: Jared Longnecker
 */

public class AccountExtension {
    
    //Properties go at the top of the class
    public List<Account> accList {get; set;}
    public Account display {get; set;}
    public boolean popupVisible {get; set;}

    //Helper class variables go after the properties
    private integer count = 0;

    public AccountExtension(ApexPages.StandardSetController ssc) {
        accList = [SELECT name FROM Account];
        display = accList.get(count);
        popupVisible = false;
    }

    //Page actions go at the top of the class
    //All methods should have a comment detailing its function

    //Displays the next account in the list
    public void Next() {
        IncrementCount();
        display = accList.get(count);
    }
    
    //Inverts the visibility of the popup
    public void AlternatePopup() {
        popupVisible = !popupVisible;
    }
    
    //Increments count and ensures it stays within the bounds of the list
    public void IncrementCount() {
        count++;
        count = Math.mod(count, accList.size());
    }
}