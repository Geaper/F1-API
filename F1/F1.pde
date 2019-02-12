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
private XYChart driverPointsLineChart;
private ArrayList<DriverCircle> driverCircles;

private MapPosition currentHoveringMapPos = new MapPosition(0, 0);

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

private ButtonBar buttonBar;
private ButtonBar circuitBar;

private int currentPage = 0;

// Images
private PImage f1Logo;
private PImage f1Background;
private PImage f1Background2;
private PImage f1Img1, f1Img2, f1Img3, f1Img4, f1Img5, f1Img6;
private PImage pitStopImg;
private PImage ipcaLogo;

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
    currentPage = 0;
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

  // Fonts
  font1 = createFont("Arial", 40);
  font2 = createFont("Arial Bold", 42);
  titleFont = createFont("Arial Bold", 42);
  smallFont = createFont("Arial", 30);
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
  if (cp5.get("qualifying") != null) cp5.get("qualifying").hide();
  if (cp5.get("race") != null) cp5.get("race").hide();
  // Load Images
  // Background
  f1Background.resize(canvasWidth, canvasHeight);
  image(f1Background, 0, 0);
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

void seasonSlider() { 
  if(cp5.get("season") != null) {
    cp5.addSlider("season")
      .setPosition(canvasWidth/2 - 250, canvasHeight - 15)
      .setColorBackground(color(255, 0, 0))
      .setColorActive(color(127, 0, 0))
      .setColorTickMark(color(0, 0, 0))
      .setSize(450, 15)
      .setRange(2015, 2018) // values can range from big to small as well
      .setValue(2015)
      .setNumberOfTickMarks(4)
      .setSliderMode(Slider.FLEXIBLE);
    }
}

void page99() {

  image(f1Img1, 0, 0, canvasWidth, canvasHeight);

  // Hide controls
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
  if (cp5.get("qualifying") != null) cp5.get("qualifying").hide();
  if (cp5.get("race") != null) cp5.get("race").hide();
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
  if (cp5.get("season") != null) cp5.get("season").hide();

  //shape(map, 0, 0, canvasWidth, canvasHeight - 100);
  fill(255, 0, 0);    

  // Season Slider
  if (!dataLoaded) {
    seasonSlider();

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
    ellipse(mapPosition.x, mapPosition.y, 0.75 * scale, 0.75 * scale);

    // Pretty?
    //ImageMarker imgMarker1 = new ImageMarker(mapLocation, markerImage);
    //unfoldingMap.addMarkers(imgMarker1);

    // On Hover ...
    if (mouseX < mapPosition.x + 7 && mouseX > mapPosition.x - 7 && mouseY < mapPosition.y + 7 && mouseY > mapPosition.y - 7) {

      circuitHovered[index] = true;

      if (!videoLoaded) {
        println(circuitID);
        video = new Movie(this, "circuit_videos/" + circuitID + ".mp4");
        videoLoaded = true;
      }

      // Title on top of the video
      textSize(22);
      text(circuitJSON.getString("circuitName"), 150, 135);

      image(video, 50, 150, video.width * 0.75, video.height * 0.75);
      video.loop();

      // When the user clicks this circle, change page
      if (mousePressed) {
        dataLoaded = false;
        currentPage = 2;
        // "Pass" selectedCircuitID
        selectedRace = raceJSON;
      }
    } else {
      circuitHovered[index] = false;
      for (boolean b : circuitHovered) { 
        if (b) break;
        else {
          videoLoaded = false;
        }
      }
    }
    index++;
  }
}

