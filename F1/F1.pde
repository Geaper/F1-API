import java.util.Map;

// API URL
private static final String apiURL = "https://ergast.com/api/f1/";
private JSONArray circuitsJSON;

private HashMap<String, JSONObject> circuitsMap = new HashMap<String, JSONObject>();


private int currentPage = 0;

// Images
private PShape map;
private PImage f1Logo;
private PImage f1Background;

// Default settings
private final int canvasWidth = 1600;
private final int canvasHeight = 900;

// Buttons

// Current Circuit
private String currentCircuitID;


void settings() {
    size(canvasWidth, canvasHeight);
}

void setup() {
  
  // Get necessary data from the API
  // Load All the Circuits
  JSONObject data = loadJSONObject(apiURL + "circuits.json").getJSONObject("MRData");
  circuitsJSON = data.getJSONObject("CircuitTable").getJSONArray("Circuits");
  // Put them into the hashmap
  for(int i = 0; i < circuitsJSON.size(); i++) {
     JSONObject circuitJSON = circuitsJSON.getJSONObject(i);
     String circuitID = circuitJSON.getString("circuitId"); // Key
     // Add map coordinates to JSON
     circuitJSON.setInt("mapX", 550);
     circuitJSON.setInt("mapY", 625);
     
     circuitsMap.put(circuitID, circuitJSON); // Add to Collection
  }
 
  // Common Stuff
  map = loadShape("img/common/world-map.svg");
  f1Logo = loadImage("img/common/f1-logo.png");
  f1Background = loadImage("img/common/f1-background.jpg");
}

void draw() {
  // Pages
  switch(currentPage) {
    case 0:
      page0();
    break;
    case 1:
      page1();
    break;
    case 2:
      page2();
    break;
    default:
      page0();
    break;
  }
  // Debug
  fill(255,0,0);
  text("X: " + mouseX + " ,Y: " + mouseY, canvasWidth - 200, 40);
}

// Page 0
void page0() {
    // Load Images
    f1Background.resize(canvasWidth, canvasHeight);
    image(f1Background, 0, 0);
    f1Logo.resize(150,50);
    image(f1Logo, 0, 0);
    // Made by
    fill(255);
    textSize(32);
    text("Made By:", 10, height/2);
    textSize(16);
    text("Tiago Silva", 10, height/2 +30);
    text("André Monteiro:", 10, height/2 +60);
    
    // When user clicks any key, go to the next page
    if(keyPressed || mousePressed) currentPage = 1;
}

// Page 1
void page1() {
    background(255);
    // Load images
    shape(map, 0, 0, canvasWidth, canvasHeight);
    fill(255,0,0);    
    // Loop through the circuits
    for(Map.Entry circuitEntry : circuitsMap.entrySet()) {
      String circuitID = (String) circuitEntry.getKey(); // Key
      JSONObject circuitJSON = (JSONObject) circuitEntry.getValue(); // JSONObject
      // Get coordinates
      int mapX = (int) circuitJSON.get("mapX");
      int mapY = (int) circuitJSON.get("mapY");
      // Draw points on the map
      ellipse(mapX, mapY, 15, 15);
    }
}

void page2() {
   background(255);
   PImage circuitImage = loadImage("img/circuits/" + currentCircuitID + ".png");
   circuitImage.resize(canvasWidth,canvasHeight);
   image(circuitImage,0,0);   
   // Buttons For each Season
   
   // When the User clicks the season, show the standings for this year on this circuit
   
}
