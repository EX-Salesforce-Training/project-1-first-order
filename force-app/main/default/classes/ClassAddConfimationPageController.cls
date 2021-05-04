/*
 * Controller that does one thing, return to the class list
 * Probably will add button to return to homepage
 */

public class ClassAddConfimationPageController {
	
    // just a function to redirect to ClassList
    public PageReference GoBackToClassList(){
        PageReference pageRef = new PageReference('/apex/ClassList');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // might need another function here to route back to homepage or something.
}