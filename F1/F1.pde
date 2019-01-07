private HashMap<Integer, Season> seasons = new HashMap<Integer, Season>();
private HashMap<String, Driver> drivers = new HashMap<String, Driver>();
private HashMap<String, Circuit> circuits = new HashMap<String, Circuit>();
private int page = 0;

void setup() {
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
    Circuit circuit = new Circuit(circuitID, params[7], params[2], location);
    circuits.put(circuitID, circuit);
  }
}

void draw() {
  background(0);
  // Pages
  switch(page) {
    case 0:
      page0();
    break;
    case 1:
      page1();
    break;
    default:
      page0();
    break;
  }
}

// Page 0
void page0() {
  
}

// Page 1
void page1() {
  
}
