private HashMap<Integer, Season> seasons = new HashMap<Integer, Season>();
private HashMap<String, Driver> drivers = new HashMap<String, Driver>();
private HashMap<String, Circuit> circuits = new HashMap<String, Circuit>();
private int currentPage = 0;

// Images
private PShape map;
private PImage f1Logo;
private PImage f1Background;

// Default settings
private final int canvasWidth = 1600;
private final int canvasHeight = 900;

// Buttons


void settings() {
    size(canvasWidth, canvasHeight);
}

void setup() {
  
  // Common Stuff
  map = loadShape("img/common/world-map.svg");
  f1Logo = loadImage("img/common/f1-logo.png");
  f1Background = loadImage("img/common/f1-background.jpg");
  
  // Load Seasons
  String[] seasonLines = loadStrings("seasons.csv");
  for(String seasonLine : seasonLines) {
    String[] params = seasonLine.split(",");
    int year = Integer.parseInt(params[0]);
    Season season = new Season(year, params[1]);
    seasons.put(year, season);
  }
  // Load Driver
  String[] driversLines = loadStrings("driver.csv");
  for(String driversLine : driversLines) {
    String[] params = driversLine.split(",");
    String driverID = params[1];
    Driver driver = new Driver(driverID, params[2], params[3], params[7], params[3], params[4], params[5], params[6]);
    drivers.put(driverID, driver);
  }
  // Load Circuits
  String[] circuitLines = loadStrings("circuits.csv");
  for(String circuitLine : circuitLines) {
    String[] params = circuitLine.split(",");
    String circuitID = params[1];
    Location location = new Location(params[5], params[6], params[3], params[4]);
    // Map Positions
    int mapX = -1, mapY = -1;
    if(params.length > 10) {
      mapX = Integer.parseInt(params[9]);
      mapY = Integer.parseInt(params[10]);
    }
    Circuit circuit = new Circuit(circuitID, params[8], params[2], location, mapX, mapY);
    circuits.put(circuitID, circuit);
  }
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
    // Load All the Circuit Positions
    for(Circuit circuit : circuits.values()) {
      ellipse(circuit.getMapX(), circuit.getMapY(),10,10);
      // When the user hovers the Point
      if(mouseX < circuit.getMapX() + 10 && mouseX > circuit.getMapX() - 10 && mouseY > circuit.getMapY() - 10 && mouseY < circuit.getMapY() + 10) {
        // Highlight it
        ellipse(circuit.getMapX(), circuit.getMapY(),30,30);
        // Show a simple informative box
        fill(255);
        line(circuit.getMapX(), circuit.getMapY(), 200,631);
        rect(200,631,150,200);
        // Inside the rect, insert information
        PImage circuitImage = loadImage("img/circuits/" + circuit.getCircuitID() + ".png");
        circuitImage.resize(150,200);
        image(circuitImage,200,631);   
        // On click, change to page 2
        if(mousePressed) currentPage = 2;
      }
    }
}

void page2() {
  background(0);
  
}
