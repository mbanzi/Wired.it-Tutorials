int x = 20;
int y = 10;
int sx = 1;
int sy = 1;

void setup() {
  size(400,300);
  background(0);
  stroke(255);
  fill(255);
}

void draw() {
  background(0);
  x = x + sx;
  y = y + sy;
  if ((y < 0) || (y > height)) {
     // inverte il segno di sy
     sy = -1 * sy;
  }
  if ((x < 0) ||(x > width)) {
    sx = -1 * sx;
  }
  
  if ((x<= 20) && (x >=10) && (y >= mouseY) && (y <= (mouseY +60))) {
    sx = -1 * sx;

  }

  line(200,0,200,300);
  rect(x,y, 10,10);
  
  // disegno la racchetta
  rect(10,mouseY,10,60);
}


