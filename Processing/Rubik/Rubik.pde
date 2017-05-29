import remixlab.proscene.*;
import remixlab.proscene.MouseAgent;
import remixlab.dandelion.core.*;
import remixlab.bias.*;
import remixlab.bias.event.MotionEvent;
import remixlab.bias.event.KeyboardShortcut;
import java.util.LinkedList;
import java.util.Stack;
import java.util.TreeSet;

Scene[] scenes = new Scene[ 4 ];
PGraphics[] pg = new PGraphics[ 4 ];
int[] cubeId = new int[ 27 ];
float cubeSz = 80.0;
double delta = HALF_PI / 20.0;
int isShift = 1;
boolean[] keysPressed = new boolean[ 26 ];
ArrayList<PShape> cubes;
LinkedList<Event> queue = new LinkedList<Event>();
Stack<Event> stack = new Stack<Event>();
TreeSet<String> visited = new TreeSet<String>(); 
int[][] dimension = new int[3][9];
int[][] newPos = new int[3][9];  
int[][][] newColor = new int[3][2][6]; 
int colors[][] = {
                  { 0, 0, 0 },
                  { 255, 255, 255 },
                  { 255, 0, 0 },
                  { 0, 255, 0 },
                  { 0, 0, 255 },
                  { 255, 255, 0 },
                  { 255, 145, 0 }
                 };
//0 - Black
//1 - White
//2 - Red
//3 - Green
//4 - Blue
//5 - Yellow
//6 - Orange

int facesColors[][] = { 
                        { 2, 5, 0, 0, 3, 0 },
                        { 2, 5, 0, 0, 0, 0 },
                        { 2, 5, 0, 0, 0, 4 },
                        { 2, 0, 0, 0, 3, 0 },
                        { 2, 0, 0, 0, 0, 0 },
                        { 2, 0, 0, 0, 0, 4 },
                        { 2, 0, 0, 1, 3, 0 },
                        { 2, 0, 0, 1, 0, 0 },
                        { 2, 0, 0, 1, 0, 4 },
                        
                        { 0, 5, 0, 0, 3, 0 },
                        { 0, 5, 0, 0, 0, 0 },
                        { 0, 5, 0, 0, 0, 4 },
                        { 0, 0, 0, 0, 3, 0 },
                        { 0, 0, 0, 0, 0, 0 },
                        { 0, 0, 0, 0, 0, 4 },
                        { 0, 0, 0, 1, 3, 0 },
                        { 0, 0, 0, 1, 0, 0 },
                        { 0, 0, 0, 1, 0, 4 },
                        
                        { 0, 5, 6, 0, 3, 0 },
                        { 0, 5, 6, 0, 0, 0 },
                        { 0, 5, 6, 0, 0, 4 },
                        { 0, 0, 6, 0, 3, 0 },
                        { 0, 0, 6, 0, 0, 0 },
                        { 0, 0, 6, 0, 0, 4 },
                        { 0, 0, 6, 1, 3, 0 },
                        { 0, 0, 6, 1, 0, 0 },
                        { 0, 0, 6, 1, 0, 4 },
                      };

