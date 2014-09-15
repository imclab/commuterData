import controlP5.*;
import java.lang.Math;
ControlP5 cp5;

//dropDown variables
DropdownList dropDown;
int currState = 0; //index of dropdown selected state for first viz

//filter variables
Range filter;
int rangeHigh, rangeLow = 0;

//Toggle variables
Toggle dataToggle;
int toggleValue = 0;//0=raw data, 1=percent data

//data variables
Table table;
ArrayList<String> states;
color[] colors = {#5484FF,#0fe85c,#ffe800,#e8804d,#cb0dff,#FF3042};
String[] dataNames = {"Drove Alone", "Car-pooled", "Used Public Transportation", "Walked", "Other", "Worked at home"};


//color arrays of each nested square
//cAlone, cPool, cPublic, cWalk, cOther, cHome
color[][] vis2Colors = new color[][] {{#0B13FF,#5484FF,#5DD5FF}, {#18401D,#0fe85c,#97FFB7}, 
{#8F8200,#ffe800,#FFFAA5}, {#AB5E40,#e8804d,#E8A695}, {#590670,#cb0dff,#EA9EFF}, {#611219,#FF3042,#FFA5AF}};
float[][] columnData;
float[] totalWorkers;

//coordinates of objects
float circleX = 200;
float circleY = 350;
int slidex = 560;
int slidey = 600;
int dropx = 150;
int dropy = 360;
int togglex = 745;
int toggley = 635;
int rawx = 650;
int rawy = 650;
int perx = 815;
int pery = 650;

//vis1, vis2 variables
Arc[] arcShapes = new Arc[6];
Rectangle[] rectShapes = new Rectangle[18];
int rectCount;

//details on demand variables
boolean detailOnDemand = false;
int dodIndex = 0;
int dodIndex2 = 0;
color dodColor = #FFFFFF;

float[] topStatesData = new float[18];
float[] topStatesIndex = new float[18];

void setup(){
  size(1250, 700);
  cp5 = new ControlP5(this);
  
  createTable();
  createDropDown();
  createToggle();
  createFilter();

}

void createFilter() {
  //slider-filtering
  filter = cp5.addRange("filter").setPosition(slidex, slidey).setSize(420,30).setRange(240000, 16000000).setValue(16000000);
  filter.setColorBackground(color(0,0,0));
  filter.setColorActive(color(200, 200, 0));
}

void createTable() {
  table = loadTable("CommuterData.csv", "header");
  states = new ArrayList<String>();
  for (TableRow row : table.rows()) {
    String state_name = row.getString("State");
    states.add(state_name);
  } 

  //arrays to find top values for each data column
  float[] droveAloneData = table.getFloatColumn("Drove Alone");
  float[] carPooledData = table.getFloatColumn("Car-pooled");
  float[] publicData = table.getFloatColumn("Used Public Transportation");
  float[] walkData = table.getFloatColumn("Walked");
  float[] otherData = table.getFloatColumn("Other");
  float[] homeData = table.getFloatColumn("Worked at home");
  totalWorkers = table.getFloatColumn("Total Workers");
  
  columnData = new float[][] {droveAloneData, carPooledData, publicData, walkData, otherData, homeData};
}


void createDropDown() {
  
  //positioning of state dropdown
  dropDown = cp5.addDropdownList("states").setPosition(dropx, dropy);
  dropDown.setItemHeight(20);
  dropDown.setBarHeight(15);
  dropDown.captionLabel().set("States");
  dropDown.captionLabel().style().marginTop = 3;
  dropDown.captionLabel().style().marginLeft = 3;
  dropDown.valueLabel().style().marginTop = 3;
  
  //populate states
  for(int i=0; i<states.size(); i++) {
    dropDown.addItem(states.get(i), i);
  }
  
  //color settings of state dropdown
  dropDown.setColorBackground(color(255,255,255));
  dropDown.setColorActive(color(125,125,125));
  dropDown.setColorLabel(color(0,0,0));

}

void createToggle() {
  dataToggle = cp5.addToggle("data Toggle").setPosition(togglex, toggley).setSize(50,20).setMode(ControlP5.SWITCH);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    if (theEvent.group().name() == "states") {//name of dropdownlist
      currState = (int)theEvent.group().getValue(); 
    }
    else if(theEvent.isController()) {}
  }
}

void draw() {
  background(255);
  rectCount = 0;
  //get toggle values, set labels
  textSize(15.5);
  fill(0);
  text("Commuter Data By State", 80, 80);
  fill(0);
  text("By: Justin Luk * Rebecca Norton", 80, 100);
  text("Raw Value", rawx, rawy);
  fill(0);
  text("Percentage", perx, pery);
  toggleValue = (int)dataToggle.getValue();
  
  //get values from filter
  rangeLow = (int)filter.getLowValue();
  rangeHigh = (int)filter.getHighValue();
  
  findMaxes();
 
  
  //instantiate each visualization
  createVis1();
  createVis2();
  
  for(Rectangle r : rectShapes) {
    r.draw();
  }
  
  for(Arc a : arcShapes) {
    a.draw();
  }
  println();
  
    //linking
  if(detailOnDemand == true && dodIndex2 >= 0) {
    String vis2State = states.get((int)topStatesIndex[dodIndex*3 + dodIndex2]);
    if(states.get(currState).equals(vis2State)) {
      arcShapes[dodIndex].highlight();
    }
  }
  else if(detailOnDemand == true && dodIndex2 < 0) {  
    for(int i = 0; i<3; i++) {
      String vis2State = states.get((int)topStatesIndex[dodIndex*3 + i]);
      if(states.get(currState).equals(vis2State)) {
        rectShapes[dodIndex*3 + i].highlight();
      }
    }
  }
  
  //draw labels for vis2
  //coordinates of first letter of each row
  int rowLabel1x = 485;
  int rowLabel1y = 20;
  int rowLabel2x = 490;
  int rowLabel2y = 335;
  for (int i = 0; i < 3; i++){
    fill(0);
    text(dataNames[i],rowLabel1x,rowLabel1y);
    rowLabel1x += 260;
  }
  for (int i = 3; i < 6; i++){
    text(dataNames[i],rowLabel2x,rowLabel2y);
    fill(0);
    rowLabel2x += 260;
  }
  
  //poke the hole in the donut chart
  fill(255, 255, 255);
  ellipse(circleX, circleY, 125, 125);
  noStroke();
  
  loadPixels();
  if(detailOnDemand == true) {
    String dodValue = "";
    if(dodIndex2 < 0) { //use format for first vis
      dodValue = table.getString(currState, dataNames[dodIndex]);
      fill(0,0,0);
      textSize(18);
      text(dataNames[dodIndex] + ": " + dodValue, mouseX, mouseY);
    }
    else {
      String state = states.get((int)topStatesIndex[dodIndex*3 + dodIndex2]);
      fill(0,0,0);
      textSize(18);
      text(state + ": " + topStatesData[dodIndex*3 + dodIndex2], mouseX, mouseY);
    }
  }
}

void createVis1() {
  //populate donutchart with data from all 6 types of transport
  float[] angles = new float[6];  
  float total = table.getInt(currState, "Total Workers");
  
  for (int i = 0; i < 6; i++){
    float val = table.getInt(currState, dataNames[i]);
    angles[i] = (val/total)*360;
  }
  
  donutChart(300, angles); 
}

void donutChart(int diam, float[] angles) {
  float lastAngle = 0;
  //give arc i for the color index
  for (int i = 0; i < angles.length; i++) {
    arcShapes[i] = new Arc(diam, lastAngle, lastAngle+radians(angles[i]), i);
    lastAngle += radians(angles[i]);
  }
}

//creation of vis2, called once in draw
void createVis2() {
  float[] stData = steralize(topStatesData);
  
  float[] dAlone = {stData[0],stData[1],stData[2]};
  float[] carPool = {stData[3],stData[4],stData[5]};
  float[] usedPublic = {stData[6],stData[7],stData[8]};
  float[] walked = {stData[9],stData[10],stData[11]};
  float[] other = {stData[12],stData[13],stData[14]};
  float[] home = {stData[15],stData[16],stData[17]};

  //first row of squares
  topThree(500,25,dAlone,vis2Colors[0]);
  topThree(760,25,carPool,vis2Colors[1]);
  topThree(1020,25,usedPublic,vis2Colors[2]);
  //second row of squares
  topThree(500,350,walked,vis2Colors[3]);
  topThree(760,350,other,vis2Colors[4]);
  topThree(1020,350,home,vis2Colors[5]);
}

float[] steralize(float[] arr){
  float[] clone = new float[18];
  float min = arr[0];
  for (int i = 1; i < arr.length; i++) {
      if (arr[i] < min) {
          min = arr[i];
      }
  }
  
  float max = arr[0];
  for ( int i = 1; i < arr.length; i++) {
    if ( arr[i] > max) {
      max = arr[i];
    }
  }
  
  for (int i = 0; i < 18; i++){
    clone[i] = (((arr[i]-min)*1.3)/(max-min))+0.2;
  }
  return clone;
}

/*
* Create three nested squares based on input of 3 floats
* 
*/
void topThree(int x, int y, float[] maxes, color[] c) {
  for (int i = 0; i<3; i++){
    Rectangle r = new Rectangle(x,y,maxes[i],c[i]);
    //x -= 70;
    y += 100;
    rectShapes[rectCount] = r;
    rectCount++;  
  }
}

//when finding maxes place it in array based upon filtered constraints
void findMaxes(){
  float max = 0; 
  float maxIndex = 0;
  float oldMax1 = 0;
  float oldMax2 = 0;
  int index = 0;
  float data = 0;
  for(int i=0; i<columnData.length; i++) {
    for(int loop=0; loop<3; loop++) {
      if(loop == 1) { oldMax1 = max; }
      if(loop == 2) { oldMax2 = max; }
      
      max = 0;
      maxIndex = 0;
      for(int j=1; j<columnData[i].length; j++) {
        if(toggleValue == 0) {
          data = columnData[i][j];
        }
        if(toggleValue == 1) {
          data = (columnData[i][j] / totalWorkers[j]) * 100;
        }

        if((data > max) && (data != oldMax1) && (data != oldMax2) && (totalWorkers[j] > rangeLow) && (totalWorkers[j] < rangeHigh)) {
          max = data;
          maxIndex = j;
        }
      }
      topStatesData[index] = max;
      topStatesIndex[index] = maxIndex;
      index++;
    }
  }  
}

void mouseMoved() {
  detailOnDemand = false;
  dodIndex = -1;
  dodIndex2 = -1;
  color c = pixels[mouseY*width + mouseX];
  dodColor = c;
  if(mouseX < 400) { //use vis1 colors
    for(int i = 0; i<colors.length; i++) {
      if(c == colors[i]) {
        detailOnDemand = true;
        dodIndex = i;
      }
    }
  }
  
  else {
    for(int i = 0; i<vis2Colors.length; i++) {
      for(int j = 0; j<3; j++) {
        if(c == vis2Colors[i][j]) {
          detailOnDemand = true;
          dodIndex = i;
          dodIndex2 = j;
        }
      }
    }
  } 
}



//SHAPE CLASSES
class Arc {
  float diam, lastAngle, newAngle;
  int colorIndex, col, strokeColor; 
  Arc(float diam, float lastAngle, float newAngle, int colorIndex) {
  //fill in constructor - make sure to add any necessary parameters
    this.diam = diam;
    this.lastAngle = lastAngle;
    this.newAngle = newAngle;
    this.colorIndex = colorIndex;
    col = colors[colorIndex];
    strokeColor = #FFFFFF;
  }
  
  void highlight() {
    strokeColor = #000000;
    draw();
  }
  
  //draw the arc
  void draw(){
    stroke(strokeColor);
    fill(col); 
    arc(circleX, circleY, diam, diam, lastAngle, newAngle);
  }
}

//rectangle object for vis #2
class Rectangle{
  float pop;
  int x,y,w,h, strokeColor;
  color c;
  //utilize pop paramater to create a proportional square (should be a normalized population value)
  Rectangle(int x, int y, float pop, color c) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.pop = pop;
    strokeColor = #FFFFFF;
  }
  
  void highlight() {
    strokeColor = #000000;
    draw();
  }
  
  void draw(){
    if(strokeColor == #000000) {
      stroke(strokeColor);
      fill(c);
      rect(x,y,pop*65,pop*65,8,8,8,8);
    }
    else {
      noStroke();
      fill(c);
<<<<<<< HEAD
      rect(x,y,pop*65,pop*65,10,10,10,10);
    }
=======
      rect(x,y,pop*65,pop*65,8,8,8,8);
    }

    fill(c);
    rect(x,y,pop*65,pop*65,8,8,8,8);
>>>>>>> e5b7ae6d9c77d6800d2be302f467208026e95e9e
  }
}
