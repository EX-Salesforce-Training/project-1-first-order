public class EmployeeApplicationWizard {
    public Employee_Application__c wiz {get;set;}
    public EmployeeApplicationWizard(){
        wiz = new Employee_Application__c();
    }
    public PageReference step3(){
        return Page.EmployeeApplicationPage3;
    }
    public PageReference step2() {
        return Page.EmployeeApplicationPage2;
    }
    public PageReference step1() {
        return Page.EmployeeApplicationPage1;
    }
    public PageReference save() {
        PageReference employeeApplicationPage = new PageReference('/home/home.jsp');
        upsert wiz;
        employeeApplicationPage.setRedirect(true);
        return employeeApplicationPage; 
    }
    public PageReference cancel() {
        PageReference employeeApplicationPage = new PageReference('/home/home.jsp');
        employeeApplicationPage.setRedirect(true);
        return employeeApplicationPage; 
    }
    
}