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


//color arrays of each nested square
//cAlone, cPool, cPublic, cWalk, cOther, cHome
color[][] vis2Colors = new color[][] {{#5484FF,#5DD5FF,#152140}, {#0fe85c,#97FFB7,#18401D}, 
{#ffe800,#FFFAA5,#8F8200}, {#e8804d,#E8A695,#AB5E40}, {#cb0dff,#EA9EFF,#590670}, {#FF3042,#FFA5AF,#611219}};
float[][] columnData;
float[] totalWorkers;

//coordinate center of donut chart
float circleX = 200;
float circleY = 250;

//vis1, vis2 variables
ArrayList<Arc> arcShapes;
ArrayList<Rectangle> rectShapes;

//details on demand variables
boolean detailOnDemand = false;
int dodIndex = 0;
int dodIndex2 = 0;
color dodColor = #FFFFFF;


float[] topStatesData = new float[18];
float[] topStatesIndex = new float[18];

<<<<<<< HEAD
=======
//color arrays of each nested square
//cAlone, cPool, cPublic, cWalk, cOther, cHome
color[][] vis2Colors = new color[][] {{#152140,#5DD5FF,#5484FF}, {#18401D,#97FFB7,#0fe85c}, 
{#8F8200,#FFFAA5,#ffe800}, {#AB5E40,#E8A695,#e8804d}, {#590670,#EA9EFF,#cb0dff}, {#611219,#FFA5AF,#FF3042}};
String[][] vis2States = new String[][] {{"Georgia", "Pennsylvania", "California"}, {"Georgia", "Pennsylvania", "California"}, 
{"Georgia", "Pennsylvania", "California"},{"Georgia", "Pennsylvania", "California"}, {"Georgia", "Pennsylvania", "California"}, {"Georgia", "Pennsylvania", "California"}};
float[][] columnData;

>>>>>>> cda49ceeabd8b78578dddc4fdb047d0b4141b324
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
  filter = cp5.addRange("filter").setPosition(485, 430).setSize(400,20).setRange(240000, 16000000);
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
    }
    else if(theEvent.isController()) {}
  }
}

void draw() {
  background(255);
 
    
  //get toggle values, set labels
  textSize(14);
  fill(0);
  text("Raw Value", 570, 485);
  fill(0);
  text("Percentage", 730, 485);
  toggleValue = (int)dataToggle.getValue();
  
  //get values from filter
  rangeLow = (int)filter.getLowValue();
  rangeHigh = (int)filter.getHighValue();
  
  findMaxes();
  
  for(Rectangle r : rectShapes) {
    r.draw();
  }
 
  
  //instantiate each visualization
  createVis1();
  createVis2();
  
  //linking
  if(detailOnDemand == true && dodIndex2 >= 0) {
    String vis2State = states.get((int)topStatesIndex[dodIndex*3 + dodIndex2]);
    if(states.get(currState).equals(vis2State)) {
      arcShapes.get(dodIndex).highlight = true;
    }
    
  }
  
  for(Arc a : arcShapes) {
    a.draw();
  }
  
  //draw labels for vis2
  //coordinates of first letter of each row
  int x = 445;
<<<<<<< HEAD
  int y = 200;
=======
  int y = 20;
>>>>>>> cda49ceeabd8b78578dddc4fdb047d0b4141b324
  int x2 = 465;
  int y2 = 235;
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
    String dodValue = "";
    if(dodIndex2 < 0) { //use format for first vis
      dodValue = table.getString(currState, dataNames[dodIndex]);
      fill(0,0,0);
      textSize(16);
      text(dataNames[dodIndex] + ": " + dodValue, mouseX, mouseY);
    }
    else {
      String state = states.get((int)topStatesIndex[dodIndex*3 + dodIndex2]);
      fill(0,0,0);
      textSize(16);
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
    arcShapes.add(new Arc(diam, lastAngle, lastAngle+radians(angles[i]), i));
    lastAngle += radians(angles[i]);
  }
}

//creation of vis2, called once in draw
void createVis2() {
  //TODO: sorted data will return float[] we can call for each square, conditionals based on filters will be in findMaxes()
  float[] f = new float[] {15503746,7001136,6058873};
  //float[] f = new float[] {662513,331556,291801};
  
  //first row of squares
<<<<<<< HEAD
  topThree(400,10,f,vis2Colors[0]);
  topThree(600,10,f,vis2Colors[1]);
  topThree(800,10,f,vis2Colors[2]);
  //second row of squares
  topThree(400,220,f,vis2Colors[3]);
  topThree(600,220,f,vis2Colors[4]);
  topThree(800,220,f,vis2Colors[5]);

=======
  topThree(400,25,dAlone,vis2Colors[0]);
  topThree(600,25,carPool,vis2Colors[1]);
  topThree(800,25,usedPublic,vis2Colors[2]);
  //second row of squares
  topThree(400,240,walked,vis2Colors[3]);
  topThree(600,240,other,vis2Colors[4]);
  topThree(800,240,home,vis2Colors[5]);
  
}
>>>>>>> cda49ceeabd8b78578dddc4fdb047d0b4141b324

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
 
  //draw the arc
  void draw(){
    if(highlight == true) {
      
      arc(circleX, circleY, diam, diam, lastAngle, newAngle);
    }
    else { 
      fill(colors[color_index]); 
      arc(circleX, circleY, diam, diam, lastAngle, newAngle);
    }
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