void setup(){
  size( 600, 600, P3D );
  pg[ 0 ] = createGraphics( 300, 300, P3D );
  scenes[ 0 ] = new Scene( this, pg[ 0 ] );
  scenes[ 0 ].removeBindings();
  scenes[ 0 ].setGridVisualHint( false );
  
  
  for( int i = 1; i <= 3; ++i ){
    pg[ i ] = createGraphics( 300,300, P3D );
    scenes[ i ] = new Scene( this, pg[ i ], (i % 2 == 0) ? 0 : 300, (i < 2) ? 0 : 300 );
    scenes[ i ].setRadius( 100 );
    scenes[ i ].showAll();
    scenes[ i ].removeBindings();
    scenes[ i ].setGridVisualHint( false );
    scenes[ i ].setAxesVisualHint( true );
  }
  
  
  setBindings();
  
  for( int i = 0; i < 27; ++i )
    cubeId[ i ] = i;
    
  visited.add( getCubeIdRepresentation() );
  
  
  dimension[ 0 ] = new int[]{ 0, 3, 6, 9, 12, 15, 18, 21, 24 }; //X
  dimension[ 1 ] = new int[]{ 0, 1, 2, 9, 10, 11, 18, 19, 20 }; //Y
  dimension[ 2 ] = new int[]{ 0, 1, 2, 3, 4, 5, 6, 7, 8 }; //Z
  newPos[ 0 ] = new int[]{ 18, 9, 0, 21, 12, 3, 24, 15, 6 }; //X
  newPos[ 1 ] = new int[]{ 18, 9, 0, 19, 10, 1, 20, 11, 2 }; //Y
  newPos[ 2 ] = new int[]{ 2, 5, 8, 1, 4, 7, 0, 3, 6 }; //Z
  newColor[ 0 ][ 1 ] = new int[]{ 1, 2, 3, 0, 4, 5 }; //X horario
  newColor[ 1 ][ 1 ] = new int[]{ 4, 1, 5, 3, 2, 0 }; //Y horario
  newColor[ 2 ][ 1 ] = new int[]{ 0, 5, 2, 4, 1, 3 }; //Z horario
  newColor[ 0 ][ 0 ] = new int[]{ 3, 0, 1, 2, 4, 5 }; //X anti-horario
  newColor[ 1 ][ 0 ] = new int[]{ 5, 1, 4, 3, 0, 2 }; //Y anti-horario
  newColor[ 2 ][ 0 ] = new int[]{ 0, 4, 2, 5, 3, 1 }; //Z anti-horario
  
  for( int i = 1; i <= 3; ++i )
    scenes[ i ].loadConfig("data/config" + i + ".json");
}

boolean rotateFlag = false;
void draw(){
  checkKeys();
  
  int[] backgroundColor = { 220, 150 };
  for( int i = 0; i <= 3; ++i ){
    scenes[ i ].beginDraw();
    pg[ i ].background( backgroundColor[ (i == 0 || i == 3) ? 0 : 1  ] );
    drawScene( pg[ i ] );
    scenes[ i ].endDraw();
    scenes[ i ].display(); 
  }
 
}

void drawScene( PGraphics pg ) {
  if( !queue.isEmpty() ) {
    if( queue.peek().ang >= HALF_PI ) {
      Event cur = queue.remove();
      changeColor( cur );  
      drawStaticCube( pg ); 
    }
    else {
      queue.peek().ang += delta;
      drawMovingCube( pg, queue.peek() );
    }
  }
  else {
    delta = HALF_PI / 20.0;
    drawStaticCube( pg );
  }
}

void removeBindings() {
  for( int i = 0; i <= 3; ++i ){
    scenes[ i ].removeKeyBinding( 'a' );
    scenes[ i ].removeKeyBinding( 'e' );
    scenes[ i ].removeKeyBinding( 'h' );
    scenes[ i ].removeKeyBinding( 'c' );
    scenes[ i ].removeKeyBinding( 's' );
    scenes[ i ].removeKeyBinding( 'S' );
    scenes[ i ].eyeFrame().removeMotionBinding( RIGHT );
  }
}

