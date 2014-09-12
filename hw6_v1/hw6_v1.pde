import controlP5.*;
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


//coordinate center of donut chart, vis1 variables
float circleX = 200;
float circleY = 250;
ArrayList<Arc> arcShapes;

//details on demand variables
boolean detailOnDemand = false;
int dodIndex = 0;

ArrayList<Integer> topStates;


void setup(){
  size(1000, 500);
  cp5 = new ControlP5(this);
  
  createTable();
  createDropDown();
  createToggle();
  createFilter();

  arcShapes = new ArrayList<Arc>();
  
}

void createFilter() {
  //slider-filtering
  filter = cp5.addRange("filter").setPosition(475, 400).setSize(400,20).setRange(0, 500);
  filter.setColorBackground(color(0,0,0));
  filter.setColorActive(color(200, 200, 0));
}

void createTable() {
  table = loadTable("CommuterData.csv", "header");
  states = new ArrayList<String>();
  topStates = new ArrayList<Integer>();
  for (TableRow row : table.rows()) {
    String state_name = row.getString("State");
    states.add(state_name);
  } 
  
}

void createDropDown() {
  
  //positioning of state dropdown
  dropDown = cp5.addDropdownList("states").setPosition(150, 260);
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
  dataToggle = cp5.addToggle("data Toggle").setPosition(675, 435).setSize(50,20).setMode(ControlP5.SWITCH);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    if (theEvent.group().name() == "states") {//name of dropdownlist
      currState = (int)theEvent.group().getValue();
      print(currState); 
    }
    else if(theEvent.isController()) {}
  }
}

void draw() {
  background(255);
  
  //get values from filter
  rangeHigh = (int)filter.getLowValue();
  rangeLow = (int)filter.getHighValue();
  //get toggle values, set labels
  textSize(14);
  fill(0);
  text("percent data", 550, 450);
  fill(0);
  text("raw data", 750, 450);
  toggleValue = (int)dataToggle.getValue();
  
  for(Arc a : arcShapes) {
    a.draw();
  }
  
  //instantiate each visualization
  createVis1();
  createVis2();
  
  //poke the hole in the donut chart
  fill(255, 255, 255);
  ellipse(circleX, circleY, 125, 125);
  noStroke();
  
  loadPixels();
  if(detailOnDemand == true) {
    String dodValue = table.getString(currState, dataNames[dodIndex]);
    fill(0,0,0);
    textSize(16);
    text(dataNames[dodIndex] + ": " + dodValue, mouseX, mouseY);
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
    arcShapes.add(new Arc(diam, lastAngle, lastAngle+radians(angles[i]), i));
    lastAngle += radians(angles[i]);
  }
}

void createVis2() {
  topThree();
}

void topThree() {
}

void mouseMoved() {
  detailOnDemand = false;
  color c = pixels[mouseY*width + mouseX];
  for(int i = 0; i<colors.length; i++) {
    if(c == colors[i]) {
      detailOnDemand = true;
      dodIndex = i;
    }
  }
}

class Arc {
  float diam, lastAngle, newAngle;
  int color_index;
  boolean highlight;
  Arc(float diam, float lastAngle, float newAngle, int color_index) {
  //fill in constructor - make sure to add any necessary parameters
    this.diam = diam;
    this.lastAngle = lastAngle;
    this.newAngle = newAngle;
    this.color_index = color_index;
    highlight = false;
  }
 
  //draw the circle
  void draw(){
    if(highlight == true) {
      stroke(0, 0, 0);
    }
    else {
      noStroke();
    }
    fill(colors[color_index]);
    arc(circleX, circleY, diam, diam, lastAngle, newAngle);
  }
}

//rectangle object for vis #2
class Rectangle{
  int x,y,w,h,colorIndex,pop;
  //utilize pop paramater to create a proportional square (should be a normalized population value)
  Rectangle(int x, int y, int w, int h, int colorIndex, int pop) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.colorIndex = colorIndex;
    this.pop = pop;
  }
  
  void draw(){
    rect(x,y,w,h,12,12,12,12);
  }
}


