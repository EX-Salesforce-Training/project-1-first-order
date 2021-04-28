public class NewCaseListController {

    public List<Case> getNewCases(){
        return [SELECT ID, CaseNumber FROM Case WHERE Status='New'];
    }
}