void drawCube( PGraphics pg, int[] idCol ){
  float d = cubeSz/6.0;
  pg.beginShape(QUADS);
    pg.fill( colors[ idCol[ 0 ] ][ 0 ], colors[ idCol[ 0 ] ][ 1 ], colors[ idCol[ 0 ] ][ 2 ] );
    //front
    pg.vertex( d, -d, d );
    pg.vertex( d, d, d );
    pg.vertex( -d, +d, d );
    pg.vertex( -d, -d, d );
    
    pg.fill( colors[ idCol[ 1 ] ][ 0 ], colors[ idCol[ 1 ] ][ 1 ], colors[ idCol[ 1 ] ][ 2 ] );
    //bottom
    pg.vertex( d, d, d );
    pg.vertex( d, d, -d );
    pg.vertex( -d, d, -d );
    pg.vertex( -d, d, d );

    pg.fill( colors[ idCol[ 2 ] ][ 0 ], colors[ idCol[ 2 ] ][ 1 ], colors[ idCol[ 2 ] ][ 2 ] );
    //back
    pg.vertex( d, -d, -d );
    pg.vertex( d, d, -d );
    pg.vertex( -d, +d, -d );
    pg.vertex( -d, -d, -d );
    
    pg.fill( colors[ idCol[ 3 ] ][ 0 ], colors[ idCol[ 3 ] ][ 1 ], colors[ idCol[ 3 ] ][ 2 ] );
    //top
    pg.vertex( d, -d, d );
    pg.vertex( d, -d, -d );
    pg.vertex( -d, -d, -d );
    pg.vertex( -d, -d, d );
    
    pg.fill( colors[ idCol[ 4 ] ][ 0 ], colors[ idCol[ 4 ] ][ 1 ], colors[ idCol[ 4 ] ][ 2 ] );
    //left
    pg.vertex( -d, -d, d );
    pg.vertex( -d, d, d );
    pg.vertex( -d, d, -d );
    pg.vertex( -d, -d, -d );
    
    pg.fill( colors[ idCol[ 5 ] ][ 0 ], colors[ idCol[ 5 ] ][ 1 ], colors[ idCol[ 5 ] ][ 2 ] );
    //right
    pg.vertex( d, -d, d );
    pg.vertex( d, d, d );
    pg.vertex( d, d, -d );
    pg.vertex( d, -d, -d );
  pg.endShape();
}

/*d = x,y,z
  dimension = Indice en cubeId de los cubos que se van a mover (9)                     
  newPos = Para la posicion i-esima el indice de lo tengo que copiar ahi de cubeId (9) 
  dimension[ 2 ] = new int[]{ 0, 1, 2, 3, 4, 5, 6, 7, 8 }; //Z
  newPos[ 2 ] =    new int[]{ 2, 5, 8, 1, 4, 7, 0, 3, 6 }; //Z
                              cubeId[ 0 ] = cubeId[ 2 ]
                              cubeId[ 1 ] = cubeId[ 5 ]
                              cubeId[ dimension[i] ] = cubeId[ newPos[i] ]
  newColor = El id de lo que va a quedar en la posicion i-esima                           
  newColor[ 2 ] = new int[]{ 0, 5, 2, 4, 1, 3  }; //Z
  Esto se tiene que hacer para cada uno de los cubos que vamos a mover
  
*/
//d es la dimension x,y,z
//t es cual de los 3 grupos vamos a mover
void changeColor( Event e ) {
  int d = e.dim;
  int t = e.type;
  int s = max( e.sign, 0 );
  int[] aux = new int[ 9 ];
  if( d == 1 )
    t *= 3;
  else if( d == 2 )
    t *= 9;
  if( s == 1 ) {
    for( int i = 0; i < 9; i++ )
      aux[ i ] = cubeId[ newPos[d][i] + t ];
  }
  else {
    for( int i = 0; i < 9; i++ )
      aux[ 8-i ] = cubeId[ newPos[d][i] + t ];
  }
  for( int i = 0; i < 9; i++ )
      cubeId[ dimension[d][i] + t ] = aux[ i ];
    
  for( int i = 0; i < 9; i++ ) {
    for( int j = 0; j < 6; j++ )
      aux[ j ] = facesColors[ cubeId[ dimension[d][i] + t ] ][ newColor[d][s][j] ];
    for( int j = 0; j < 6; j++ )
      facesColors[ cubeId[ dimension[d][i] + t ] ][ j ] = aux[ j ];
  }
  
  if( !e.isHint ){
    String curCubeId = getCubeIdRepresentation();
    Event inv = e.getInverseEvent();
    inv.cubeRep = curCubeId;
    if( !visited.contains( curCubeId ) ){
      inv.isHint = true;
      stack.push( inv );
      visited.add( curCubeId );
    }
    else{
      while( !stack.isEmpty() && !stack.peek().cubeRep.equals( curCubeId ) )
        visited.remove( stack.pop().cubeRep );
    }
  }
  /*println( "Tree:" );
  for( String str: visited ){
    println( "\t" + str );
  }
  println( "Stack size:" + stack.size() );*/
}

