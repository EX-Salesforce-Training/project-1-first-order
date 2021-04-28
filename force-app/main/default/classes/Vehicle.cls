public abstract class Vehicle {
    public static Integer numberOfV = 0;
    protected Integer speed {get;set;}
    public enum Mode {AIR, WATER, LAND}
    protected Mode vMode {get;set;}
    protected String movement{get;set;}
    protected String stopMethod{get;set;}
    
    public virtual void DoSpecial(){
        system.debug('Do a Barrel Roll!');
    }
    public void resetNOV(){
        numberOfV = 0;
    }
    public abstract void Stop();
    public abstract void Move();
}