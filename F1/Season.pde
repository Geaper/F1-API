class Season {
  
  private int year;
  private String wiki;
  
  Season(int year, String wiki) {
    this.year = year;
    this.wiki = wiki;
  }
  
  public int getYear() {
    return year;
  }
  
  public void setYear(int year) {
    this.year = year;
  }
  
  public String getWiki() {
    return wiki;
  }
  
  public void setWiki(String wiki) {
    this.wiki = wiki;
  }
}
