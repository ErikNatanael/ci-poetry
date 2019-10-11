import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

String[] poem;

void setup() {
  fullScreen();
  //size(1024, 720);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  PFont wask;
  wask = createFont("wask.ttf", 38);
  textFont(wask);
}


void draw() {
  background(0);  

  // Draw text
  if (poem!=null) {
    int xpos = 0;
    int ypos = 0;
    int lastLine = 0;
    int col = 1;
    for (int i = 0; i < poem.length; i++) {
      if (col==1) {
        xpos = 100;
        ypos = 100+i*50;
        lastLine = i;
        if (ypos>height-100)
          col=2;
      }
      if (col==2) {
        xpos = width/2;
        ypos = 100+(i-lastLine)*50;
      }

      println(xpos, ypos);
      text(poem[i], xpos, ypos);
    }
  }
}

void mousePressed() {
  // Simulates a poem message
  String[] testPoem = loadStrings("testPoem.txt");
  poem = testPoem;// Print poem to debug
  for (int i = 0; i < poem.length; i++) {
    println(poem[i]);
  }
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());

  if (theOscMessage.checkAddrPattern("/poem")==true) {
    String poemString = theOscMessage.get(0).stringValue();
    //println(poemString);
    String lines[] = poemString.split("\\r?\\n"); // split into lines
    poem = lines;
  }
}
