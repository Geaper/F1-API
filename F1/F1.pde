import org.gicentre.utils.spatial.*;
import org.gicentre.utils.network.*;
import org.gicentre.utils.network.traer.physics.*;
import org.gicentre.utils.geom.*;
import org.gicentre.utils.move.*;
import org.gicentre.utils.stat.*;
import org.gicentre.utils.gui.*;
import org.gicentre.utils.colour.*;
import org.gicentre.utils.text.*;
import org.gicentre.utils.*;
import org.gicentre.utils.network.traer.animation.*;
import org.gicentre.utils.io.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import java.util.Map;
import controlP5.*;
import processing.video.*;
import org.gicentre.utils.stat.*;
import java.util.Arrays;
import grafica.*;

private Movie video;
private boolean videoLoaded = false;
private boolean videoRunning = false;
private ControlP5 cp5;
// PitStop plot
private GPlot plot;
private BarChart pitStopBarChart;
private BarChart constructorsChart;
private XYChart[] driverPointsLineChart;
private ArrayList<DriverCircle> driverCircles;

private MapPosition currentHoveringMapPos = new MapPosition(0, 0);

private PImage circleImage;

// Status Array
private Status[] statusArray;

// Colors
private color red = color(225, 6, 0);
private color grey = color(204);
private color lighterRed = color(204, 4, 31);

// API URL
private static final String apiURL = "http://ergast.com/api/f1/";

// Graphs
private BarChart finishStatusBarChart;

private JSONArray racesJSON;
private JSONArray driversJSON;
private JSONArray constructorsJSON;

private HashMap<String, JSONObject> circuitsMap = new HashMap<String, JSONObject>();
private HashMap<String, JSONObject> racesMap = new HashMap<String, JSONObject>();

// Years for constructors, etc..
private String[] years = new String[] {"2015", "2016", "2017", "2018"};

private ButtonBar buttonBar;
private ButtonBar circuitBar;
private ButtonBar constructorBar;
private BarChart raceStatsBarChart;

private int currentPage = 0;

// Images
private PImage f1Logo;
private PImage f1Background;
private PImage f1Background2;
private PImage f1Img1, f1Img2, f1Img3, f1Img4, f1Img5, f1Img6;
private PImage pitStopImg;
private PImage ipcaLogo;
private PImage f1LogoBig;
private PImage constructors2Img;
private PImage circuitImg;

// Default settings
private final int canvasWidth = 1600;
private final int canvasHeight = 900;

// Buttons

//Selected Round
private String selectedRound = "1";
// Selected Race
private JSONObject selectedRace;
// Selected Driver
private JSONObject selectedDriver;
// Selected Constructor
private JSONObject selectedConstructor;
// Selected Season. Defaults to 2018
private int selectedSeason = 2018;
// Selected race results
private JSONArray resultsJSONArray;
// Selected finish status
private JSONArray finishStatusesJSON;
// Constructors Standings
private JSONArray constructorsStandingsJSON;
// Driver Images
private Map<String, PImage> driverImages = new HashMap<String, PImage>();
// Circuit Images
private Map<String, PImage> circuitImages = new HashMap<String, PImage>();
// Flags Images
private Map<String, PImage> flagImages = new HashMap<String, PImage>();
// Country Flags Images
private Map<String, PImage> countryImages = new HashMap<String, PImage>();
// Constructor Images
private Map<String, PImage> constructorImages = new HashMap<String, PImage>();
// Circuit videos
private Map<String, Movie> circuitVideos = new HashMap<String, Movie>();

// Page information loaded?
private boolean dataLoaded = false;
private boolean[] circuitHovered;

// Map
private UnfoldingMap unfoldingMap;

// Marker Image
private PImage markerImage;

// Results of a race
JSONArray resultsArray;

// Circuit locations on the map
Map<String, MapPosition> mapPositions = new HashMap<String, MapPosition>();

// Fonts
private PFont font1, font2;
private PFont titleFont;
private PFont smallFont;
private PFont smallerFont;

