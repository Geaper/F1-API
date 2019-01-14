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
private String selectedSeason = "2018";

// Circuit locations on the map
Map<String, MapPosition> mapPositions = new HashMap<String, MapPosition>();

// Season buttons
private Button btn2015 = new Button(20, 200, 60, 35, "2015");
private Button btn2016 = new Button(20, 250, 60, 35, "2016");
private Button btn2017 = new Button(20, 300, 60, 35, "2017");
private Button btn2018 = new Button(20, 350, 60, 35, "2018");

void settings() {
    size(canvasWidth, canvasHeight);
}

void setup() {
  
  // Load Map positions
  loadCircuitPointOnMap();

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
      page6(); // Intro
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
    // Back button
    drawBackButton();
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

void drawSeasonButtons() {
   // Season Buttons
    
    btn2015.display();
    if(btn2015.hasClicked()) selectedSeason = "2015";
   
    btn2016.display();
    if(btn2016.hasClicked()) selectedSeason = "2016";
   
    btn2017.display();
    if(btn2017.hasClicked()) selectedSeason = "2017";

    btn2018.display();
    if(btn2018.hasClicked()) selectedSeason = "2018";
    
    // Highlight the selected button
    color buttonColor = color(255,0,0);
    color buttonTextColor = color(255);
    color defaultButtonColor = color(0);
    color defaultButtonTextColor = color(255);
    
    switch(selectedSeason) {
      case "2015":
        btn2015.buttonColor = buttonColor;
        btn2015.buttonTextColor = buttonTextColor;
        btn2016.buttonColor = defaultButtonColor;
        btn2017.buttonColor = defaultButtonColor;
        btn2018.buttonColor = defaultButtonColor;
        btn2016.buttonTextColor = defaultButtonTextColor;
        btn2017.buttonTextColor = defaultButtonTextColor;
        btn2018.buttonTextColor = defaultButtonTextColor;
      break;
       case "2016":
         btn2016.buttonColor = buttonColor;
         btn2016.buttonTextColor = buttonTextColor;
         btn2015.buttonColor = defaultButtonColor;
         btn2017.buttonColor = defaultButtonColor;
         btn2018.buttonColor = defaultButtonColor;
         btn2015.buttonTextColor = defaultButtonTextColor;
         btn2017.buttonTextColor = defaultButtonTextColor;
         btn2018.buttonTextColor = defaultButtonTextColor;
       break;
       case "2017":
         btn2017.buttonColor = buttonColor;
         btn2017.buttonTextColor = buttonTextColor;
         btn2016.buttonColor = defaultButtonColor;
         btn2015.buttonColor = defaultButtonColor;
         btn2018.buttonColor = defaultButtonColor;
         btn2016.buttonTextColor = defaultButtonTextColor;
         btn2015.buttonTextColor = defaultButtonTextColor;
         btn2018.buttonTextColor = defaultButtonTextColor;
       break;
       case "2018":
         btn2018.buttonColor = buttonColor;
         btn2018.buttonTextColor = buttonTextColor;
         btn2016.buttonColor = defaultButtonColor;
         btn2017.buttonColor = defaultButtonColor;
         btn2015.buttonColor = defaultButtonColor;
         btn2016.buttonTextColor = defaultButtonTextColor;
         btn2017.buttonTextColor = defaultButtonTextColor;
         btn2015.buttonTextColor = defaultButtonTextColor;
       break;
    }
}
// Page 1
void page1() {
    background(255);
    // Load images
    
    shape(map, 150, 100, canvasWidth - 150, canvasHeight - 100);
    fill(255,0,0);    
    // Title
    textSize(48);
    text("Circuits", canvasWidth/2 -100, 50);
    
    // Season Buttons
    drawSeasonButtons();
    
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
        PImage circuitImage = loadImage("/img/circuits/" + circuitID + ".png");
        if(circuitImage != null) {
          circuitImage.resize(200,200);
          image(circuitImage, 200, 600);
          
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
    // Back button
    drawBackButton();
   JSONObject circuitJSON = selectedRace.getJSONObject("Circuit");
   // Title
   fill(255,0,0);
   textSize(32);
   String circuitName = circuitJSON.getString("circuitName");
   text(circuitName, canvasWidth/2 - 100, 60); 
   textSize(12);
   // Circuit Image
   PImage circuitImage = loadImage("img/circuits/" + circuitJSON.getString("circuitId") + ".png");
   circuitImage.resize(canvasWidth/2,canvasHeight/2);
   image(circuitImage,canvasWidth/2,canvasHeight/2);   
   // Draw season buttons
   drawSeasonButtons();
   
   // Details page pointing to wiki
   fill(0);
   text("View on Wikipedia", 450, 100);
   if(mouseX < 470 && mouseX > 430 && mouseY > 80 && mouseY < 120) {
     if(mousePressed) {
       link(circuitJSON.getString("url"));
     }
   }
   
   // Get Driver standings
   String round = selectedRace.getString("round");
   JSONObject data = loadJSONObject(apiURL + selectedSeason + "/" + round + "/results.json").getJSONObject("MRData");
   JSONObject race = (JSONObject) data.getJSONObject("RaceTable").getJSONArray("Races").get(0);
   JSONArray results = race.getJSONArray("Results");
   
   for(int i = 0; i < results.size(); i++) {
     JSONObject result = (JSONObject) results.get(i);
     JSONObject driver = result.getJSONObject("Driver");
     String driverID = driver.getString("driverId");
     
     // Display the standings in a "table listing"
     fill(255);
     rect(100, i * 10 + 200, 100, 30);
     // Driver Name
     String driverName = driver.getString("givenName") + " " + driver.getString("familyName");
     fill(0);
     text(driverName, 110, i * 10 + 200 + 10);
     
     // Top 3
     if(i < 3) {    
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
  // Back button
  drawBackButton();
  String driverName = selectedDriver.getString("givenName") + " " + selectedDriver.getString("familyName");
  // Title
  textSize(32);
  fill(255,0,0);
  text(driverName, canvasWidth/2, 20);
}

void page4()  {
   background(255);
   // Back button
   drawBackButton();
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
     // Back button
     drawBackButton();
     String constructorID = selectedConstructor.getString("name");
     text(constructorID, canvasWidth/2, 20);
     PImage constructorImage = loadImage("/img/constructors/" + selectedConstructor.getString("constructorId") + ".png");
     constructorImage.resize(canvasWidth/2, canvasHeight/2);
     image(constructorImage, canvasWidth/2, canvasHeight/2);
}

void page6() {
   background(255);
    // Back button
   drawBackButton();
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

void drawBackButton() {
  Button backButton = new Button(20,20, 70, 50, "Back");
  backButton.display();
  if(backButton.hasClicked()) currentPage--;
}
