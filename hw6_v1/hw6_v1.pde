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


//coordinate center of donut chart
float circleX = 200;
float circleY = 250;

//vis1, vis2 variables
ArrayList<Arc> arcShapes;
ArrayList<Rectangle> rectShapes;

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
  rectShapes = new ArrayList<Rectangle>();
}

void createFilter() {
  //slider-filtering
  filter = cp5.addRange("filter").setPosition(485, 430).setSize(400,20).setRange(0, 500);
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
  dataToggle = cp5.addToggle("data Toggle").setPosition(660, 470).setSize(50,20).setMode(ControlP5.SWITCH);
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
  text("Raw Value", 570, 485);
  fill(0);
  text("Percentage", 730, 485);
  toggleValue = (int)dataToggle.getValue();
  
  for(Arc a : arcShapes) {
    a.draw();
  }
  
  for(Rectangle r : rectShapes) {
    r.draw();
  }
  
  //instantiate each visualization
  createVis1();
  createVis2();
  
  //draw labels for vis2
  //coordinates of first letter of each row
  int x = 445;
  int y = 200;
  int x2 = 465;
  int y2 = 410;
  for (int i = 0; i < 3; i++){
    fill(0);
    text(dataNames[i],x,y);
    x += 180;
  }
  for (int i = 3; i < 6; i++){
    text(dataNames[i],x2,y2);
    fill(0);
    x2 += 180;
  }
  
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

//creation of vis2, called once in draw
void createVis2() {
  //TODO: sorted data will return float[] we can call for each square, conditionals based on filters will be in findMaxes()
  float[] f = new float[] {15503746,7001136,6058873};
  //float[] f = new float[] {662513,331556,291801};
  
  //color arrays of each nested square
  color[] cAlone = new color[] {#5484FF,#5DD5FF,#152140};
  color[] cPool = new color[] {#0fe85c,#97FFB7,#18401D};
  color[] cPublic = new color[] {#ffe800,#FFFAA5,#8F8200};
  color[] cWalk = new color[] {#e8804d,#E8A695,#AB5E40};
  color[] cOther = new color[] {#cb0dff,#EA9EFF,#590670};
  color[] cHome = new color[] {#FF3042,#FFA5AF,#611219};
  
  //first row of squares
  topThree(400,10,f,cAlone);
  topThree(600,10,f,cPool);
  topThree(800,10,f,cPublic);
  //second row of squares
  topThree(400,220,f,cWalk);
  topThree(600,220,f,cOther);
  topThree(800,220,f,cHome);


}

/*
* Create three nested squares based on input of 3 floats
* 
*/
void topThree(int x, int y, float[] maxes, color[] c) {
  for (int i = 0; i<3; i++){
    Rectangle r = new Rectangle(x,y,maxes[i],c[i]);
    rectShapes.add(r);  
  }
}

//when finding maxes place it in array based upon filtered constraints
void findMaxes(float min, float max){
  
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
  float pop;
  int x,y,w,h;
  color c;
  //utilize pop paramater to create a proportional square (should be a normalized population value)
  //hardcoded normalization based off largest value in csv
  Rectangle(int x, int y, float pop, color c) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.pop = pop;
  }
  
  void draw(){
    fill(c);
    rect(x,y,(pop/90000),(pop/90000),12,12,12,12);
  }
}


