import java.util.Map;

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

// Default settings
private final int canvasWidth = 1600;
private final int canvasHeight = 900;

// Buttons

// Selected Race
private JSONObject selectedRace;


void settings() {
    size(canvasWidth, canvasHeight);
}

void setup() {
  
  // Get necessary data from the API
  // Load All the Circuits
  JSONObject data = loadJSONObject(apiURL + "2018.json").getJSONObject("MRData"); //TODO change year
  racesJSON = data.getJSONObject("RaceTable").getJSONArray("Races");
  // Put them into the hashmap
  for(int i = 0; i < racesJSON.size(); i++) {
     String round = racesJSON.getJSONObject(i).getString("round");
     JSONObject raceJSON = racesJSON.getJSONObject(i);
     JSONObject circuitJSON = racesJSON.getJSONObject(i).getJSONObject("Circuit");
     String circuitID = circuitJSON.getString("circuitId"); // Key
     // TODO For now only add Brazil)
     if(circuitID.equals("interlagos")) {
       // Add map coordinates to JSON
       // Load coordinates from file
       circuitJSON.setInt("mapX", 1073);
       circuitJSON.setInt("mapY", 760);
       
       circuitsMap.put(circuitID, circuitJSON); // Add to Collection
       racesMap.put(round, raceJSON); // Add to collection
     }
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
    shape(map, canvasWidth/2, canvasHeight/2, canvasWidth/2, canvasHeight/2);
    fill(255,0,0);    
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
        line(mapX, mapY, 430, 480);
        text(circuitJSON.getString("circuitName"), 410, 490);
        // Show Circuit Image
        PImage circuitImage = loadImage("/img/circuits/" + circuitID + ".png");
        if(circuitImage != null) {
          circuitImage.resize(200,200);
          image(circuitImage, 410, 520);
          
          // When the user clicks this circle, change page
          if(mousePressed) currentPage = 2;
          
          // "Pass" selectedCircuitID
          selectedRace = raceJSON;
        }
      }
   }
}

void page2() {
   background(255);
   JSONObject circuitJSON = selectedRace.getJSONObject("Circuit");
   text(circuitJSON.getString("circuitName"), canvasWidth/2, 30); // title
   PImage circuitImage = loadImage("img/circuits/" + circuitJSON.getString("circuitId") + ".png");
   circuitImage.resize(canvasWidth/2,canvasHeight/2);
   image(circuitImage,canvasWidth/2,canvasHeight/2);   
   // Buttons For each Season
   
   // When the User clicks the season, show the standings for this year on this circuit
   
}
