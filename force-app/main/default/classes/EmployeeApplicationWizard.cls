public class EmployeeApplicationWizard {
    public Employee_Application__c wiz {get;set;}
    public String publicKey {get;set;}
    public Boolean verified { get; private set; }
    //Google Secret Key
    private static String secretKey = '6LcXM8IaAAAAAG-FJPdwqrtSPN291e5y72RhSRcJ';
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify';
    
    public EmployeeApplicationWizard(){
        wiz = new Employee_Application__c();
        this.publicKey = '6LcXM8IaAAAAAJKpA9e99o_Un7Pnr9b2k-AHA6j2';//Google Site Key or Public Key
        this.verified = false;
    }
    public PageReference step3(){
        return Page.EmployeeApplicationPage3;
    }
    public PageReference step2() {
        system.debug(wiz);
        return Page.EmployeeApplicationPage2;
    }
    public PageReference step1() {
        return Page.EmployeeApplicationPage1;
    }
    
    public PageReference save() {
        upsert wiz;
        system.debug(wiz);
        PageReference employeeApplicationPage = new PageReference('https://aquatic-alchemy-developer-edition.na156.force.com/s/');
        employeeApplicationPage.setRedirect(true);
        return employeeApplicationPage; 
    }
    public PageReference cancel() {
        PageReference employeeApplicationPage = new PageReference('https://aquatic-alchemy-developer-edition.na156.force.com/s/');
        employeeApplicationPage.setRedirect(true);
        return employeeApplicationPage; 
    }
    
    
    
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('g-recaptcha-response');
        }
    }
    
    // return remote server
    private String remoteHost{
        get {
            String ret = '127.0.0.1';
            //Also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret = hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret = hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    
     
    //Get Google reCAPTCHA Service Response 
    private static HttpResponse getGoogleReCAPTCHAResponse(string requestURL, string body){
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestURL);
        req.setMethod('POST');
        req.setBody (body);
        try{
            Http http = new Http();
            response = http.send(req);
            System.debug('ReCAPTCHA Response-' + response);
            System.debug('ReCAPTCHA Body-' + response.getBody());
        }
        catch(System.Exception ex){
            System.debug('ERROR Message-' + ex.getMessage());
        }
        return response;
    }
}