void settings() {
  size(canvasWidth, canvasHeight, P2D);
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// Call back event of menu bar
void bar(int pageIndex) {
  switch(pageIndex) {
    // Initial
  case 0:
    currentPage = 99;
    break;
    // Circuits
  case 1:
    currentPage = 1;
    break;
    // Drivers
  case 2:
    currentPage = 7;
    break;
    // Constructors
  case 3:
    currentPage = 4;
    break;
    // Finish Statistics
  case 4:
    currentPage = 6;
    break;
  case 5:
    // Pit Stops
    currentPage = 8;
    break;
  }

  dataLoaded = false;
}


void setup() {

  background(0);
  // Spinner GIF
  PImage spinner = loadImage("img/common/spinner.gif");
  image(spinner, canvasWidth/2 - 100, canvasHeight/2 - 50);

  // Enable control p5
  cp5 = new ControlP5(this);

  // Animation
  Ani.init(this);

  // Unfolding Map
  //smooth();  // instrucao para suavisar graficos em todo o programa

  unfoldingMap = new UnfoldingMap(this);
  unfoldingMap.setTweening(true);
  unfoldingMap.zoomToLevel(16);
  Location location = new Location(38.736946, -9.142685);
  unfoldingMap.zoomAndPanTo(location, 3);
  unfoldingMap.setScaleRange(8f, 300f);

  MapUtils.createDefaultEventDispatcher(this, unfoldingMap);

  // Menu Names
  ArrayList<String> menuNames = new ArrayList<String>();
  menuNames.add("Main Menu");
  menuNames.add("Circuits");
  menuNames.add("Drivers");
  menuNames.add("Constructors");
  menuNames.add("Finish Statistics");
  menuNames.add("Pit Stops");

  // Button Bar
  buttonBar = cp5.addButtonBar("bar")
    .setPosition(0, 0)
    .setSize(canvasWidth, 30)
    .setColorBackground(0)
    .setColorActive(red)
    .setColorForeground(lighterRed)
    .addItems(menuNames);

  // Load Map positions
  loadCircuitPointOnMap();

  // Load all videos
  /*
    String[] fileNames = listFileNames(sketchPath() + "/data/circuit_videos");
   println("Loading Videos");
   for (String fileName : fileNames) {
   // remove extension
   String circuitID = fileName.split("\\.")[0];
   // Load videos
   video = new Movie(this, "circuit_videos/" + circuitID + ".mp4");
   circuitVideos.put(circuitID, video);
   }
   */

  // Load All Flag Images
  String[] fileNames = listFileNames(sketchPath() + "/img/flags");
  println("Loading Flags");
  for (String fileName : fileNames) {
    // remove extension
    String flagName = fileName.split("\\.")[0];
    flagImages.put(flagName, loadImage(sketchPath() + "/img/flags/" + fileName));
  }
  // Country Images
  fileNames = listFileNames(sketchPath() + "/img/countries");
  println("Loading Countries");
  for (String fileName : fileNames) {
    // remove extension
    String flagName = fileName.split("\\.")[0];
    countryImages.put(flagName, loadImage(sketchPath() + "/img/countries/" + fileName));
  }

  // Load All Circuit Images
  fileNames = listFileNames(sketchPath() + "/img/circuits");
  println("Loading Circuits");
  for (String fileName : fileNames) {
    // remove extension
    String circuitid = fileName.split("\\.")[0];
    circuitImages.put(circuitid, loadImage(sketchPath() + "/img/circuits/" + fileName));
  }

  // Load All Driver Images
  fileNames = listFileNames(sketchPath() + "/img/drivers");
  println("Loading Drivers");
  for (String fileName : fileNames) {
    // remove extension
    String driverid = fileName.split("\\.")[0];
    driverImages.put(driverid, loadImage(sketchPath() + "/img/drivers/" + fileName));
  }

  // Load All Constructor Images
  fileNames = listFileNames(sketchPath() + "/img/constructors");
  println("Loading Constructors");
  for (String fileName : fileNames) {
    // remove extension
    String constructorid = fileName.split("\\.")[0];
    constructorImages.put(constructorid, loadImage(sketchPath() + "/img/constructors/" + fileName));
  }


  // Get necessary data from the API
  // Load All the Circuits
  JSONObject data = loadJSONObject(apiURL + selectedSeason + ".json").getJSONObject("MRData"); 
  racesJSON = data.getJSONObject("RaceTable").getJSONArray("Races");
  // Put them into the hashmap
  for (int i = 0; i < racesJSON.size(); i++) {
    String round = racesJSON.getJSONObject(i).getString("round");
    JSONObject raceJSON = racesJSON.getJSONObject(i);
    JSONObject circuitJSON = racesJSON.getJSONObject(i).getJSONObject("Circuit");
    String circuitID = circuitJSON.getString("circuitId"); // Key
    // Load points from the Map
    MapPosition mapPosition = mapPositions.get(circuitID);
    if (mapPosition != null) {
      // Load coordinates from file
      circuitJSON.setFloat("mapX", mapPosition.getX());
      circuitJSON.setFloat("mapY", mapPosition.getY());

      circuitsMap.put(circuitID, circuitJSON); // Add to Collection
      racesMap.put(round, raceJSON); // Add to collection
    }
  }

  // Common Stuff
  f1Logo = loadImage("img/common/f1-logo2.png");
  f1Background = loadImage("img/common/f1-background.jpg");
  f1Background2 = loadImage("img/common/f1-background3.jpg");
  ipcaLogo = loadImage("img/common/ipca.png");
  f1Img1 = loadImage("img/common/f1-background2.jpg");
  f1Img2 = loadImage("img/common/f1-circuit-background.jpg");
  f1Img3 = loadImage("img/common/f1-drivers-background.jpg");
  f1Img4 = loadImage("img/common/f1-finishStatus-background.jpg");
  f1Img5 = loadImage("img/common/f1-constructors-background.jpg");
  f1Img6 = loadImage("img/common/f1-pitstops-background.jpg");
  pitStopImg = loadImage("img/common/pitstop.jpg");
  pitStopImg.resize(canvasWidth, canvasHeight);
  f1LogoBig = loadImage("img/common/f1-logo-big.jpg");
  f1LogoBig.resize(canvasWidth, canvasHeight);
  constructors2Img = loadImage("img/common/constructors2.jpg");
  constructors2Img.resize(canvasWidth, canvasHeight);
  circuitImg = loadImage("img/common/circuit.jpg");
  circuitImg.resize(canvasWidth, canvasHeight);
  
 

  // Fonts
  font1 = createFont("Arial", 40);
  font2 = createFont("Arial Bold", 42);
  titleFont = createFont("Arial Bold", 42);
  smallFont = createFont("Arial", 30);
  smallerFont = createFont("Arial", 12);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void draw() {

  // Remove hidden menu when page is not the first one
  if (currentPage != 0) buttonBar.show();

  // Pages
  switch(currentPage) {
  case 0:
    page0(); // Intro
    break;
  case 99:
    page99(); // Main Menu
    break;
  case 1:
    page1(); // Circuit
    break;
  case 2:
    page2(); // Circuit Details
    break;
  case 3:
    page3(); // Driver Details
    break;
  case 4:
    page4(); // Constructors
    break;
  case 5:
    page5(); // Constructor Details
    break;
  case 6:
    page6(); // Finishing Statistics (Maybe check the drivers with most accidents, finishes, etc...)
    break;
  case 7:
    page7(); // Drivers
    break;
  case 8:
    page8(); // PitStops
    break; 
  default:
    currentPage = 0; // Default page
    page0();
    break;
  }
  // Debug
  fill(255, 0, 0);
  textSize(10);
  text("X: " + mouseX + " ,Y: " + mouseY, canvasWidth - 200, 40);

  text("Zoom: " + unfoldingMap.getZoom(), canvasWidth -400, 40);
}

// Page 0
void page0() {
  buttonBar.hide();
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
  if (cp5.get("race") != null) cp5.get("race").hide();
  // Load Images
  // Background
  image(f1LogoBig, 0, 0);
  // F1 Logo
  f1Logo.resize(213, 54);
  image(f1Logo, canvasWidth - 233, canvasHeight - 74);
  // IPCA Logo
  ipcaLogo.resize(156, 90);
  image(ipcaLogo, canvasWidth -233 - 156, canvasHeight -85);

  fill(255);
  // Title
  textSize(80);
  text("Formula 1 Data Visualization", 50, 100); 
  // Made by
  textSize(48);
  text("Made By:", 75, height - 200);
  textSize(30);
  text("Tiago Silva 6130", 75, height - 150);
  text("André Monteiro 16202", 75, height - 100);

  // When user clicks any key, go to the next page
  if (keyPressed || mousePressed) currentPage = 99;
}

void page99() {

  noTint();
  image(f1Img1, 0, 0, canvasWidth, canvasHeight);

  // Hide controls
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
  if (cp5.get("barSeason") != null) cp5.get("barSeason").hide();
  if (cp5.get("barCircuit") != null) cp5.get("barCircuit").hide();
  
  buttonBar.hide();

  // Menu
  fill(255);

  textFont(font1);
  text("Circuits", 75, 450);
  text("Drivers", 75, 550);
  text("Constructors", 75, 650);
  text("Finish Statistics", 75, 750);
  text("PitStop Statistics", 75, 850);

  // Circuits
  if (mouseX < 230 && mouseX > 100 && mouseY > 425 && mouseY < 450) {
    // Show another image
    image(f1Img2, 0, 0, canvasWidth, canvasHeight);
    // Highlight
    textFont(font2);
    text("Circuits", 75, 450);
    textFont(font1);
    text("Drivers", 75, 550);
    text("Constructors", 75, 650);
    text("Finish Statistics", 75, 750);
    text("PitStop Statistics", 75, 850);

    // On Click change page
    if (mousePressed) {
      currentPage = 1;
      dataLoaded = false;
    }
  }
  // Drivers
  if (mouseX < 230 && mouseX > 75 && mouseY > 525 && mouseY < 550) {
    // Show another image
    image(f1Img3, 0, 0, canvasWidth, canvasHeight);
    // Highlight
    textFont(font2);
    text("Drivers", 75, 550);
    textFont(font1);
    text("Circuits", 75, 450);
    text("Constructors", 75, 650);
    text("Finish Statistics", 75, 750);
    text("PitStop Statistics", 75, 850);

    // On Click change page
    if (mousePressed) {
      currentPage = 7;
      dataLoaded = false;
    }
  }
  // Constructors
  if (mouseX < 320 && mouseX > 75 && mouseY > 625 && mouseY < 650) {
    // Show another image
    image(f1Img5, 0, 0, canvasWidth, canvasHeight);
    // Highlight
    textFont(font2);
    text("Constructors", 75, 650);
    textFont(font1);
    text("Circuits", 75, 450);
    text("Drivers", 75, 550);
    text("Finish Statistics", 75, 750);
    text("PitStop Statistics", 75, 850);

    // On Click change page
    if (mousePressed) {
      currentPage = 4;
      dataLoaded = false;
    }
  }
  // Finish Statistics
  if (mouseX < 360 && mouseX > 75 && mouseY > 725 && mouseY < 750) {
    // Show another image
    image(f1Img4, 0, 0, canvasWidth, canvasHeight);
    // Highlight
    textFont(font2);
    text("Finish Statistics", 75, 750);
    textFont(font1);
    text("Circuits", 75, 450);
    text("Drivers", 75, 550);
    text("Constructors", 75, 650);
    text("PitStop Statistics", 75, 850);

    // On Click change page
    if (mousePressed) {
      currentPage = 6;
      dataLoaded = false;
    }
  }
  // PitStops Statistics
  if (mouseX < 360 && mouseX > 75 && mouseY > 825 && mouseY < 850) {
    // Show another image
    image(f1Img6, 0, 0, canvasWidth, canvasHeight);
    // Highlight
    textFont(font2);
    text("PitStop Statistics", 75, 850);
    textFont(font1);
    text("Circuits", 75, 450);
    text("Drivers", 75, 550);
    text("Constructors", 75, 650);
    text("Finish Statistics", 75, 750);

    // On Click change page
    if (mousePressed) {
      currentPage = 8;
      dataLoaded = false;
    }
  }
}

// Page 1
void page1() {
  background(0);
  // Load Map
  unfoldingMap.draw();

  // Hide controls
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("barSeason") != null) cp5.get("barSeason").hide();

  //shape(map, 0, 0, canvasWidth, canvasHeight - 100);
  fill(255, 0, 0);    

  // Season Slider
  if (!dataLoaded) {
    circuitBar2();
    if(cp5.get("circuitBar2") != null) cp5.get("circuitBar2").show();

    circuitHovered = new boolean[racesMap.size()];
    // Marker Image
    //markerImage = loadImage("img/common/marker.png");
    //markerImage.resize((int)(markerImage.width * 0.005), (int) (markerImage.height * 0.005));

    dataLoaded = true;
  }

  // Loop through the circuits
  int index = 0;
  for (Map.Entry raceEntry : racesMap.entrySet()) {
    JSONObject raceJSON = (JSONObject) raceEntry.getValue();
    JSONObject circuitJSON = raceJSON.getJSONObject("Circuit");
    String circuitID = (String) circuitJSON.getString("circuitId");

    circuitHovered[index] = false;

    // Get coordinates
    float mapX = ((Double) circuitJSON.get("mapX")).floatValue();
    float mapY = ((Double) circuitJSON.get("mapY")).floatValue();

    Location mapLocation = new Location(mapX, mapY);
    ScreenPosition mapPosition = unfoldingMap.getScreenPosition(mapLocation);
    float scale = unfoldingMap.getZoom();

    // Draw points on the map
    stroke(255);
    fill(38);
    ellipse(mapPosition.x, mapPosition.y, 0.75 * scale, 0.75 * scale);
    
    // Pretty?
    //ImageMarker imgMarker1 = new ImageMarker(mapLocation, circleImage);
    //unfoldingMap.addMarkers(imgMarker1);

    // On Hover ...
    float dist = dist(mapPosition.x, mapPosition.y, mouseX, mouseY);
    
    if (dist < (0.75 * scale)/2) {
      fill(255);
      stroke(38);
      rect(50,100,300,150);
      
      // Title on top of the video
      textSize(21);
      String circuitName = circuitJSON.getString("circuitName");
      String lat = circuitJSON.getJSONObject("Location").getString("lat");
      String longi = circuitJSON.getJSONObject("Location").getString("long");
      String locality = circuitJSON.getJSONObject("Location").getString("locality");
      String country = circuitJSON.getJSONObject("Location").getString("country");
      
      fill(red);
      text(circuitName, 55, 135);
      fill(38);
      textSize(17);
      text("Latitude: " + lat + "º", 55, 170);
      text("Longitude: " + longi + "º", 55, 200);
      text("Location: " + locality, 55, 230);
      
       rect(232,172, 82, 42);
       PImage countryImg = countryImages.get(country);
       countryImg.resize(80,40);
       image(countryImg, 230, 170);
      

      // When the user clicks this circle, change page
      if (mousePressed) {
        dataLoaded = false;
        currentPage = 2;
        // "Pass" selectedCircuitID
        selectedRace = raceJSON;
      }
    }
  }
}

String cName;
// Circuit Details
void page2() {
  //image(circuitImg, 0,0);
  background(38);
  // If data is not loaded, do it
  if (!dataLoaded) { 
    
    circuitBar3();
    // Line
    fill(255);
    line(0, 30, canvasWidth, 30);
    // Load Circuit  
    JSONObject circuitJSON = selectedRace.getJSONObject("Circuit");
    String circuitName = circuitJSON.getString("circuitName");
    String circuitCountry = circuitJSON.getJSONObject("Location").getString("country");
    String circuitID = circuitJSON.getString("circuitId");
    String city = circuitJSON.getJSONObject("Location").getString("locality");
    String lat = circuitJSON.getJSONObject("Location").getString("lat");
    String longit = circuitJSON.getJSONObject("Location").getString("long");
    String wikiURL = circuitJSON.getString("url");
    
    cName = circuitName;

    // Show circuit Details
    text("Circuit Name: " + circuitName, 20, 40);
    text("City: " + city, 20, 30);
    text("Latitude: " + lat + "º", 20, 50);
    text("Longitude: " + longit + "º", 20, 60);
    text("Wikipedia Link: " + wikiURL, 20, 70);
    text("Country: " + circuitCountry, 20, 80);

    // Title
    //cp5.addTextlabel("label").setText(circuitName).setPosition(canvasWidth/2 - 100,30).setColorValue(0xffffff00).setFont(createFont("Georgia",20));
    
    video = new Movie(this, "circuit_videos/" + circuitID + ".mp4");
    image(video, 50, 150, video.width * 0.75, video.height * 0.75);
    video.loop();

    // Get Driver standings
    String round = selectedRace.getString("round");
    float maxValue = 0;
    float min = Integer.MAX_VALUE;
    println(round);
    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/" + round + "/results.json").getJSONObject("MRData");
    JSONObject race = (JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0);
    resultsJSONArray = race.getJSONArray("Results");
    float[] fastestLaps = new float[resultsJSONArray.size()];
    String[] drivers = new String[resultsJSONArray.size()];
    ArrayList<String> driverStandingsList = new ArrayList<String>();
    for (int i = 0; i < resultsJSONArray.size(); i++) {
      JSONObject result = (JSONObject) resultsJSONArray.get(i);
      JSONObject driver = result.getJSONObject("Driver");
      String driverID = driver.getString("driverId");

      // Driver Name
      String driverName = driver.getString("givenName") + " " + driver.getString("familyName");

      driverStandingsList.add(i+1 + "º - " + driverName + " | " + result.getString("status"));
      
      if(result.getJSONObject("FastestLap") != null) {
        fastestLaps[i] = Float.parseFloat(result.getJSONObject("FastestLap").getJSONObject("AverageSpeed").getString("speed"));
        drivers[i] = driverID;
        
        if(maxValue < fastestLaps[i]) maxValue = fastestLaps[i];
        
        if(min > fastestLaps[i]) min = fastestLaps[i];
      }
      else {
        fastestLaps[i] = 0f;
        drivers[i] = "";
      }
    }
    fill(38);

      cp5.addScrollableList("Driver Standings")
        .setPosition(canvasWidth/2, 45)
        .setSize(canvasWidth/2 - 10, canvasHeight/2 - 45)
        .setColorBackground(color(0))
        .setColorActive(red)
        .setColorForeground(red)
        .setBarHeight(50)
        .setItemHeight(50)
        .addItems(driverStandingsList)
        .setFont(smallerFont);
      
    raceStatsBarChart = new BarChart(this);
    raceStatsBarChart.setData(fastestLaps);

    // Scaling
    raceStatsBarChart.setMinValue(min - 10);
    raceStatsBarChart.setMaxValue(maxValue);
    
    // Axis appearance
    textFont(createFont("Serif", 10), 10);
     println(min);
     println(maxValue);
    raceStatsBarChart.showValueAxis(true);
    raceStatsBarChart.setBarLabels(drivers);
    raceStatsBarChart.showCategoryAxis(true);
    raceStatsBarChart.setBarColour(fastestLaps, ColourTable.getPresetColourTable(ColourTable.YL_OR_RD, min, maxValue));
    raceStatsBarChart.setAxisLabelColour(255);
    raceStatsBarChart.setAxisValuesColour(255);
    raceStatsBarChart.transposeAxes(true);
    raceStatsBarChart.setShowEdge(true);
    raceStatsBarChart.setValueFormat("# KM/h");

    dataLoaded = true;
  }
  stroke(255);
  textSize(10);
  if(raceStatsBarChart != null)
    raceStatsBarChart.draw(20, 170, canvasWidth/2 - 70, canvasHeight - 210);
    
    // Title
  fill(255);
  textFont(titleFont);
  text("Formula 1 Average Speeds", 140, 80);
  float textHeight = textAscent();
  textFont(smallFont);
  text(cName, 140, 80 + textHeight);
  textSize(25);
    
  image(video, canvasWidth/2 - 5, canvasHeight/2 - 10, canvasWidth/2 - 5, canvasHeight/2 - 10);
}

// Driver details
void page3() {
  background(0);

  // Hide Controlp5
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
  if (cp5.get("race") != null) cp5.get("race").hide();

  String driverID = selectedDriver.getString("driverId");
  String driverName = selectedDriver.getString("givenName") + " " + selectedDriver.getString("familyName");
  // Title
  textSize(32);
  fill(255, 0, 0);
  text(driverName, canvasWidth/2, 20);
  // Driver Picture
  PImage driverImage = driverImages.get(driverID);
  driverImage.resize(200, 150);
  image(driverImage, 30, 150);
}

void barSeason(int index) {
  season = years[index];
  println(season);
  dataLoaded = false;
}

void seasonBar() {
  if (cp5.get("barSeason") == null) {
    constructorBar = cp5.addButtonBar("barSeason")
      .setPosition(0, canvasHeight - 30)
      .setSize(canvasWidth, 30)
      .setColorBackground(0)
      .setColorActive(red)
      .setColorForeground(lighterRed)
      .addItems(years);
  }
}

// Constructors
private String season = "2018";
void page4() {
  //background(38);
  image(constructors2Img,0,0);

  if (!dataLoaded) {
    if(cp5.get("barSeason") != null) cp5.get("barSeason").show();
    JSONObject data = loadJSONObject(apiURL + season + "/constructors.json").getJSONObject("MRData"); //TODO change year
    constructorsJSON = data.getJSONObject("ConstructorTable").getJSONArray("Constructors");

    // Constructor standings for this year
    data = loadJSONObject(apiURL + season + "/constructorStandings.json").getJSONObject("MRData"); //TODO change year
    constructorsStandingsJSON = ((JSONObject)(data.getJSONObject("StandingsTable").getJSONArray("StandingsLists")).get(0)).getJSONArray("ConstructorStandings");

    String[] wins = new String[constructorsStandingsJSON.size()];
    String[] points = new String[constructorsStandingsJSON.size()];
    String[] constructors = new String[constructorsStandingsJSON.size()];
    ConstructorStandings[] constructorStandingsArray = new ConstructorStandings[constructorsStandingsJSON.size()];

    for (int i = 0; i < constructorsStandingsJSON.size(); i++) {
      JSONObject constructorStandingsJSON = (JSONObject) constructorsStandingsJSON.get(i);
      // They are ordered
      points[i] = constructorStandingsJSON.getString("points");
      wins[i] = constructorStandingsJSON.getString("wins");
      constructors[i] = constructorStandingsJSON.getJSONObject("Constructor").getString("constructorId");

      constructorStandingsArray[i] = new ConstructorStandings(constructors[i], points[i], wins[i]);
    }

    float maxValue = 0;

    Arrays.sort(constructorStandingsArray);

    float[] pointsData = new float[constructorStandingsArray.length]; 

    for (int i = 0; i < constructorStandingsArray.length; i++) {
      points[i] = constructorStandingsArray[i].points;
      wins[i] = constructorStandingsArray[i].wins;
      pointsData[i] = Float.parseFloat(points[i]);
      constructors[i] = constructorStandingsArray[i].constructor;

      if (Integer.parseInt(points[i]) > maxValue) maxValue = Integer.parseInt(points[i]);
    }

    constructorsChart = new BarChart(this);
    constructorsChart.setData(pointsData);

    // Scaling
    constructorsChart.setMinValue(0);
    constructorsChart.setMaxValue(maxValue);

    // Axis appearance
    textFont(createFont("Serif", 10), 10);

    constructorsChart.showValueAxis(true);
    constructorsChart.setBarLabels(constructors);
    constructorsChart.showCategoryAxis(true);
    constructorsChart.setAxisLabelColour(255);
    constructorsChart.setAxisValuesColour(255);
    constructorsChart.setShowEdge(true);
    constructorsChart.setValueFormat("# Points");

    // Change Table color
    int c;
    switch(season) {
    case "2015":
      c = ColourTable.RD_PU;
      break;
    case "2016":
      c = ColourTable.GREENS;
      break;
    case "2017":
      c = ColourTable.BLUES;
      break;
    case "2018":
      c = ColourTable.YL_OR_RD;
      break;
    default:
      c = ColourTable.YL_OR_RD;
      break;
    }

    constructorsChart.setBarColour(pointsData, ColourTable.getPresetColourTable(c, - maxValue, maxValue));

    seasonBar();

    dataLoaded = true;
  }

  textSize(16);
  stroke(255);
  // draw constructor standings graph
  constructorsChart.draw(40, 100, width-80, height-140);

  fill(255);
  textFont(titleFont);
  text("Formula 1 Constructors Ranking", 100, 100);
  float textHeight = textAscent();
  textFont(smallFont);
  text("Season " + season, 100, 100 + textHeight);
}


// Constructor Details
void page5() {
  background(0);

  // Hide Controlp5
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();

  String constructorID = selectedConstructor.getString("constructorId");
  text(constructorID, canvasWidth/2, 20);
  PImage constructorImage = constructorImages.get(constructorID);
  constructorImage.resize(300, 200);
  image(constructorImage, 30, 100);
}

// Finish Status
void page6() {
  PFont font = createFont("serif bold", 25);
  if (!dataLoaded) {
    //background(255);
    JSONObject data = loadJSONObject(apiURL + "status.json").getJSONObject("MRData");
    finishStatusesJSON = data.getJSONObject("StatusTable").getJSONArray("Status");
    dataLoaded = true;

    // Hide Controlp5
    if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
    if (cp5.get("season") != null) cp5.get("season").hide();

    fill(255, 0, 0);
    // For each Status
    float lastAngle = 0;
    float totalCount = 0;
    float maxValue = 0;
    statusArray = new Status[finishStatusesJSON.size()];

    for (int i = 0; i < finishStatusesJSON.size(); i++) {
      JSONObject finishStatusJSON = (JSONObject) finishStatusesJSON.get(i);
      float count = finishStatusJSON.getFloat("count"); 
      String status = finishStatusJSON.getString("status");
      totalCount += count;

      //Remove Finished, n Laps
      Status statusObj = new Status(status, count);
      statusArray[i] = statusObj;

      // Max value of the table
      if (maxValue < count) maxValue = count;
    }

    Arrays.sort(statusArray);

    String[] statusDescriptions = new String[statusArray.length];
    float[] countData = new float[statusArray.length]; 
    for (int i = 0; i < statusArray.length; i++) {
      statusDescriptions[i] = statusArray[i].status;
      countData[i] = statusArray[i].count;
    }

    finishStatusBarChart = new BarChart(this);
    finishStatusBarChart.setData(countData);

    // Scaling
    finishStatusBarChart.setMinValue(0);
    finishStatusBarChart.setMaxValue(maxValue);

    // Axis appearance
    textFont(createFont("Serif", 10), 10);

    finishStatusBarChart.showValueAxis(true);
    finishStatusBarChart.setBarLabels(statusDescriptions);
    finishStatusBarChart.showCategoryAxis(true);
    finishStatusBarChart.setBarColour(countData, ColourTable.getPresetColourTable(ColourTable.YL_OR_RD, - maxValue, maxValue));
    finishStatusBarChart.setAxisLabelColour(255);
    finishStatusBarChart.setAxisValuesColour(255);
    finishStatusBarChart.transposeAxes(true);
    finishStatusBarChart.setShowEdge(true);

    dataLoaded = true;
  }
  background(255);
  tint(255, 220);
  f1Background2.resize(canvasWidth, canvasHeight);
  image(f1Background2, 0, 0);

  textSize(13);
  finishStatusBarChart.draw(20, 55, canvasWidth - 35, canvasHeight-60);
  fill(255);

  textFont(titleFont);
  text("Formula 1 Finish Statistics", 150, 100);
  float textHeight = textAscent();
  textFont(smallFont);
  text("All time finish statistics", 150, 100 + textHeight);

  for (int i = 0; i < statusArray.length; i++) {    
    // Show data on the right
    fill(255);
    textFont(font);
    int posX = 0, posY = 0;

    if (i == 0) {
      posX = 1000;
      posY = 100;
      fill(254, 53, 50);
    } else if (i == 1) {
      posX = 1200;
      posY = 100;
      fill(255);
    } else if (i == 2) {
      posX = 1400;
      posY = 100;
      fill(255, 168, 9);
    } else if (i == statusArray.length - 3) {
      posX = 1000;
      posY = 200;
      fill(255, 168, 9);
    } else if (i == statusArray.length - 2) {
      posX = 1200;
      posY = 200;
      fill(254, 53, 50);
    } else if (i == statusArray.length - 1) {
      posX = 1400;
      posY = 200;
      fill(255);
    }  

    // Stroke for the graphs
    stroke(0); 
    if (i < 3) {
      text(statusArray[i].status, posX +50, posY);
      text((int)statusArray[i].count, posX + 50, posY + 50);
      fill(255);
      text("Less Common", 800, 120);

      // Draw line
      if (i == 2) {
        stroke(255);
        line(800, 165, 1560, 165);
      }
    } else if (i > statusArray.length - 4) {
      text(statusArray[i].status, posX +50, posY);
      text((int)statusArray[i].count, posX +50, posY + 50);
      fill(255);
      text("Most Common", 800, 220);
    }
  }
}


Map<String, Boolean> activatedDriversMap = new HashMap<String, Boolean>();
Map<String, float[]> pointsPerRaceMap = new HashMap<String, float[]>();
Map<String, XYChart> charts = new HashMap<String, XYChart>();
boolean driverResultsLoaded = false;
String selectedDriv = "alonso";
boolean doOnce = false;
boolean axisShown = false;
// Drivers
void page7() {

   background(38);
  if (!dataLoaded) {
    driverPointsLineChart = new XYChart[25];
    JSONObject data = loadJSONObject(apiURL + "2018" + "/drivers.json").getJSONObject("MRData"); //TODO change year
    driversJSON = data.getJSONObject("DriverTable").getJSONArray("Drivers");
    for (int i=0; i < driversJSON.size(); i++) {
      JSONObject driverJSON = (JSONObject) driversJSON.get(i);
      String driverID = driverJSON.getString("driverId");
      if (driverID.equals("alonso")) activatedDriversMap.put(driverID, true);
      else activatedDriversMap.put(driverID, false);

      charts.put(driverID, new XYChart(this));
    }
    
    JSONArray dataRaces = loadJSONObject(apiURL + season + "/drivers/" + selectedDriv + "/results.json").getJSONObject("MRData").getJSONObject("RaceTable").getJSONArray("Races"); 
    float[] pointsPerRaceList = new float[dataRaces.size()];   
    float[] roundsArray = new float[dataRaces.size()];
    // for each race
    for (int j = 0; j < dataRaces.size(); j++) {
      JSONObject dataRace = (JSONObject) dataRaces.get(j);
      JSONArray results = dataRace.getJSONArray("Results");
      JSONObject result = (JSONObject) results.get(0);
      String dID = result.getJSONObject("Driver").getString("driverId");
      float points = Float.parseFloat(result.getString("points"));
      pointsPerRaceList[j] = points;
      pointsPerRaceMap.put(dID, pointsPerRaceList);
      roundsArray[j] = Float.parseFloat(dataRace.getString("round"));
    }

    dataLoaded = true;
  }

  fill(255);

  // For each one of them show details on the bottom and enable to user to click them to see the details
  textSize(25);
  int posY = 40;
  int posX = 1500;
  int[] colors = new int[driversJSON.size()];
  for (int i=0; i < driversJSON.size(); i++) {
    JSONObject driverJSON = (JSONObject) driversJSON.get(i);
    String driverID = driverJSON.getString("driverId");
    String driverCode = driverJSON.getString("code");

    posY += 40;
    if (!activatedDriversMap.get(driverID)) {
      fill(255);
    } else {
      if (driverID.equals("alonso") || driverID.equals("vandoorne")) {
        // Orange
        fill(255, 135, 0);
        colors[i] = color(255, 135, 0);
      } else if (driverID.equals("bottas") || driverID.equals("hamilton")) {
        // Light blue
        fill(0, 210, 190);
        colors[i] = color(0, 210, 190);
      } else if (driverID.equals("vettel") || driverID.equals("raikkonen")) {
        // Red
        fill(220, 0, 0);
        colors[i] = color(220, 0, 0);
      } else if (driverID.equals("ericsson") || driverID.equals("leclerc")) {
        // White and Red
        fill(155, 0, 0);
        colors[i] = color(155, 0, 0);
      } else if (driverID.equals("gasly") || driverID.equals("brendon_hartley")) {
        // Blue
        fill(0, 50, 255);
        colors[i] = color(0, 50, 255);
      } else if (driverID.equals("grosjean") || driverID.equals("kevin_magnussen")) {
        // Grey
        fill(90, 90, 90);
        colors[i] = color(90, 90, 90);
      } else if (driverID.equals("hulkenberg") || driverID.equals("sainz")) {
        // Yellow
        fill(255, 245, 0);
        colors[i] = color(255, 245, 0);
      } else if (driverID.equals("ricciardo") || driverID.equals("max_verstappen")) {
        // Purple
        fill(0, 50, 125);
        colors[i] = color(0, 50, 125);
      } else if (driverID.equals("ocon") || driverID.equals("perez")) {
        // Pink
        fill(245, 150, 200);
        colors[i] = color(245, 150, 200);
      } else if (driverID.equals("sirotkin") || driverID.equals("stroll")) {
        // White and Blue
        fill(255, 255, 255);
        colors[i] = color(255, 255, 255);
      }
    }
    
    text(driverCode, 1500, posY);

    // If hover
    if (mouseX < posX + 100 && mouseX > posX && mouseY > posY - 21 && mouseY < posY) {


      if (driverID.equals("alonso") || driverID.equals("vandoorne")) {
        // Orange
        fill(255, 135, 0);
      } else if (driverID.equals("bottas") || driverID.equals("hamilton")) {
        // Light blue
        fill(0, 210, 190);
      } else if (driverID.equals("vettel") || driverID.equals("raikkonen")) {
        // Red
        fill(220, 0, 0);
      } else if (driverID.equals("ericsson") || driverID.equals("leclerc")) {
        // White and Red
        fill(155, 0, 0);
      } else if (driverID.equals("gasly") || driverID.equals("brendon_hartley")) {
        // Blue
        fill(0, 50, 255);
      } else if (driverID.equals("grosjean") || driverID.equals("kevin_magnussen")) {
        // Grey
        fill(90, 90, 90);
      } else if (driverID.equals("hulkenberg") || driverID.equals("sainz")) {
        // Yellow
        fill(255, 245, 0);
      } else if (driverID.equals("ricciardo") || driverID.equals("max_verstappen")) {
        // Purple
        fill(0, 50, 125);
      } else if (driverID.equals("ocon") || driverID.equals("perez")) {
        // Pink
        fill(245, 150, 200);
      } else if (driverID.equals("sirotkin") || driverID.equals("stroll")) {
        // White and Blue
        fill(255, 255, 255);
      }
      text(driverCode, 1500, posY);

      if (mousePressed && !doOnce) {
        println(activatedDriversMap.get(driverID));
        if (activatedDriversMap.get(driverID))  activatedDriversMap.put(driverID, false);
        else activatedDriversMap.put(driverID, true);
        driverResultsLoaded = false;
        selectedDriv = driverID;
        doOnce = true;
        
        JSONArray dataRaces = loadJSONObject(apiURL + season + "/drivers/" + selectedDriv + "/results.json").getJSONObject("MRData").getJSONObject("RaceTable").getJSONArray("Races"); 
        float[] pointsPerRaceList = new float[dataRaces.size()];   
        float[] roundsArray = new float[dataRaces.size()];
        // for each race
        for (int j = 0; j < dataRaces.size(); j++) {
          JSONObject dataRace = (JSONObject) dataRaces.get(j);
          JSONArray results = dataRace.getJSONArray("Results");
          JSONObject result = (JSONObject) results.get(0);
          String dID = result.getJSONObject("Driver").getString("driverId");
          float points = Float.parseFloat(result.getString("points"));
          pointsPerRaceList[j] = points;
          pointsPerRaceMap.put(dID, pointsPerRaceList);
          roundsArray[j] = Float.parseFloat(dataRace.getString("round"));
        }
      }
    }
  }

  // Graph graph for each active driver
  int idx = 0;
  int clr = red;
  for (Map.Entry me : activatedDriversMap.entrySet()) {
    if ((boolean) me.getValue()) {
      String driverID = (String) me.getKey();
      if(pointsPerRaceMap.get(driverID) != null) {
        
         if (!activatedDriversMap.get(driverID)) {
          } else {
            if (driverID.equals("alonso") || driverID.equals("vandoorne")) {
              clr = color(255, 135, 0);
            } else if (driverID.equals("bottas") || driverID.equals("hamilton")) {
              // Light blue
              clr = color(0, 210, 190);
            } else if (driverID.equals("vettel") || driverID.equals("raikkonen")) {
              // Red
              clr = color(220, 0, 0);
            } else if (driverID.equals("ericsson") || driverID.equals("leclerc")) {
              // White and Red
              clr = color(155, 0, 0);
            } else if (driverID.equals("gasly") || driverID.equals("brendon_hartley")) {
              // Blue
              clr = color(0, 50, 255);
            } else if (driverID.equals("grosjean") || driverID.equals("kevin_magnussen")) {
              // Grey
              clr = color(90, 90, 90);
            } else if (driverID.equals("hulkenberg") || driverID.equals("sainz")) {
              // Yellow
              clr = color(255, 245, 0);
            } else if (driverID.equals("ricciardo") || driverID.equals("max_verstappen")) {
              // Purple
              clr = color(0, 50, 125);
            } else if (driverID.equals("ocon") || driverID.equals("perez")) {
              // Pink
              clr = color(245, 150, 200);
            } else if (driverID.equals("sirotkin") || driverID.equals("stroll")) {
              // White and Blue
              clr = color(255, 255, 255);
            }
          }
          
        float[] rounds = new float[pointsPerRaceMap.get(driverID).length];
        for(int t = 0; t < rounds.length; t++) {
           rounds[t] = t + 1;
        }
        
        charts.get(driverID).setLineColour(clr);
        charts.get(driverID).setData(rounds, pointsPerRaceMap.get(driverID));
        
        if(!axisShown) {
          // Axis formatting and labels.
          charts.get(driverID).showXAxis(true); 
          charts.get(driverID).showYAxis(true); 
          charts.get(driverID).setYFormat("# Points");
        }
        else {
          charts.get(driverID).showXAxis(false); 
          charts.get(driverID).showYAxis(false); 
        }
          
        // Symbol colours
         fill(255);
        charts.get(driverID).setPointColour(255);
        charts.get(driverID).setPointSize(5);
        charts.get(driverID).setAxisLabelColour(255);
        charts.get(driverID).setAxisColour(255);
        charts.get(driverID).setAxisValuesColour(255);
        charts.get(driverID).setMinY(0);
        charts.get(driverID).setMaxY(25);
        charts.get(driverID).setMaxX(21);
        charts.get(driverID).setMinX(1);
        stroke(255);
        charts.get(driverID).setShowEdge(true);
        charts.get(driverID).setLineWidth(2);
        charts.get(driverID).draw(15, 140, 1450, canvasHeight - 170);
        
        // Title
        textFont(titleFont);
        text("Formula 1 Driver Statistics Per Race", 140, 80);
        float textHeight = textAscent();
        textFont(smallFont);
        text("Season " + season, 140, 80 + textHeight);
        textSize(25);
      }
    }
    idx++;
  }
}

void mouseReleased() {
  doOnce = false;
}


// General Pitstops
int maxDistance = canvasWidth - 200;
void page8() {
  if (!dataLoaded) {
    if(cp5.get("barCircuit") != null) cp5.get("barCircuit").show();
    background(255);
    // Default round is the first
    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/" + selectedRound + "/pitstops.json").getJSONObject("MRData"); //TODO change year
    JSONArray pitstopsJSON = ((JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0)).getJSONArray("PitStops");
    // Driver details
    JSONArray driversJSON = loadJSONObject(apiURL + selectedSeason + "/drivers.json").getJSONObject("MRData").getJSONObject("DriverTable").getJSONArray("Drivers"); 

    // driverID key and name as value
    Map<String, JSONObject> driversMap = new HashMap<String, JSONObject>();

    // Find the name of the driver
    for (int j = 0; j < driversJSON.size(); j++) {
      JSONObject driverJSON = (JSONObject) driversJSON.get(j); 
      driversMap.put(driverJSON.getString("driverId"), driverJSON);
    }


    float[] durations = new float[pitstopsJSON.size()];
    float maxValue = 0, minValue = 0;
    driverCircles = new ArrayList<DriverCircle>();
    for (int i = 0; i < pitstopsJSON.size(); i++) {
      JSONObject pitstopJSON = (JSONObject) pitstopsJSON.get(i);
      String driverID = pitstopJSON.getString("driverId");
      String lap = pitstopJSON.getString("lap");
      String time = pitstopJSON.getString("time");
      float duration = pitstopJSON.getFloat("duration");
      // Get driver name
      String driverName = driversMap.get(driverID).getString("familyName");
      String driverCode = driversMap.get(driverID).getString("code");

      for (int j = 0; j < pitstopsJSON.size(); j++) {
        JSONObject currentPitstop = (JSONObject) pitstopsJSON.get(j);

        if (driverID.equals(currentPitstop.getString("driverId"))  && i != j) {
          duration += currentPitstop.getFloat("duration");
          pitstopsJSON.remove(j);
        }
      }

      int posY = 75 + 800/pitstopsJSON.size() * i;

      DriverCircle driverCircle = new DriverCircle(driverID, driverName, driverCode, lap, time, duration, 0, posY);

      driverCircles.add(driverCircle);


      if (durations[i] > maxValue) maxValue = durations[i];

      if (durations[i] < minValue) minValue = durations[i];


      minValue = durations[i];
    }

    // Show Circuits on bottom
    circuitBar();

    dataLoaded = true;
  }
  // Background
  background(255);
  tint(255, 230);
  image(pitStopImg, 0, 0);
  textSize(18);

  stroke(0);
  // Draw teams on the right
  // Show the legend on the right
  // Light blue
  fill(0, 210, 190);
  rect(1450, 200, 20, 20);
  text("Mercedes", 1500, 215);
  // Red
  fill(220, 0, 0);
  rect(1450, 250, 20, 20);
  text("Ferrari", 1500, 265);
  // White and Red
  fill(155, 0, 0);
  rect(1450, 300, 20, 20);
  text("Sauber", 1500, 315);
  // Blue
  fill(0, 50, 255);
  rect(1450, 350, 20, 20);
  text("Toro Rosso", 1500, 365);
  // Grey
  fill(90, 90, 90);
  rect(1450, 400, 20, 20);
  text("Haas", 1500, 415);
  // Yellow
  fill(255, 245, 0);
  rect(1450, 450, 20, 20);
  text("Renault", 1500, 465);
  // Purple
  fill(0, 50, 125);
  rect(1450, 500, 20, 20);
  text("Red Bull", 1500, 515);
  // Pink
  fill(245, 150, 200);
  rect(1450, 550, 20, 20);
  text("Force India", 1500, 565);
  // White and Blue
  fill(255, 255, 255);
  rect(1450, 600, 20, 20);
  text("Williams", 1500, 615);
  // Light blue
  fill(0, 210, 190);

  // For each driver
  int circleSize = 35;
  float best = Integer.MAX_VALUE, worst = 0;
  String teamBest = "", teamWorst = "";
  for (DriverCircle driverCircle : driverCircles) {
    stroke(0);
    // Depending on the driver, change it's color
    if (driverCircle.driverID.equals("alonso") || driverCircle.driverID.equals("vandoorne")) {
      // Orange
      fill(255, 135, 0);
    } else if (driverCircle.driverID.equals("bottas") || driverCircle.driverID.equals("hamilton")) {
      // Light blue
      fill(0, 210, 190);
    } else if (driverCircle.driverID.equals("vettel") || driverCircle.driverID.equals("raikkonen")) {
      // Red
      fill(220, 0, 0);
    } else if (driverCircle.driverID.equals("ericsson") || driverCircle.driverID.equals("leclerc")) {
      // White and Red
      fill(155, 0, 0);
    } else if (driverCircle.driverID.equals("gasly") || driverCircle.driverID.equals("brendon_hartley")) {
      // Blue
      fill(0, 50, 255);
    } else if (driverCircle.driverID.equals("grosjean") || driverCircle.driverID.equals("kevin_magnussen")) {
      // Grey
      fill(90, 90, 90);
    } else if (driverCircle.driverID.equals("hulkenberg") || driverCircle.driverID.equals("sainz")) {
      // Yellow
      fill(255, 245, 0);
    } else if (driverCircle.driverID.equals("ricciardo") || driverCircle.driverID.equals("max_verstappen")) {
      // Purple
      fill(0, 50, 125);
    } else if (driverCircle.driverID.equals("ocon") || driverCircle.driverID.equals("perez")) {
      // Pink
      fill(245, 150, 200);
    } else if (driverCircle.driverID.equals("sirotkin") || driverCircle.driverID.equals("stroll")) {
      // White and Blue
      fill(255, 255, 255);
    }

    // Draw a circle for each driver
    ellipse(driverCircle.posX, driverCircle.posY, circleSize, circleSize);
    text(driverCircle.driverCode, driverCircle.posX - 60, driverCircle.posY);

    // Make animation between 0 and time lost in pitstops
    driverCircle.posX += 90/driverCircle.duration;

    // If the user hovers, show details about the pitstop
    float dist = dist(mouseX, mouseY, driverCircle.posX, driverCircle.posY);

    // Mouse inside circle
    if (dist < circleSize/2) {
      line(driverCircle.posX, driverCircle.posY, driverCircle.posX - 100, driverCircle.posY - 20);
      stroke(255);
      fill(255);
      textSize(25);
      text(driverCircle.duration + "s", driverCircle.posX - 170, driverCircle.posY - 20);
      textSize(18);
    }

    // If the ellipse ends
    if (driverCircle.posX > maxDistance) {
      driverCircle.posX = maxDistance;
    }

    if (worst < driverCircle.duration) {
      worst = driverCircle.duration;
      teamWorst = driverCircle.driverName;
    }
    if (best > driverCircle.duration) {
      best = driverCircle.duration;
      teamBest = driverCircle.driverName;
    }
  }
  // Best and Worst
  textSize(22);
  fill(0, 255, 0);
  text("Best: " + best + " (" + teamBest + ")", 1000, 50);
  fill(255, 0, 0);
  text("Worst: " + worst + " (" + teamWorst + ")", 1300, 50);
}

void loadCircuitPointOnMap() {
  String[] lines = loadStrings("circuitLocations.txt");
  for (String line : lines) {
    String[] params = line.split(";");
    MapPosition mapPosition = new MapPosition(Float.parseFloat(params[1]), Float.parseFloat(params[2]));
    // Key
    String circuitID = params[0];
    mapPositions.put(circuitID, mapPosition);

    println("Map position for " + circuitID + " loaded -> X: " + mapPosition.getX() + " ,Y: " + mapPosition.getY());
  }
}

void circuitBar() {

  if (cp5.get("barCircuit") == null) {
    ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());

    circuitBar = cp5.addButtonBar("barCircuit")
      .setPosition(0, canvasHeight - 30)
      .setSize(canvasWidth, 30)
      .setColorBackground(0)
      .setColorActive(red)
      .setColorForeground(lighterRed)
      .addItems(circuitNames);
  }
}

