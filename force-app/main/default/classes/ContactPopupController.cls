public class ContactPopupController {
    public boolean displayPopup {get;set;}
    
    public ContactPopupController(ApexPages.StandardSetController standCon){
        //standCon.setPageSize(10);
    }
    public void closePopup(){
        displayPopup = false;
    }
    
    public void showPopup(){
        displayPopup = true;
    }
   
}