public class Challenge6 extends Vehicle implements Ship{
    public String vehicleName;
    public String vehicleStreetName {get;set;}
    
    public Challenge6(){
        numberOfV++;
        movement= 'Engage propellers';
        stopMethod = 'Drop anchor';
        vMode = Mode.WATER;
    }
    public Challenge6(String vn){
        this();
        vehicleName = vn;
    }
    public Challenge6(String vn, String sn){
        this(vn);
        vehicleStreetName = sn;
    }
    public void reset(){
        super.resetNOV();
    }
    public Integer CurrentNumberOfV(){
        return numberOfV;
    }
    public void GetMode(){
        System.debug(vMode);
    }
    public void AnchorDown(){
        System.debug('Drop the Anchor');
    }
    public void AnchorUp(){
        System.debug('Pull up the Anchor');
    }
    public override void DoSpecial(){
        super.DoSpecial();
        System.debug('Boat sinked because boat can not do a barrel roll... rip');
    }
                     
    public override void Move(){
        System.debug(movement);
    }
    public override void Stop(){
        System.debug(stopMethod);
    }
}