// Circuit Details
void page2() {

  // If data is not loaded, do it
  if (!dataLoaded) { 
    background(0);
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

    // Show circuit Details
    text("Circuit Name: " + circuitName, 20, 40);
    text("City: " + city, 20, 30);
    text("Latitude: " + lat + "º", 20, 50);
    text("Longitude: " + longit + "º", 20, 60);
    text("Wikipedia Link: " + wikiURL, 20, 70);
    text("Country: " + circuitCountry, 20, 80);

    // Title
    //cp5.addTextlabel("label").setText(circuitName).setPosition(canvasWidth/2 - 100,30).setColorValue(0xffffff00).setFont(createFont("Georgia",20));


    // Get Driver standings
    String round = selectedRace.getString("round");
    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/" + round + "/results.json").getJSONObject("MRData");
    JSONObject race = (JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0);
    resultsJSONArray = race.getJSONArray("Results");

    ArrayList<String> driverStandingsList = new ArrayList<String>();
    for (int i = 0; i < resultsJSONArray.size(); i++) {
      JSONObject result = (JSONObject) resultsJSONArray.get(i);
      JSONObject driver = result.getJSONObject("Driver");
      String driverID = driver.getString("driverId");

      // Driver Name
      String driverName = driver.getString("givenName") + " " + driver.getString("familyName");

      // Top 3
      if (i < 3) {
        PImage driverImage = driverImages.get(driverID);
        driverImage.resize(100, 100);
        int driverPosX = 0, driverPosY = 0, flagPosX = 0, flagPosY = 0, constructorPosX = 0, constructorPosY = 0;

        switch(i) {
          // First Place
        case 0:
          driverPosX = 1250;
          driverPosY = 150;
          flagPosX = driverPosX;
          flagPosY = 250;
          constructorPosX = driverPosX + 70;
          constructorPosY = flagPosY;
          break;
        case 1:
          driverPosX = 1400;
          driverPosY = 200;
          flagPosX = driverPosX;
          flagPosY = 300;
          constructorPosX = driverPosX + 70;
          constructorPosY = flagPosY;
          break;
        case 2:
          driverPosX = 1100;
          driverPosY = 200;
          flagPosX = driverPosX;
          flagPosY = 300;
          constructorPosX = driverPosX + 70;
          constructorPosY = flagPosY;
          break;
        }

        image(driverImage, driverPosX, driverPosY);

        // Load Driver flag
        PImage flagImage = flagImages.get(driver.getString("nationality"));
        flagImage.resize(35, 25);
        image(flagImage, flagPosX, flagPosY);

        // Load Constructors
        JSONObject constructorJSON = result.getJSONObject("Constructor");
        String constructorID = constructorJSON.getString("constructorId");
        PImage constructorImage = constructorImages.get(constructorID);
        constructorImage.resize(35, 25);
        image(constructorImage, constructorPosX, constructorPosY);
      }
      driverStandingsList.add(driverName + " | " + result.getString("status"));
    }

    cp5.addScrollableList("Driver Standings")
      .setPosition(0, 350)
      .setSize(450, 450)
      .setColorBackground(color(255, 0, 0))
      .setColorActive(color(0))
      .setBarHeight(30)
      .setItemHeight(30)
      .addItems(driverStandingsList);

    seasonSlider();

    // Buttons for Qualifying and Race
    cp5.addButton("qualifying").setPosition(100, 100).setSize(100, 75);
    cp5.addButton("race").setPosition(200, 100).setSize(100, 75);

    dataLoaded = true;
  }
  // Create Click events
  // For each Driver
  for (int i = 0; i < 3; i++) {

    int driverPosX = 0, driverPosY = 0, constructorPosX = 0, constructorPosY = 0;

    switch(i) {
      // First Place
    case 0:
      driverPosX = 1250;
      driverPosY = 150;
      constructorPosX = driverPosX + 70;
      constructorPosY = 250;
      break;
    case 1:
      driverPosX = 1400;
      driverPosY = 200;
      constructorPosX = driverPosX + 70;
      constructorPosY = 300;
      break;
    case 2:
      driverPosX = 1100;
      driverPosY = 200;
      constructorPosX = driverPosX + 70;
      constructorPosY = 300;
      break;
    }

    // Driver Image Click
    if (mouseX < driverPosX + 100 && mouseX > driverPosX && mouseY < driverPosY + 100 && mouseY > driverPosY) {
      if (mousePressed) {
        JSONObject result = (JSONObject) resultsJSONArray.get(i);
        JSONObject driver = result.getJSONObject("Driver");
        selectedDriver = driver;
        currentPage = 3;
      }
    }
    // Constructor Image Click
    if (mouseX < constructorPosX + 35 && mouseX > constructorPosX && mouseY < constructorPosY + 25 && mouseY > constructorPosY) {
      if (mousePressed) {
        JSONObject result = (JSONObject) resultsJSONArray.get(i);
        JSONObject constructor = result.getJSONObject("Constructor");
        selectedConstructor = constructor;
        currentPage = 5;
      }
    }
  }
  image(video, canvasWidth/2, canvasHeight/2 - 30, canvasWidth/2, canvasHeight/2 - 30);
}

