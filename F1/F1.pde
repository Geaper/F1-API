private HashMap<Integer, Season> seasons = new HashMap<Integer, Season>();
private HashMap<String, Driver> drivers = new HashMap<String, Driver>();
private HashMap<Integer, Circuit> circuits = new HashMap<Integer, Circuit>();

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
  
}

void draw() {
  
}
