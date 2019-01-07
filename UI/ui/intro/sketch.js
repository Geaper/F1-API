var canvas;
var ipcaLogo;
var f1Logo;
var circuits;

function setup() {
   canvas = createCanvas(window.innerWidth, window.innerHeight);

   // Load images to page
   //ipcaLogo = loadImage("../../img/ipca-logo.png");
   circuits = loadJSON("http://localhost:3000/api/circuits");
   console.log(circuits);
}

function draw() {
  background(0);
  stroke(0);
  fill(255,6,0);
  triangle(0, 0, 0, height, width/2, 0);
}


window.onresize = function() {
  var w = window.innerWidth;
  var h = window.innerHeight;
  canvas.size(w,h);
  width = w;
  height = h;
};