void checkKeys() {
  if( keysPressed['Q'-'A'] ) {
    queue.add( new Event( 0, 0, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['Q'-'A'] = false;
  }
  else if( keysPressed['W'-'A'] ) {
    queue.add( new Event( 0, 1, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['W'-'A'] = false;
  }
  else if( keysPressed['E'-'A'] ) {
    queue.add( new Event( 0, 2, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['E'-'A'] = false;
  }
  else if( keysPressed['A'-'A'] ) {
    queue.add( new Event( 1, 0, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['A'-'A'] = false;
  }
  else if( keysPressed['S'-'A'] ) {
    queue.add( new Event( 1, 1, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['S'-'A'] = false;
  }
  else if( keysPressed['D'-'A'] ) {
    queue.add( new Event( 1, 2, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['D'-'A'] = false;
  }
  else if( keysPressed['Z'-'A'] ) {
    queue.add( new Event( 2, 0, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['Z'-'A'] = false;
  }
  else if( keysPressed['X'-'A'] ) {
    queue.add( new Event( 2, 1, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['X'-'A'] = false;
  }
  else if( keysPressed['C'-'A'] ) {
    queue.add( new Event( 2, 2, isShift ) );
    //stack.push( queue.getLast().getInverseEvent() );
    keysPressed['C'-'A'] = false;
  }
  else if( keysPressed['M'-'A'] ) {
    mix();
    keysPressed['M'-'A'] = false;
  }
  else if( keysPressed['H'-'A'] ) {
    if( !stack.isEmpty() )
      getHint();
    keysPressed['H'-'A'] = false;
  }
  else if( keysPressed['P'-'A'] ) {
    solve();
    keysPressed['P'-'A'] = false;
  }
}

void drawStaticCube( PGraphics pg ) {
  //pg.background( 100 );
  pg.pushMatrix();
  pg.translate( -cubeSz/3.0, cubeSz/3.0, cubeSz/3.0 );
 
  for( int i = 0; i < 27; ++i ){
    drawCube( pg, facesColors[ cubeId[i]  ]  );
    if( (i+1) % 3 == 0 ){
      pg.translate( -2*cubeSz/3.0, 0 );
      if( (i+1) % 9 == 0 ){
        pg.translate( 0, 2*cubeSz/3.0 );
        pg.translate( 0, 0, -cubeSz/3.0 );
      }
      else pg.translate( 0, -cubeSz/3.0 );
    }
    else pg.translate( cubeSz/3.0, 0 );
  }
  pg.popMatrix();
}

void drawMovingCube( PGraphics pg, Event curE ){
  //pg.background( 100 );
  pg.pushMatrix();
  if( curE.dim == 0 )
    pg.rotateX( curE.sign*curE.ang );
  if( curE.dim == 1 )
    pg.rotateY( curE.sign*curE.ang );
  if( curE.dim == 2 )
    pg.rotateZ( curE.sign*curE.ang );
    
  pg.translate( -cubeSz/3.0, cubeSz/3.0, cubeSz/3.0 );
  for( int i = 0; i < 27; ++i ){
    if( check( curE.dim, curE.type, i ) )
      drawCube( pg, facesColors[ cubeId[i]  ] );
    if( (i+1) % 3 == 0 ){
      pg.translate( -2*cubeSz/3.0, 0 );
      if( (i+1) % 9 == 0 ){
        pg.translate( 0, 2*cubeSz/3.0 );
        pg.translate( 0, 0, -cubeSz/3.0 );
      }
      else pg.translate( 0, -cubeSz/3.0 );
    }
    else pg.translate( cubeSz/3.0, 0 );
  }
  pg.popMatrix();
  
  pg.pushMatrix();
  pg.translate( -cubeSz/3.0, cubeSz/3.0, cubeSz/3.0 );
  for( int i = 0; i < 27; ++i ){
    if( !check( curE.dim, curE.type, i ) )
      drawCube( pg, facesColors[ cubeId[i]  ] );
    if( (i+1) % 3 == 0 ){
      pg.translate( -2*cubeSz/3.0, 0 );
      if( (i+1) % 9 == 0 ){
        pg.translate( 0, 2*cubeSz/3.0 );
        pg.translate( 0, 0, -cubeSz/3.0 );
      }
      else pg.translate( 0, -cubeSz/3.0 );
    }
    else pg.translate( cubeSz/3.0, 0 );
  }
  pg.popMatrix();
}

boolean check( int dim, int type, int idx ) {  
  if( dim == 0 ) 
    return idx%3 == type;
  else if( dim == 1 ) 
    return type*3 <= idx%9 && idx%9 <= type*3+2;
  else  
    return type*9 <= idx && idx <= type*9+8;
}

void mix() {
  delta = HALF_PI / 10.0;
  for( int i = 0; i < 30; ++i ) {
    queue.add( new Event( int(random(3)), int(random(3)), random(1)>= 0.5 ? 1 : -1 ) );
    //stack.push( queue.getLast().getInverseEvent() );
  }
}

void getHint() {
  visited.remove( stack.peek().cubeRep );
  queue.add( stack.pop() );
}

void solve() {
  delta = HALF_PI / 10.0;
  while( !stack.isEmpty() )
    getHint();
}

String getCubeIdRepresentation(){
  StringBuilder ans = new StringBuilder( "" );
  for( int i = 0; i < 27; ++i )
    ans.append( (char)(cubeId[ i ] + 'a') );
  return ans.toString();
}

void keyReleased() {
  if( keyCode == SHIFT )
    isShift = 1;
}

void keyPressed() {
  if( char(keyCode) == 'B' ){
    println( "pos: " + scenes[ 3 ].eyeFrame().position() );
    println( "ori: " + scenes[ 3 ].eyeFrame().orientation() );
  }
  /*if( char(keyCode) == 'G' ){
    for( int i = 1; i <= 3; ++i )
      scenes[ i ].saveConfig("data/config" + i + ".json");
    println( "Guardo" );
  }*/
  if( char(keyCode) == 'R' ){
    for( int i = 0; i <= 3; ++i ){
      //scenes[ i ].setAxesVisualHint( true );
      //scenes[ i ].setRadius( 100 );
      scenes[ i ].eyeFrame().removeBindings( );
      scenes[ i ].eyeFrame().setMotionBinding( MouseAgent.LEFT_ID, "rotate" );
    }
    println( "Rotacion General" );
  }
  if( char(keyCode) == 'T' ){
    for( int i = 0; i <= 3; ++i ){
      scenes[ i ].eyeFrame().removeBindings( );
      scenes[ i ].eyeFrame().setMotionBinding( MouseAgent.LEFT_ID, "rotateX" );
    }
    println( "Rotacion X" );
  }
  if( char(keyCode) == 'Y' ){
    for( int i = 0; i <= 3; ++i ){
      scenes[ i ].eyeFrame().removeBindings( );
      scenes[ i ].eyeFrame().setMotionBinding( MouseAgent.LEFT_ID, "rotateY" );
    }
    println( "Rotacion Y" );
  }
  if( char(keyCode) == 'U' ){
    for( int i = 0; i <= 3; ++i ){
      scenes[ i ].eyeFrame().removeBindings( );
      scenes[ i ].eyeFrame().setMotionBinding( MouseAgent.LEFT_ID, "rotateZ" );
    }
    println( "Rotacion Z" );
  }
  if( keyCode == SHIFT ) 
    isShift = -1;
  else if( 'A' <= char(keyCode) && char(keyCode) <= 'Z' )
    keysPressed[ char(keyCode)-'A' ] = true;
}


//Funciones para configurar guardado de frames
public void setBindings(){
  
  for( int i = 0; i <= 3; ++i ){
    scenes[ i ].eyeFrame().removeBindings( );
    scenes[ i ].eyeFrame().setMotionBinding( MouseAgent.LEFT_ID, "rotate" );
  }
  
  for( int i = 0; i <= 3; ++i ){
    
    for( char num = '0'; num <= '9'; ++num ){
      //scenes[ i ].setKeyBinding(BogusEvent.SHIFT, num, "addKeyFrameToPath" + num);
      //scenes[ i ].setKeyBinding(BogusEvent.ALT, num, "deletePath" + num);
      scenes[ i ].setKeyBinding(num, "playPath" + num);
    }
    
    char ch1 = '-';
    char ch2 = '=';
    //scenes[ i ].setKeyBinding(BogusEvent.SHIFT, ch1, "addKeyFrameToPath10" );
    //scenes[ i ].setKeyBinding(BogusEvent.ALT, ch1, "deletePath10");
    scenes[ i ].setKeyBinding(ch1, "playPath10" );
    
    //scenes[ i ].setKeyBinding(BogusEvent.SHIFT, ch2, "addKeyFrameToPath11" );
    //scenes[ i ].setKeyBinding(BogusEvent.ALT, ch2, "deletePath11");
    scenes[ i ].setKeyBinding(ch2, "playPath11" );
  }
}

public void addKeyFrameToPath0(Scene scn) {
  scn.eye().addKeyFrameToPath(0);
}

public void addKeyFrameToPath1(Scene scn) {
  scn.eye().addKeyFrameToPath(1);
}

public void addKeyFrameToPath2(Scene scn) {
  scn.eye().addKeyFrameToPath(2);
}

public void addKeyFrameToPath3(Scene scn) {
  scn.eye().addKeyFrameToPath(3);
}

public void addKeyFrameToPath4(Scene scn) {
  scn.eye().addKeyFrameToPath(4);
}

public void addKeyFrameToPath5(Scene scn) {
  scn.eye().addKeyFrameToPath(5);
}

public void addKeyFrameToPath6(Scene scn) {
  scn.eye().addKeyFrameToPath(6);
}

public void addKeyFrameToPath7(Scene scn) {
  scn.eye().addKeyFrameToPath(7);
}

public void addKeyFrameToPath8(Scene scn) {
  scn.eye().addKeyFrameToPath(8);
}

public void addKeyFrameToPath9(Scene scn) {
  scn.eye().addKeyFrameToPath(9);
}

public void addKeyFrameToPath10(Scene scn) {
  scn.eye().addKeyFrameToPath(10);
}

public void addKeyFrameToPath11(Scene scn) {
  scn.eye().addKeyFrameToPath(11);
}

public void deletePath0(Scene scn) {
   scn.eye().deletePath(0);
}

public void deletePath1(Scene scn) {
   scn.eye().deletePath(1);
}

public void deletePath2(Scene scn) {
   scn.eye().deletePath(2);
}

public void deletePath3(Scene scn) {
   scn.eye().deletePath(3);
}

public void deletePath4(Scene scn) {
   scn.eye().deletePath(4);
}

public void deletePath5(Scene scn) {
   scn.eye().deletePath(5);
}

public void deletePath6(Scene scn) {
   scn.eye().deletePath(6);
}

public void deletePath7(Scene scn) {
   scn.eye().deletePath(7);
}

public void deletePath8(Scene scn) {
   scn.eye().deletePath(8);
}

public void deletePath9(Scene scn) {
   scn.eye().deletePath(9);
}

public void deletePath10(Scene scn) {
   scn.eye().deletePath(10);
}

public void deletePath11(Scene scn) {
   scn.eye().deletePath(11);
}

public void playPath0(Scene scn) {
  scn.eye().playPath(0);
}

public void playPath1(Scene scn) {
  scn.eye().playPath(1);
}

public void playPath2(Scene scn) {
  scn.eye().playPath(2);
}

public void playPath3(Scene scn) {
  scn.eye().playPath(3);
}

public void playPath4(Scene scn) {
  scn.eye().playPath(4);
}

public void playPath5(Scene scn) {
  scn.eye().playPath(5);
}

public void playPath6(Scene scn) {
  scn.eye().playPath(6);
}

public void playPath7(Scene scn) {
  scn.eye().playPath(7);
}

public void playPath8(Scene scn) {
  scn.eye().playPath(8);
}

public void playPath9(Scene scn) {
  scn.eye().playPath(9);
}

public void playPath10(Scene scn) {
  scn.eye().playPath(10);
}

public void playPath11(Scene scn) {
  scn.eye().playPath(11);
}