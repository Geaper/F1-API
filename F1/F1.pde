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
private boolean videoRunning = false;
private ControlP5 cp5;
// PitStop plot
private GPlot plot;
private BarChart pitStopBarChart;

// API URL
private static final String apiURL = "https://ergast.com/api/f1/";

// Graphs
private BarChart finishStatusBarChart;

private JSONArray racesJSON;
private JSONArray driversJSON;
private JSONArray constructorsJSON;

private HashMap<String, JSONObject> circuitsMap = new HashMap<String, JSONObject>();
private HashMap<String, JSONObject> racesMap = new HashMap<String, JSONObject>();

private ButtonBar buttonBar;

private int currentPage = 0;

// Images
private PImage f1Logo;
private PImage f1Background;
private PImage f1Img1, f1Img2, f1Img3, f1Img4, f1Img5, f1Img6;
private PImage ipcaLogo;

// Default settings
private final int canvasWidth = 1600;
private final int canvasHeight = 900;

// Buttons

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
  // TODO MAKE ALL PAGE TRANSITIONS
  println(pageIndex);
  switch(pageIndex) {
  case 0:
    currentPage = 0;
    break;
  case 2:
    currentPage = 7;
    break;
  case 4:
    currentPage = 6;
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
  smooth();  // instrucao para suavisar graficos em todo o programa

  unfoldingMap = new UnfoldingMap(this);
  unfoldingMap.setTweening(true);
  unfoldingMap.zoomToLevel(3);

  MapUtils.createDefaultEventDispatcher(this, unfoldingMap);

  // Menu Names
  ArrayList<String> menuNames = new ArrayList<String>();
  menuNames.add("Main Menu");
  menuNames.add("Circuits");
  menuNames.add("Drivers");
  menuNames.add("Constructors");
  menuNames.add("Finish Statistics");
  menuNames.add("Lap Times");

  // Button Bar
  buttonBar = cp5.addButtonBar("bar")
    .setPosition(0, 0)
    .setSize(canvasWidth, 20)
    .addItems(menuNames);

  // Load Map positions
  loadCircuitPointOnMap();

  // Load all videos
  String[] fileNames = listFileNames(sketchPath() + "/data/circuit_videos");
  println("Loading Videos");
  for (String fileName : fileNames) {
    // remove extension
    String circuitID = fileName.split("\\.")[0];
    // Load videos
    video = new Movie(this, "circuit_videos/" + circuitID + ".mp4");
    circuitVideos.put(circuitID, video);
  }

  // Load All Flag Images
  fileNames = listFileNames(sketchPath() + "/img/flags");
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
  ipcaLogo = loadImage("img/common/ipca.png");
  f1Img1 = loadImage("img/common/f1-background2.jpg");
  f1Img2 = loadImage("img/common/f1-circuit-background.jpg");
  f1Img3 = loadImage("img/common/f1-drivers-background.jpg");
  f1Img4 = loadImage("img/common/f1-finishStatus-background.jpg");
  f1Img5 = loadImage("img/common/f1-constructors-background.jpg");
  f1Img6 = loadImage("img/common/f1-pitstops-background.jpg");

  // Fonts
  font1 = createFont("Arial", 40);
  font2 = createFont("Arial Bold", 42);
  titleFont = loadFont("Helvetica-22.vlw");
  smallFont = loadFont("Helvetica-12.vlw");
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
}

// Page 0
void page0() {
  buttonBar.hide();
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

void page99() {

  image(f1Img1, 0, 0, canvasWidth, canvasHeight);

  // Hide controls
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();
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
  background(255);
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

    // Marker Image
    markerImage = loadImage("img/common/marker.png");
    markerImage.resize((int)(markerImage.width * 0.005), (int) (markerImage.height * 0.005));

    dataLoaded = true;
  }

  // Loop through the circuits
  for (Map.Entry raceEntry : racesMap.entrySet()) {
    JSONObject raceJSON = (JSONObject) raceEntry.getValue();
    JSONObject circuitJSON = raceJSON.getJSONObject("Circuit");
    String circuitID = (String) circuitJSON.getString("circuitId");

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

      // Title on top of the video
      textSize(22);
      text(circuitJSON.getString("circuitName"), 150, 135);

      video = circuitVideos.get(circuitID);
      image(video, 50, 150, video.width * 0.75, video.height * 0.75);
      video.loop();
      videoRunning = true;

      // Border on t

      // When the user clicks this circle, change page
      if (mousePressed) {
        dataLoaded = false;
        currentPage = 2;
        // "Pass" selectedCircuitID
        selectedRace = raceJSON;
      }
    } else {
      // TODO BUG!!
      if (videoRunning) {
        // Stop video
        //video.pause();
        videoRunning = false;
      }
    }
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

    println(circuitID);

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
}

