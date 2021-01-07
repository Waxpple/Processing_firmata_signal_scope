import processing.serial.*;
import cc.arduino.*; 


Arduino arduino;  
int potPin = 0;
int Dc_offset_input = 1;
int Dc_offset_output = 3;
int sensorValue;
int dc_offset;
float prevY;
boolean rectOver = false;
int rectX, rectY;      // Position of square button
int rectSize = 100;     // Diameter of rect
color rectColor, baseColor;
color rectHighlight;
color currentColor;
IntList position;
boolean flag;
int temp;
void setup() {
  size(1800, 1024);
  position = new IntList();
  frameRate(30);
  drawStuff();
  rectColor = color(0);
  rectHighlight = color(51);
  baseColor = color(102);
  currentColor = baseColor;
  rectX = 1600;
  rectY = 900;
  flag=false;

  arduino = new Arduino(this, "/dev/cu.usbmodem141401", 57600);
}

void draw() {
  update(mouseX, mouseY);
  sensorValue = 1024-arduino.analogRead(potPin);
  stroke(255);
  if (rectOver) {
    fill(rectHighlight);
  } else {
    fill(rectColor);
  }
  fill(0,255,255);
  rect(rectX, rectY, rectSize*16/9, rectSize);
  fill(255,0,0);
  textSize(24);
  String settext = "Calibrate:"+nf((float)(1023-sensorValue)*5/1023,1,1)+"V";
  text(settext,rectX+5,rectY+50);
  
  //println(sensorValue);  
  stroke(255,0,0);
  strokeWeight(4);
  line((frameCount-1), prevY, frameCount, sensorValue);
  if(prevY<=500 && sensorValue>500){
    stroke(0,0,255);
    drawArrow(frameCount,500,50,90);
    
    position.append(frameCount);
    if(position.size()==2){
      fill(255,255,255);
      rect(750,40,250,100);
      fill(255,0,0);
      String a = "period is "+nf(float(position.get(1)-position.get(0))/30,1,2)+"s";
      println(float(position.get(1)-position.get(0))/30);
      text(a,800,100);
      position.clear();
    }

    stroke(255,0,0);
  }else if (prevY>=500 && sensorValue<500){
    stroke(0,0,255);
    drawArrow(frameCount,500,50,270);
    stroke(255,0,0);
  }



  prevY = sensorValue;
  if(frameCount==1800){
    drawStuff();
    position.clear();
    frameCount=0;
  }
  
}
void drawStuff() {
  background(0);
  for (int i = 0; i <= width; i += 100) {
    fill(0, 255, 0);
    stroke(255);
    line(i, height, i, 0);
    text(i/10, i-10, height-15);
  }
  for (int j = 0; j < height; j += 100) {
    fill(0, 255, 0);
    stroke(255);
    line(0, j, width, j);
    text(float((height-j)*5)/height, 10, j);
  }
}
void drawArrow(int cx, int cy, int len, float angle){
  pushMatrix();
  translate(cx, cy);
  rotate(radians(angle));
  line(0,0,len, 0);
  line(len, 0, len - 8, -8);
  line(len, 0, len - 8, 8);
  popMatrix();
}
void update(int x, int y) {
  if ( overRect(rectX, rectY, rectSize, rectSize) ) {
    rectOver = true;
  } else {
    rectOver = false;
  }
}

void mousePressed() {
  if (rectOver) {
    currentColor = rectColor;
    
    arduino.analogWrite(Dc_offset_output,(sensorValue)/4);
    print("pressed");
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
