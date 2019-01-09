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
// Selected Driver
private JSONObject selectedDriver;
// Selected Constructor
private JSONObject selectedConstructor;


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
      page4(); // Intro
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
   
   // Get Driver standings
   String round = selectedRace.getString("round");
   JSONObject data = loadJSONObject(apiURL + "2018/" + round + "/results.json").getJSONObject("MRData");
   JSONObject race = (JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0);
   JSONArray results = race.getJSONArray("Results");
   
   for(int i = 0; i < results.size(); i++) {
     JSONObject result = (JSONObject) results.get(i);
     JSONObject driver = result.getJSONObject("Driver");
     String driverID = driver.getString("driverId");
     
     // Top 3
     if( i < 3) {
       // Driver Name
       String driverName = driver.getString("givenName") + " " + driver.getString("familyName");
       text(driverName, i *100, canvasHeight/2 - 50);
       PImage driverImage = loadImage("/img/drivers/" + driverID + ".jpg");
       driverImage.resize(100,100);
       image(driverImage, i * 100, canvasHeight/2);
       // Load Driver flag
       PImage flagImage = loadImage("/img/flags/" + driver.getString("nationality") + ".png");
       flagImage.resize(70,50);
       image(flagImage, i *100, canvasHeight/2 + 150);
       // Load Constructors
       JSONObject constructorJSON = result.getJSONObject("Constructor");
       PImage constructorImage = loadImage("/img/constructors/" + constructorJSON.getString("constructorId") + ".png");
       constructorImage.resize(70, 50);
       image(constructorImage, i * 100, canvasHeight/2 + 250);
       
       // When user hovers the driver image
       if(mouseX < i * 100 + 100 && mouseX > i * 100 -100 && mouseY > canvasHeight/2 - 100 && mouseY < canvasHeight/2 +100) {
         // If user clicks on the image
         if(mousePressed)  {
           selectedDriver = driver;
           currentPage = 3;
         }
       }
       // When user hovers the constructor image
       if(mouseX < i * 100 +70 && mouseX > i * 100 -70 && mouseY > canvasHeight/2 - 200 && mouseY < canvasHeight/2 +300) {
         if(mousePressed) {
           selectedConstructor = constructorJSON;
           currentPage = 5;
         }
       }
     }    
   }
}

void page3() {
  background(255);
  String driverName = selectedDriver.getString("givenName") + " " + selectedDriver.getString("familyName");
  text(driverName, canvasWidth/2, 20);
}

void page4()  {
   background(255);
   JSONObject data = loadJSONObject(apiURL + "2018/constructors.json").getJSONObject("MRData"); //TODO change year
   JSONArray constructorsJSON = data.getJSONObject("ConstructorTable").getJSONArray("Constructors");
  
   int incr1 = 1, incr2 = 1;
   for(int i = 0; i < constructorsJSON.size(); i++) {
     JSONObject constructorJSON = (JSONObject) constructorsJSON.get(i);
     PImage constructorImage = loadImage("/img/constructors/" + constructorJSON.getString("constructorId") + ".png"); 
     constructorImage.resize(50, 50);
     // List constructors
     if(i < constructorsJSON.size() / 2) {
       image(constructorImage, incr1 * 100, canvasHeight * .33);
       incr1++;
     }
     else if(i >= constructorsJSON.size() / 2 && i < constructorsJSON.size()) {
       image(constructorImage, incr2 * 100, canvasHeight * .66);
       incr2++;
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