void circuitBar3() {

  if (cp5.get("barCircuit") == null) {
    ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());

    circuitBar = cp5.addButtonBar("barCircuit3")
      .setPosition(0, canvasHeight - 30)
      .setSize(canvasWidth, 30)
      .setColorBackground(0)
      .setColorActive(red)
      .setColorForeground(lighterRed)
      .addItems(circuitNames);
  }
}

void circuitBar2() {

  if (cp5.get("barCircuit2") == null) {
    ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());

    circuitBar = cp5.addButtonBar("barCircuit2")
      .setPosition(0, canvasHeight - 30)
      .setSize(canvasWidth, 30)
      .setColorBackground(0)
      .setColorActive(red)
      .setColorForeground(lighterRed)
      .addItems(circuitNames);
  }
}

void barCircuit2(int circuitIndex) {
  ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());
  println();
  String circuitID = circuitNames.get(circuitIndex);

  // go to the circuit in the map 
  MapPosition mapPosition = mapPositions.get(circuitID);
  Location mapLocation = new Location(mapPosition.getX(), mapPosition.getY());
  unfoldingMap.zoomAndPanTo(mapLocation, 6);
}

// Call back event of menu bar
void barCircuit(int circuitIndex) {
  println(circuitIndex);
  ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());
  println(circuitNames.get(circuitIndex));

  // Get Round from API
  JSONObject data = loadJSONObject(apiURL + selectedSeason + "/races.json").getJSONObject("MRData"); //TODO change year
  JSONArray racesJSON = data.getJSONObject("RaceTable").getJSONArray("Races");

  for (int i = 0; i < racesJSON.size(); i++) {
    JSONObject raceJSON = (JSONObject) racesJSON.get(i);
    if (raceJSON.getJSONObject("Circuit").getString("circuitId").equals(circuitNames.get(circuitIndex))) {
      selectedRound = raceJSON.getString("round");

      println(selectedRound);

      // Reload data
      dataLoaded = false;
    }
  }
}

