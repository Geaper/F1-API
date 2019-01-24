import java.util.Map;
import controlP5.*;

private ControlP5 cp5;

// API URL
private static final String apiURL = "https://ergast.com/api/f1/";

private JSONArray racesJSON;

private HashMap<String, JSONObject> circuitsMap = new HashMap<String, JSONObject>();
private HashMap<String, JSONObject> racesMap = new HashMap<String, JSONObject>();


private int currentPage = 0;

// Images
private PShape map;
private PImage f1Logo;
private PImage f1Background;
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
// Driver Images
private Map<String, PImage> driverImages = new HashMap<String, PImage>();
// Circuit Images
private Map<String, PImage> circuitImages = new HashMap<String, PImage>();
// Flags Images
private Map<String, PImage> flagImages = new HashMap<String, PImage>();
// Constructor Images
private Map<String, PImage> constructorImages = new HashMap<String, PImage>();

// Page information loaded?
private boolean dataLoaded = false;

// Results of a race
JSONArray resultsArray;

// Circuit locations on the map
Map<String, MapPosition> mapPositions = new HashMap<String, MapPosition>();

void settings() {
    size(canvasWidth, canvasHeight);
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


void setup() {
  
  // Enable control p5
  cp5 = new ControlP5(this);
  
  // Load Map positions
  loadCircuitPointOnMap();
  
  // Load All Flag Images
  String[] fileNames = listFileNames(sketchPath() + "/img/flags");
  println("Loading Flags");
  for(String fileName : fileNames) {
    // remove extension
    String flagName = fileName.split("\\.")[0];
    flagImages.put(flagName, loadImage(sketchPath() + "/img/flags/" + fileName));
  }
  
  // Load All Circuit Images
  fileNames = listFileNames(sketchPath() + "/img/circuits");
  println("Loading Circuits");
  for(String fileName : fileNames) {
    // remove extension
    String circuitid = fileName.split("\\.")[0];
    circuitImages.put(circuitid, loadImage(sketchPath() + "/img/circuits/" + fileName));
  }
  
  // Load All Driver Images
  fileNames = listFileNames(sketchPath() + "/img/drivers");
  println("Loading Drivers");
  for(String fileName : fileNames) {
    // remove extension
    String driverid = fileName.split("\\.")[0];
    driverImages.put(driverid, loadImage(sketchPath() + "/img/drivers/" + fileName));
  }
  
  // Load All Constructor Images
  fileNames = listFileNames(sketchPath() + "/img/constructors");
  println("Loading Constructors");
  for(String fileName : fileNames) {
    // remove extension
    String constructorid = fileName.split("\\.")[0];
    constructorImages.put(constructorid, loadImage(sketchPath() + "/img/constructors/" + fileName));
  }
  

  // Get necessary data from the API
  // Load All the Circuits
  JSONObject data = loadJSONObject(apiURL + selectedSeason + ".json").getJSONObject("MRData"); 
  racesJSON = data.getJSONObject("RaceTable").getJSONArray("Races");
  // Put them into the hashmap
  for(int i = 0; i < racesJSON.size(); i++) {
     String round = racesJSON.getJSONObject(i).getString("round");
     JSONObject raceJSON = racesJSON.getJSONObject(i);
     JSONObject circuitJSON = racesJSON.getJSONObject(i).getJSONObject("Circuit");
     String circuitID = circuitJSON.getString("circuitId"); // Key
     // Load points from the Map
     MapPosition mapPosition = mapPositions.get(circuitID);
     if(mapPosition != null) {
       // Load coordinates from file
       circuitJSON.setInt("mapX", mapPosition.getX());
       circuitJSON.setInt("mapY", mapPosition.getY());
         
       circuitsMap.put(circuitID, circuitJSON); // Add to Collection
       racesMap.put(round, raceJSON); // Add to collection
     }
  }
 
  // Common Stuff
  map = loadShape("img/common/world-map.svg");
  f1Logo = loadImage("img/common/f1-logo2.png");
  f1Background = loadImage("img/common/f1-background.jpg");
  ipcaLogo = loadImage("img/common/ipca.png");
}

void draw() {
  // Pages
  switch(currentPage) {
    case 0:
      page0(); // Intro
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
    default:
      currentPage = 0; // Default page
      page0();
    break;
  }
  // Debug
  fill(255,0,0);
  textSize(10);
  text("X: " + mouseX + " ,Y: " + mouseY, canvasWidth - 200, 40);
}

// Page 0
void page0() {
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
    if(keyPressed || mousePressed) currentPage = 1;
}

// Page 1
void page1() {
    background(255);
    // Load images
    
    shape(map, 0, 0, canvasWidth, canvasHeight - 100);
    fill(255,0,0);    
    // Title
    textSize(48);
    text("Circuits", canvasWidth/2 -100, 50);
    
    // Season Slider
    if(!dataLoaded) {
      cp5.addSlider("selectedSeason")
       .setPosition(canvasWidth/2 - 250,canvasHeight - 50)
       .setColorBackground(color(255,0,0))
       .setColorActive(color(127,0,0))
       .setColorTickMark(color(0,0,0))
       .setSize(600,50)
       .setRange(2015,2018) // values can range from big to small as well
       .setValue(2015)
       .setNumberOfTickMarks(4)
       .setSliderMode(Slider.FLEXIBLE);
       
       dataLoaded = true;
    }
    
    // Loop through the circuits
    for(Map.Entry raceEntry : racesMap.entrySet()) {
      JSONObject raceJSON = (JSONObject) raceEntry.getValue();
      JSONObject circuitJSON = raceJSON.getJSONObject("Circuit");
      String circuitID = (String) circuitJSON.getString("circuitId");

      // Get coordinates
      int mapX = (int) circuitJSON.get("mapX");
      int mapY = (int) circuitJSON.get("mapY");
      // Draw points on the map
      ellipse(mapX, mapY, 15, 15);
      // On Hover ...
      if(mouseX < mapX + 10 && mouseX > mapX - 10 && mouseY < mapY + 10 && mouseY > mapY- 10) {
        // Expand circle
        ellipse(mapX, mapY, 20, 20); 

        // Some kind of menu interface
        line(mapX, mapY, 200, 600);
        text(circuitJSON.getString("circuitName"), 410, 490);
        // Show Circuit Image
        PImage circuitImage = circuitImages.get(circuitID);
        if(circuitImage != null) {
          circuitImage.resize(200,200);
          image(circuitImage, 200, 600);
          
          // When the user clicks this circle, change page
          if(mousePressed)  {
            dataLoaded = false;
            currentPage = 2;
            // "Pass" selectedCircuitID
            selectedRace = raceJSON;
          }
        }
      }
   }
}

void page2() {
  // If data is not loaded, do it
  if(!dataLoaded) {  
      background(255);
      // Load Circuit
      JSONObject circuitJSON = selectedRace.getJSONObject("Circuit");
      String circuitid = circuitJSON.getString("circuitId");
      PImage circuitImage = circuitImages.get(circuitid);
      circuitImage.resize(canvasWidth/2,canvasHeight/2);
      image(circuitImage,canvasWidth/2,canvasHeight/2);   
      
      // Get Driver standings
     String round = selectedRace.getString("round");
     JSONObject data = loadJSONObject(apiURL + selectedSeason + "/" + round + "/results.json").getJSONObject("MRData");
     JSONObject race = (JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0);
     resultsJSONArray = race.getJSONArray("Results");
     
     ArrayList<String> driverStandingsList = new ArrayList<String>();
     for(int i = 0; i < resultsJSONArray.size(); i++) {
       JSONObject result = (JSONObject) resultsJSONArray.get(i);
       JSONObject driver = result.getJSONObject("Driver");
       String driverID = driver.getString("driverId");
       
       // Driver Name
       String driverName = driver.getString("givenName") + " " + driver.getString("familyName");
       
       // Top 3
       if(i < 3) {
         PImage driverImage = driverImages.get(driverID);
         driverImage.resize(100,100);
         image(driverImage, i * 100, canvasHeight/2);
         // Load Driver flag
         PImage flagImage = flagImages.get(driver.getString("nationality"));
         flagImage.resize(70,50);
         image(flagImage, i *100, canvasHeight/2 + 150);
         // Load Constructors
         JSONObject constructorJSON = result.getJSONObject("Constructor");
         String constructorID = constructorJSON.getString("constructorId");
         PImage constructorImage = constructorImages.get(constructorID);
         constructorImage.resize(70, 50);
         image(constructorImage, i * 100, canvasHeight/2 + 250);
       }
       
       driverStandingsList.add(driverName);
     }
     
       cp5.addScrollableList("Driver Standings")
       .setPosition(0, 0)
       .setSize(300, 600)
       .setColorBackground(color(255, 0,0))
       .setColorActive(color(0))
       .setBarHeight(20)
       .setItemHeight(20)
       .addItems(driverStandingsList);
      
      dataLoaded = true;
  }
  // Create Click events
  for(int i = 0; i < resultsJSONArray.size(); i++) {
    // Driver Image Click
    if(mouseX < i * 100 - 25 && mouseX > i * 100 + 25 && mouseY > canvasHeight/2 - 25 && mouseY < canvasHeight/2 + 25) {
      JSONObject result = (JSONObject) resultsJSONArray.get(i);
      JSONObject driver = result.getJSONObject("Driver");
      selectedDriver = driver;
      currentPage = 3;
    }
  }
}

void page3() {
  background(255);

  String driverName = selectedDriver.getString("givenName") + " " + selectedDriver.getString("familyName");
  // Title
  textSize(32);
  fill(255,0,0);
  text(driverName, canvasWidth/2, 20);
}

void page4()  {
   background(255);

   JSONObject data = loadJSONObject(apiURL + selectedSeason + "/constructors.json").getJSONObject("MRData"); //TODO change year
   JSONArray constructorsJSON = data.getJSONObject("ConstructorTable").getJSONArray("Constructors");
  
   int incr1 = 1, incr2 = 1;
   for(int i = 0; i < constructorsJSON.size(); i++) {
     JSONObject constructorJSON = (JSONObject) constructorsJSON.get(i);
     PImage constructorImage = loadImage("/img/constructors/" + constructorJSON.getString("constructorId") + ".png");
     // TODO
     if(constructorImage == null) { 
       constructorImage = loadImage("/img/constructors/" + constructorJSON.getString("constructorId") + ".jpg");
     }
     
     constructorImage.resize(50, 50);
     // List constructors
     if(i < constructorsJSON.size() / 2) {
       image(constructorImage, incr1 * 100, canvasHeight * .33);
       incr1++;
       
        // When user hovers the constructor image
       if(mouseX < i * 100 + 50 && mouseX > i * 100 -50 && mouseY > canvasHeight * .33 - 50 && mouseY < canvasHeight * .33 +50) {
         // If user clicks on the image
         if(mousePressed)  {
           selectedConstructor = constructorJSON;
           currentPage = 5;
         }
       }
     }
     else if(i >= constructorsJSON.size() / 2 && i < constructorsJSON.size()) {
       image(constructorImage, incr2 * 100, canvasHeight * .66);
       incr2++;
       
       // When user hovers the constructor image
       if(mouseX < i * 100 + 50 && mouseX > i * 100 -50 && mouseY > canvasHeight * .66 - 50 && mouseY < canvasHeight * .66 +50) {
         // If user clicks on the image
         if(mousePressed)  {
           selectedConstructor = constructorJSON;
           currentPage = 5;
         }
       }
     }
   }
}

void page5() {
     background(255);

     String constructorID = selectedConstructor.getString("name");
     text(constructorID, canvasWidth/2, 20);
     PImage constructorImage = loadImage("/img/constructors/" + selectedConstructor.getString("constructorId") + ".png");
     constructorImage.resize(canvasWidth/2, canvasHeight/2);
     image(constructorImage, canvasWidth/2, canvasHeight/2);
}

void page6() {
   background(255);

   JSONObject data = loadJSONObject(apiURL + "status.json").getJSONObject("MRData");
   JSONArray finishStatusesJSON = data.getJSONObject("StatusTable").getJSONArray("Status");
   
   fill(255,0,0);
   // For each Status
   int incr1 = 1, incr2 = 1, incr3 = 1;
   for(int i = 0; i < finishStatusesJSON.size(); i++) {
     JSONObject finishStatusJSON = (JSONObject) finishStatusesJSON.get(i);
     String status = finishStatusJSON.getString("status");
     float count = finishStatusJSON.getFloat("count");
     
     // Create a circle for each status
     // Make smaller rows
     if(i < finishStatusesJSON.size() / 3) {
       ellipse(incr1 * 100, canvasHeight * .25, count * 0.02, count * 0.02);
       text(status, incr1 * 98, canvasHeight * .25 + 100);
       incr1++;
     }
     else if(i >= finishStatusesJSON.size() / 3 && i < finishStatusesJSON.size() / 1.5) {
       ellipse(incr2 * 100, canvasHeight * .50, count * 0.02, count * 0.02);
       text(status, incr2 *98, canvasHeight * .50 + 100);
       incr2++;
     }
     else if(i >= finishStatusesJSON.size() / 1.5 && i <= finishStatusesJSON.size()) {
       ellipse(incr3 * 100, canvasHeight * .75, count * 0.02, count * 0.02);
       text(status, incr3 * 98, canvasHeight * .75 + 100);
       incr3++;
     }
   }
}

void loadCircuitPointOnMap() {
  String[] lines = loadStrings("circuitLocations.txt");
  for(String line : lines) {
    String[] params = line.split(";");
    MapPosition mapPosition = new MapPosition(Integer.parseInt(params[1]), Integer.parseInt(params[2]));
    // Key
    String circuitID = params[0];
    mapPositions.put(circuitID, mapPosition);
    
    println("Map position for " + circuitID + " loaded -> X: " + mapPosition.getX() + " ,Y: " + mapPosition.getY());
  }
}
