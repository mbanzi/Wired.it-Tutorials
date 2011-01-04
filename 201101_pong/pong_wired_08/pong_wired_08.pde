int x = 20; //posizione pallina
int y = 10;
int sx = 1; // incremento posizione pallina
int sy = 1;
int p1  = 0;   // punteggo
int p2  = 0;
int r1 = 100; // posizione racchetta 1
int r2 = 100; // posizione racchetta 2
int incR = 5; // incremento posizione racchette

PFont f;

void setup() {
  size(400,300);
  background(0);
  stroke(255);
  fill(255);
  f = createFont("Arial",24);
  textFont(f);
}

void draw() {
  background(0);
  x = x + sx;
  y = y + sy;
  if ((y < 0) || (y > height)) {
    // inverte il segno di sy
    sy = -1 * sy;
  }
  if (x > width) {
    p1 = p1 + 1;
    x = width / 2;
    y = height / 2;
    
  }
  if (x < 0) {
    p2 = p2 + 1; 
    x = width / 2;
    y = height / 2;
  }

  // collision detection racchetta 1
  if ((x<= 20) && (x >=10) && (y >= r1) && (y <= (r1 +60)))
  {
    sx = -1 * sx;
    // effetto sonoro
  }
  
  // collision detection racchetta 2
  if (((x<= width - 10)) && (x >=(width - 30)) && (y >= r2) && (y <= (r2 +60)))
  {
    sx = -1 * sx;
    // effetto sonoro
  }

  // linea di mezzeria
  line(200,0,200,300);
  rect(x,y, 10,10);

  // disegno le racchette
  rect(10,r1,10,60);
  rect(width - 20,r2,10,60); 
  text(p1, (width/2) - 30, 30);
  text(p2, (width/2) + 30, 30);
  
}

void keyPressed() {

  if (key == 'a') {
    r1 = r1 - incR;
  } 
  if (key == 'z') {
    r1 = r1 + incR;
  } 
  if (key == 'k') {
    r2 = r2 - incR;
  } 
  if (key == 'm') {
    r2 = r2 + incR;
  }
}


