public class Challenge5 {
	/* 
	 * We have received new requirements that the data in our org needs to meet 
	 * new completeness standards. To facilitate this we are going to use SOQL to 
	 * check our data and handle it by setting a default value for the phone to 
	 * be equal to the related account, and create a task if it is missing an 
	 * email for the record owner to update it.
	 */
	List<Contact> mainQuery = [SELECT name, email, phone, OwnerID, account.phone 
                               FROM Contact 
                               WHERE phone=null or email=null];
    
    public void FixEverything(){
        // task required field subject 
        List<Task> insertTask = new List<Task>();
        List<Contact> updateContact = new List<Contact>();
        for(Contact i: mainQuery){
            if(i.phone== null){
                i.phone = i.account.phone;
                updateContact.add(i);
            }
            if(i.email==null){
                Task newT = new Task();
                newT.subject = 'Need email';
                newT.OwnerId = i.OwnerId;
                newT.WhoId = i.Id;
                insertTask.add(newT);
            }
        }
        insert insertTask;
        update updateContact;
    }
}