// Call back event of menu bar
void barCircuit3(int circuitIndex) {
  println(circuitIndex);
  ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());
  println(circuitNames.get(circuitIndex));

  // Get Round from API
  JSONObject data = loadJSONObject(apiURL + selectedSeason + "/races.json").getJSONObject("MRData"); //TODO change year
  JSONArray racesJSON = data.getJSONObject("RaceTable").getJSONArray("Races");

  for (int i = 0; i < racesJSON.size(); i++) {
    JSONObject raceJSON = (JSONObject) racesJSON.get(i);
    if (raceJSON.getJSONObject("Circuit").getString("circuitId").equals(circuitNames.get(circuitIndex))) {
      selectedRace = raceJSON;
      // Reload data
      dataLoaded = false;
    }
  }
}

class Status implements Comparable<Status> {
  String  status;
  float count;

  public Status(String status, float count) {
    this.status = status;
    this.count = count;
  }

  @Override
    public int compareTo(Status s) {  
    if (s != null) {
      if (this.count > s.count) {
        return 1;
      } else if (this.count < s.count) {
        return -1;
      }
    }

    return 0;
  }
}

class ConstructorStandings implements Comparable<ConstructorStandings> {
  String  constructor;
  String points;
  String wins;

  public ConstructorStandings(String constructor, String points, String wins) {
    this.constructor = constructor;
    this.points = points;
    this.wins = wins;
  }

  @Override
    public int compareTo(ConstructorStandings s) {        
    int points = Integer.parseInt(s.points);
    int p = Integer.parseInt(this.points);
    if (p > points) {
      return 1;
    } else if (p < points) {
      return -1;
    }

    return 0;
  }
}


class DriverPitStops implements Comparable<DriverPitStops> {
  String  driverName;
  float duration;

  public DriverPitStops(String driverName, float duration) {
    this.driverName = driverName;
    this.duration = duration;
  }

  @Override
    public int compareTo(DriverPitStops s) {        
    if (this.duration > s.duration) {
      return 1;
    } else if (this.duration < s.duration) {
      return -1;
    }

    return 0;
  }
}
