class DriverCircle {
  
  String driverID;
  String driverName;
  String driverCode;
  String lap;
  String time;
  float duration;
  int posX;
  int posY;
  
  DriverCircle(String driverID, String driverName, String driverCode, String lap, String time, float duration, int posX, int posY) {
    this.driverID = driverID;
    this.driverName = driverName;
    this.driverCode = driverCode;
    this.lap = lap;
    this.time = time;
    this.duration = duration;
    this.posX = posX;
    this.posY = posY;
  }
}