// Driver details
void page3() {
  background(0);

  // Hide Controlp5
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
  if (cp5.get("qualifying") != null) cp5.get("qualifying").hide();
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

// Constructors
void page4() {

  if (!dataLoaded) {
    background(255);

    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/constructors.json").getJSONObject("MRData"); //TODO change year
    constructorsJSON = data.getJSONObject("ConstructorTable").getJSONArray("Constructors");

    int incr1 = 1, incr2 = 1;
    for (int i = 0; i < constructorsJSON.size(); i++) {
      JSONObject constructorJSON = (JSONObject) constructorsJSON.get(i);
      String constructorID = constructorJSON.getString("constructorId");
      PImage constructorImage = constructorImages.get(constructorID);

      constructorImage.resize(50, 50);

      // List constructors
      if (i < constructorsJSON.size() / 2) {
        image(constructorImage, incr1 * 100, canvasHeight * .33);
        incr1++;

        // When user hovers the constructor image
        if (mouseX < i * 100 + 50 && mouseX > i * 100 -50 && mouseY > canvasHeight * .33 - 50 && mouseY < canvasHeight * .33 +50) {
          // If user clicks on the image
          if (mousePressed) {
            selectedConstructor = constructorJSON;
            currentPage = 5;
          }
        }
      } else if (i >= constructorsJSON.size() / 2 && i < constructorsJSON.size()) {
        image(constructorImage, incr2 * 100, canvasHeight * .66);
        incr2++;

        // When user hovers the constructor image
        if (mouseX < i * 100 + 50 && mouseX > i * 100 -50 && mouseY > canvasHeight * .66 - 50 && mouseY < canvasHeight * .66 +50) {
          // If user clicks on the image
          if (mousePressed) {
            selectedConstructor = constructorJSON;
            currentPage = 5;
          }
        }
      }
    }

    // Constructor standings for this year
    data = loadJSONObject(apiURL + selectedSeason + "/constructorStandings.json").getJSONObject("MRData"); //TODO change year
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
    constructorsChart.setBarColour(pointsData, ColourTable.getPresetColourTable(ColourTable.REDS, - maxValue, maxValue));

    dataLoaded = true;
  }
  for (int i = 0; i < constructorsJSON.size(); i++) { 
    JSONObject constructorJSON = (JSONObject) constructorsJSON.get(i);
    // List constructors
    if (i < constructorsJSON.size() / 2) {    
      // When user hovers the constructor image
      if (mouseX < i * 100 + 50 && mouseX > i * 100 -50 && mouseY > canvasHeight * .33 - 50 && mouseY < canvasHeight * .33 +50) {
        // If user clicks on the image
        if (mousePressed) {
          selectedConstructor = constructorJSON;
          currentPage = 5;
        }
      }
    } else if (i >= constructorsJSON.size() / 2 && i < constructorsJSON.size()) {
      // When user hovers the constructor image
      if (mouseX < i * 100 + 50 && mouseX > i * 100 -50 && mouseY > canvasHeight * .66 - 50 && mouseY < canvasHeight * .66 +50) {
        // If user clicks on the image
        if (mousePressed) {
          selectedConstructor = constructorJSON;
          currentPage = 5;
        }
      }
    }
  }
  // draw constructor standings graph
  constructorsChart.draw(20, 20, width-40, height-40);
}

// Constructor Details
void page5() {
  background(0);

  // Hide Controlp5
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
  if (cp5.get("qualifying") != null) cp5.get("qualifying").hide();
  if (cp5.get("race") != null) cp5.get("race").hide();

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
    if (cp5.get("qualifying") != null) cp5.get("qualifying").hide();
    if (cp5.get("race") != null) cp5.get("race").hide();

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

  finishStatusBarChart.draw(20, 60, canvasWidth - 40, canvasHeight-60);
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

// Drivers
void page7() {
  background(38, 24, 34);
  if (!dataLoaded) {
    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/drivers.json").getJSONObject("MRData"); //TODO change year
    driversJSON = data.getJSONObject("DriverTable").getJSONArray("Drivers");

    dataLoaded = true;
  }

  // For each one of them show details on the bottom and enable to user to click them to see the details
  for (int i=0; i < driversJSON.size(); i++) {
    JSONObject driverJSON = (JSONObject) driversJSON.get(i);
    String driverName = driverJSON.getString("givenName") + " " + driverJSON.getString("familyName");
    String driverID = driverJSON.getString("driverId");
    PImage driverImage = driverImages.get(driverID);

    driverImage.resize(150, 190);
    // Makes rows of driver images
    int imgPosX = 0, imgPosY = 0;
    if (i < 5) {
      imgPosX = i * 150 + 800;
      imgPosY = 90;
    } else if (i >= 5 && i < 10) {  
      imgPosX = (i-5) * 150 + 800;
      imgPosY = 280;
    } else if (i >= 10 && i < 15) {
      imgPosX = (i-10) * 150 + 800;
      imgPosY = 470;
    } else {
      imgPosX = (i-15) * 150 + 800;
      imgPosY = 660;
    }

    image(driverImage, imgPosX, imgPosY);


    // If hover
    if (mouseX < imgPosX + 150 && mouseX > imgPosX && mouseY > imgPosY && mouseY < imgPosY + 190) {
      // On hover show details
      String driverCode = driverJSON.getString("code");
      String dateOfBirth = driverJSON.getString("dateOfBirth");
      String nationality = driverJSON.getString("nationality");
      String number = driverJSON.getString("permanentNumber");

      PImage flagImage = flagImages.get(nationality);
      flagImage.resize(75, 50);
      image(flagImage, 35, 500);

      PImage driverImage2 = driverImage.copy();
      driverImage2.resize(300, 400);
      image(driverImage2, 30, 90);

      // Details
      fill(255);
      textSize(32);
      text(driverName, 350, 110);
      text(driverCode, 350, 160);
      text(dateOfBirth, 350, 200);
      if (number != null) {
        textSize(90);
        text(number, 350, 450);
      }

      // Graph showing the points obtained by this driver for the season
      JSONArray dataRaces = loadJSONObject(apiURL + selectedSeason + "/drivers/" + driverID + "/results.json").getJSONObject("MRData").getJSONObject("RaceTable").getJSONArray("Races"); 
      // For each race, get the driver points
      float[] pointsArray = new float[dataRaces.size()];
      float[] roundsArray = new float[dataRaces.size()];
      for (int j = 0; j < dataRaces.size(); j++) {
        JSONObject raceJSON = (JSONObject) dataRaces.get(j);
        float round = Float.parseFloat(raceJSON.getString("round"));
        float points = Float.parseFloat(((JSONObject) raceJSON.getJSONArray("Results").get(0)).getString("points"));
        // Add to array
        roundsArray[i] = round;
        pointsArray[i] = points;
      }

      driverPointsLineChart = new XYChart(this);
      driverPointsLineChart.setData(roundsArray, pointsArray);

      // Axis formatting and labels.
      driverPointsLineChart.showXAxis(true); 
      driverPointsLineChart.showYAxis(true); 

      // Symbol colours
      driverPointsLineChart.setPointColour(color(255));
      driverPointsLineChart.setPointSize(3);
      driverPointsLineChart.setLineWidth(2);

      driverPointsLineChart.draw(15, 500, 500, 400);

      // Draw a title over the top of the chart.
      fill(255);
      textSize(10);
      //text("Income per person, United Kingdom", 25,30);
      textSize(11);
      //text("Gross domestic product measured in inflation-corrected $US", 70,45);

      // If users clicks it, redirect to the driver details
      if (mousePressed) {
        selectedDriver = driverJSON;
        currentPage = 3;
      }
    }
  }
}

// General Pitstops
int maxDistance = canvasWidth - 200;
void page8() {
  if (!dataLoaded) {
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
    
    if(worst < driverCircle.duration) {
      worst = driverCircle.duration;
      teamWorst = driverCircle.driverName;
    }
    if(best > driverCircle.duration) {
      best = driverCircle.duration;
      teamBest = driverCircle.driverName;
    }
  }
    // Best and Worst
    textSize(22);
    fill(0,255,0);
    text("Best: " + best + " (" + teamBest + ")", 1000, 50);
    fill(255,0,0);
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
  
  if(cp5.get("barCircuit") == null) {
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

// Call back event of menu bar
void barCircuit(int circuitIndex) {
  println(circuitIndex);
  ArrayList<String> circuitNames = new ArrayList<String>(circuitsMap.keySet());
  println(circuitNames.get(circuitIndex));
  
  // Get Round from API
  JSONObject data = loadJSONObject(apiURL + selectedSeason + "/races.json").getJSONObject("MRData"); //TODO change year
  JSONArray racesJSON = data.getJSONObject("RaceTable").getJSONArray("Races");
  
  for(int i = 0; i < racesJSON.size(); i++) {
    JSONObject raceJSON = (JSONObject) racesJSON.get(i);
    if(raceJSON.getJSONObject("Circuit").getString("circuitId").equals(circuitNames.get(circuitIndex))) {
      selectedRound = raceJSON.getString("round");
      
      println(selectedRound);
      
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
