public class HarveyChallengeControllerExtension {
    public List<Account> acc {get;set;}
    public Map<ID, List<Contact>> helpermap {get;set;}
    
    public HarveyChallengeControllerExtension(ApexPages.StandardSetController stdController){
        stdController = new ApexPages.StandardSetController([SELECT ID, Name FROM Account]);
        acc = stdController.getRecords();
        List<Contact> contactList = [SELECT ID, accountID, name, Contact.Account.Name FROM contact];
        helpermap = new Map<ID, List<Contact>>();
        for(Account a: acc){
            helpermap.put(a.ID, new List<Contact>());
        }
        for(Contact c: contactList){
            helpermap.get(c.AccountID).add(c);
        }
    }
}