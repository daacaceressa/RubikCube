class Event {
  int dim, type, sign;
  float ang;
  boolean isHint;
  String cubeRep;
  
  public Event( int dim, int type, int sign ) {
    this.dim = dim;
    this.type = type;
    this.sign = sign;
    isHint = false;
    ang = 0.0;
    cubeRep = null;
  }
  
  public Event( int dim, int type, int sign, String sb ) {
    this.dim = dim;
    this.type = type;
    this.sign = sign;
    ang = 0.0;
    cubeRep = sb;
  }
  
  public Event getInverseEvent(  ) {
   return new Event( dim, type, -sign );
  }
  
}