// Constructor Details
void page5() {
  background(0);

  // Hide Controlp5
  if (cp5.get("Driver Standings") != null) cp5.get("Driver Standings").hide();
  if (cp5.get("season") != null) cp5.get("season").hide();

  String constructorID = selectedConstructor.getString("name");
  text(constructorID, canvasWidth/2, 20);
  PImage constructorImage = loadImage("/img/constructors/" + selectedConstructor.getString("constructorId") + ".png");
  constructorImage.resize(300, 200);
  image(constructorImage, 30, 100);
}

// Finish Status
void page6() {
  if (!dataLoaded) {
    background(255);
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
    Status[] statusArray = new Status[finishStatusesJSON.size()];

    for (int i = 0; i < finishStatusesJSON.size(); i++) {
      JSONObject finishStatusJSON = (JSONObject) finishStatusesJSON.get(i);
      float count = finishStatusJSON.getFloat("count"); 
      String status = finishStatusJSON.getString("status");
      totalCount += count;


      Status statusObj = new Status(status, count);

      // Max value of the table
      if (maxValue < count) maxValue = count;

      statusArray[i] = statusObj;
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
    finishStatusBarChart.setBarColour(countData, ColourTable.getPresetColourTable(ColourTable.REDS, - maxValue, maxValue));


    dataLoaded = true;

    for (int i = 0; i < finishStatusesJSON.size(); i++) {  
      JSONObject finishStatusJSON = (JSONObject) finishStatusesJSON.get(i);
      float count = finishStatusJSON.getFloat("count");
      String status = finishStatusJSON.getString("status");

      // Normalize to 360
      count = (count*360)/totalCount;

      color randomColor = color(random(255), random(255), random(255), random(255));
      fill(randomColor); 
      arc(width/2, height/2, 400, 400, lastAngle, lastAngle + radians(count));
      lastAngle += radians(count);   

      // Description on the right
      rect(canvasWidth - 200, i * 20 + 150, 20, 20);
      textSize(16);
      text(status, canvasWidth - 175, i * 20 + 150);
    }
  }
  background(255);
  finishStatusBarChart.draw(20, 20, width-40, height-40);
  fill(120);
  textFont(titleFont);
  text("Formula 1 Finish Statistics", 70, 100);
  float textHeight = textAscent();
  textFont(smallFont);
  text("All time finish statistics", 70, 100 + textHeight);
}

// Drivers
void page7() {
  if (!dataLoaded) {
    background(255);
    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/drivers.json").getJSONObject("MRData"); //TODO change year
    driversJSON = data.getJSONObject("DriverTable").getJSONArray("Drivers");

    for (int i=0; i < driversJSON.size(); i++) {
      JSONObject driverJSON = (JSONObject) driversJSON.get(i);
      String driverName = driverJSON.getString("givenName") + " " + driverJSON.getString("familyName");
      String driverID = driverJSON.getString("driverId");
      println(driverName);
      println(driverID);
      println(driverJSON.getString("nationality"));

      PImage driverImage = driverImages.get(driverID);
      driverImage.resize(100, 100);
      image(driverImage, i * 100 + 100, 100);
    }

    dataLoaded = true;
  }

  // For each one of them show details on the bottom and enable to user to click them to see the details
  for (int i=0; i < driversJSON.size(); i++) {
    JSONObject driverJSON = (JSONObject) driversJSON.get(i);
    // If hover
    if (mouseX < i*100 + 200 && mouseX > i*100 + 100 && mouseY > 100 && mouseY < 200) {
      // On hover show details
      String driverName = driverJSON.getString("givenName") + " " + driverJSON.getString("familyName");
      String driverCode = driverJSON.getString("code");
      String dateOfBirth = driverJSON.getString("dateOfBirth");
      String nationality = driverJSON.getString("nationality");
      String driverID = driverJSON.getString("driverId");
      String number = driverJSON.getString("permanentNumber");

      PImage flagImage = flagImages.get(nationality);
      flagImage.resize(75, 50);
      image(flagImage, 100, 500);

      PImage driverImage = driverImages.get(driverID);
      driverImage.resize(100, 100);
      image(driverImage, 50, 500);

      // Details
      text(driverName, 150, 500);
      text(driverCode, 170, 500);
      text(dateOfBirth, 150, 600);
      if (number != null) text(number, 200, 600);

      // If users clicks it, redirect to the driver details
      if (mousePressed) {
        selectedDriver = driverJSON;
        currentPage = 3;
      }
    }
  }
}

// General Pitstops
void page8() {
  if (!dataLoaded) {
    background(255);
    // Default round is the first
    String round = "1";
    JSONObject data = loadJSONObject(apiURL + selectedSeason + "/" + round + "/pitstops.json").getJSONObject("MRData"); //TODO change year
    JSONArray pitstopsJSON = ((JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0)).getJSONArray("PitStops");
    // Driver details
    JSONArray driversJSON = loadJSONObject(apiURL + selectedSeason + "/drivers.json").getJSONObject("MRData").getJSONObject("DriverTable").getJSONArray("Drivers"); 

    // driverID key and name as value
    Map<String, String> driverNamesMap = new HashMap<String, String>();

    // Find the name of the driver
    for (int j = 0; j < driversJSON.size(); j++) {
      JSONObject driverJSON = (JSONObject) driversJSON.get(j); 
      driverNamesMap.put(driverJSON.getString("driverId"), driverJSON.getString("familyName"));
    }


    float[] durations = new float[pitstopsJSON.size()];
    String[] driverNames = new String[pitstopsJSON.size()];
    float maxValue = 0, minValue = 0;
    DriverPitStops[] driverPitStops = new DriverPitStops[pitstopsJSON.size()];
    for (int i = 0; i < pitstopsJSON.size(); i++) {
      JSONObject pitstopJSON = (JSONObject) pitstopsJSON.get(i);
      String driverID = pitstopJSON.getString("driverId");
      String lap = pitstopJSON.getString("lap");
      String time = pitstopJSON.getString("time");
      durations[i] = pitstopJSON.getFloat("duration");

      // Get driver name
      driverNames[i] = driverNamesMap.get(driverID);


      if (durations[i] > maxValue) maxValue = durations[i];

      if (durations[i] < minValue) minValue = durations[i];


      minValue = durations[i];

      driverPitStops[i] = new DriverPitStops(driverNames[i], durations[i]);
    }

    Arrays.sort(driverPitStops);
    
    for (int i = 0; i < driverPitStops.length; i++) {
      driverNames[i] = driverPitStops[i].driverName;
      durations[i] = driverPitStops[i].duration;
    }


    pitStopBarChart = new BarChart(this);
    pitStopBarChart.setData(durations);

    // Scaling
    pitStopBarChart.setMinValue(minValue - 1);
    pitStopBarChart.setMaxValue(maxValue);

    // Axis appearance
    textFont(createFont("Serif", 10), 10);

    pitStopBarChart.showValueAxis(true);
    pitStopBarChart.setBarLabels(driverNames);
    pitStopBarChart.showCategoryAxis(true);
    pitStopBarChart.setBarColour(durations, ColourTable.getPresetColourTable(ColourTable.BLUES, minValue, maxValue));

    seasonSlider();

    dataLoaded = true;
  }

  pitStopBarChart.draw(20, 20, width-40, height-40);
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

class Status implements Comparable<Status> {
  String  status;
  float count;

  public Status(String status, float count) {
    this.status = status;
    this.count = count;
  }

  @Override
    public int compareTo(Status s) {        
    if (this.count > s.count) {
      return 1;
    } else if (this.count < s.count) {
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
