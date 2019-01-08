class Circuit {
  private String circuitID;
  private String wiki;
  private String circuitName;
  private Location location;
  private int mapX;
  private int mapY;
  
  Circuit(String circuitID, String wiki, String circuitName, Location location, int mapX, int mapY) {
    this. circuitID = circuitID;
    this.wiki = wiki;
    this.circuitName = circuitName;
    this.location = location;
    this.mapX = mapX;
    this.mapY  = mapY;
  }
  
  public int getMapX() {
    return mapX;
  }
  
  public int getMapY() {
    return mapY;
  }
  
  public String getCircuitID() {
    return circuitID;
  }
}
