import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

String[] poem;
boolean fail = false;
float amt;
int startColor, newColor;

void setup() {
  //fullScreen();
  size(1280, 720);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  PFont wask;
  wask = createFont("wask.ttf", 32);
  textFont(wask);

  startColor = color(136, 109, 232);
  newColor = color(0, 0, 0);
  amt = 0;
  background(0);
}


void draw() {
  background(0);  

  // Draw fail animation
  if (fail) {
    background(lerpColor(startColor, newColor, amt));
    amt += 0.01;
    if (amt >= 1) {
      amt = 0.0;
      fail = false;
    }
  }

  // Draw text
  if (poem!=null) {
    int xpos = 0;
    int ypos = 0;
    int lastLine = 0;
    int col = 1;
    for (int i = 0; i < poem.length; i++) {
      if (col==1) {
        xpos = 100;
        ypos = 100+i*40;
        lastLine = i;
        if (ypos>height-100)
          col=2;
      }
      if (col==2) {
        xpos = width/2;
        ypos = 100+(i-lastLine)*40;
      }
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

// Test
void keyPressed() {
  if (key == ENTER)
    fail = true;
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
  if (theOscMessage.checkAddrPattern("/fail")==true) {
    fail = true;
  }
}
