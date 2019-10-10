import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

String[] poem;

void setup() {
  size(1920, 1080);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);

  PFont wask;
  wask = createFont("wask.ttf", 32);
  textFont(wask);
}


void draw() {
  background(0);  

  // Draw text
  if (poem!=null) {
    // If the poem exists, draw the current poem
    for (int i = 0; i < poem.length; i++) {
      text(poem[i], 100, 100+i*50);
    }
  }
}

void mousePressed() {
  // Simulates a poem message
  poem = new String[]{"decomposing,", "a major leap", "in inattention", "people’s ideas for inventions are constrained", "?¿", " ", "eternal growth - infinite", "eclipsed within itself", "what is innovative anymore"};
  // Print poem to debug
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
