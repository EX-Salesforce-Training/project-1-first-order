public class ClassAddConfimationPageController {

    public PageReference goBackToClassList(){
        PageReference pageRef = new PageReference('/apex/ClassList');
        pageRef.setRedirect(true);
        return pageRef;
    }
}