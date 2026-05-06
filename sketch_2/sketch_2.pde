// ============================================================
// Surreal Circus - Final 2D Visual Rendering Engine (20-style system)
// Reads precise 3D coordinates exported from Blender and converts them into a 2D artistic poster
// ============================================================

Table data;
int totalFragments = 0;

// Canvas size
int W = 1200;
int H = 1600;

// Auto boundary calculation (ensures perfect centering)
float minX = 9999, maxX = -9999;
float minY = 9999, maxY = -9999;
float minZ = 9999, maxZ = -9999;

// 5 surreal circus color palettes (primary / secondary / accent)
color[][] palettes = {
  { color(230, 50, 60, 200),  color(255, 180, 40, 180),  color(255, 250, 220, 255) }, // Crimson & Gold
  { color(30, 200, 180, 200), color(40, 80, 220, 180),   color(200, 255, 255, 255) }, // Cyber Cyan Blue
  { color(160, 40, 200, 200), color(240, 100, 180, 180), color(255, 220, 240, 255) }, // Psychedelic Purple Pink
  { color(40, 180, 80, 200),  color(180, 220, 60, 180),  color(220, 255, 200, 255) }, // Toxic Neon Green
  { color(200, 150, 40, 200), color(100, 60, 20, 180),   color(255, 240, 180, 255) }  // Ruin Dark Gold
};

void setup() {
  size(1200, 1600);
  background(10, 8, 15); // Deep cosmic black
  noLoop();

  // 1. Load Blender-generated CSV data
  data = loadTable("C:/Users/jiaor/Desktop/python2/sketch_1/fragments_export.csv", "header");
  totalFragments = data.getRowCount();
  println("Fragments loaded: " + totalFragments);

  // 2. Compute 3D spatial bounds for accurate 2D mapping
  for (TableRow r : data.rows()) {
    float x = r.getFloat("x"); float y = r.getFloat("y"); float z = r.getFloat("z");
    if (x < minX) minX = x; if (x > maxX) maxX = x;
    if (y < minY) minY = y; if (y > maxY) maxY = y;
    if (z < minZ) minZ = z; if (z > maxZ) maxZ = z;
  }
}

void draw() {
  // 1. Draw atmospheric background
  drawBackground();

  // 2. Sort fragments by Z-depth (painter’s algorithm)
  int[] order = sortByZ();

  // 3. Render each fragment
  for (int i = 0; i < totalFragments; i++) {
    TableRow row = data.getRow(order[i]);

    int   type  = row.getInt("type");
    int   cGrp  = row.getInt("colorGroup");
    float rawX  = row.getFloat("x");
    float rawY  = row.getFloat("y");
    float rawZ  = row.getFloat("z");
    float scale = row.getFloat("scale");
    float twist = row.getFloat("twist");

    // Map 3D coordinates to 2D canvas (with margins)
    float screenX = map(rawX, minX, maxX, 150, W - 150);
    float screenY = map(rawY, minY, maxY, H - 150, 150); // flipped Y-axis for visual convention
    float depthZ  = map(rawZ, minZ, maxZ, 0.5, 1.5);      // depth influences scale
    
    float finalSize = scale * 50 * depthZ;
    color[] pal = palettes[cGrp % 5];

    pushMatrix();
    translate(screenX, screenY);
    rotate(radians(twist * 2)); // subtle rotation

    // Core: 20 different artistic fragment styles
    drawAbstractFragment(type, finalSize, pal, twist);

    popMatrix();
  }

  // 4. Film grain overlay
  drawGrainOverlay();

  // 5. Save final render
  save("C:/Users/jiaor/Desktop/python2/sketch_1/circus_final_20_styles.png");
  println("✅ Render complete! Saved as circus_final_20_styles.png");
}

// =========================================
// 20 Abstract Fragment Rendering Styles (core system)
// =========================================
void drawAbstractFragment(int type, float s, color[] pal, float t) {
  strokeWeight(random(0.5, 2));
  
  switch(type) {
    case 0: // Spire: sharp triangle
      fill(pal[0]); stroke(pal[2]);
      triangle(-s/2, s, s/2, s, 0, -s*2);
      break;

    case 1: // Cage: grid circle
      noFill(); stroke(pal[1]); strokeWeight(1.5);
      ellipse(0, 0, s*2, s*2);
      for(int i=-1; i<=1; i+=2) { line(-s, i*s/3, s, i*s/3); line(i*s/3, -s, i*s/3, s); }
      break;

    case 2: // Slab: stacked lines
      fill(pal[1]); noStroke();
      for(int i=0; i<5; i++) rect(-s, -s + i*s*0.4, s*2, s*0.2);
      break;

    case 3: // Arch: layered arcs
      noFill(); stroke(pal[0]); strokeCap(SQUARE);
      for(int i=0; i<3; i++) arc(0, 0, s*(1+i*0.5), s*(1+i*0.5), PI, TWO_PI);
      break;

    case 4: // Rock: irregular polygon
      fill(pal[0]); stroke(pal[2]);
      beginShape();
      for(int i=0; i<6; i++) vertex(cos(i*TWO_PI/6)*s*random(0.8,1.5), sin(i*TWO_PI/6)*s*random(0.5,1.2));
      endShape(CLOSE);
      break;

    case 5: // Spiral wave
      noFill(); stroke(pal[2]);
      beginShape();
      for(float i=-s; i<s; i+=s/5) curveVertex(sin(i/s*PI*2)*s*0.5, i);
      endShape();
      break;

    case 6: // Melt block
      fill(pal[1]); noStroke();
      rect(-s/2, -s/2, s, s, s/4);
      break;

    case 7: // Scaffold X
      stroke(pal[0]); noFill();
      line(-s, -s, s, s); line(-s, s, s, -s);
      rect(-s, -s, s*2, s*2);
      break;

    case 8: // Sea urchin spikes
      stroke(pal[2]);
      for(int i=0; i<12; i++) { float ang=i*TWO_PI/12; line(0,0, cos(ang)*s*1.5, sin(ang)*s*1.5); }
      break;

    case 9: // Ribbon curve
      noFill(); stroke(pal[1]);
      bezier(-s, -s, s, -s/2, -s, s/2, s, s);
      break;

    case 10: // Gear
      fill(pal[0]); noStroke();
      beginShape();
      for(int i=0; i<16; i++) { float r=(i%2==0)?s:s*0.7; vertex(cos(i*TWO_PI/16)*r, sin(i*TWO_PI/16)*r); }
      endShape(CLOSE);
      break;

    case 11: // Shell layers
      fill(pal[1], 100); noStroke();
      ellipse(0, 0, s*1.5, s*1.5); ellipse(s*0.2, s*0.2, s, s);
      break;

    case 12: // Crystal cluster
      fill(pal[2]); stroke(pal[0]);
      quad(0, -s, s/2, 0, 0, s, -s/2, 0);
      quad(-s/2, -s/2, 0, 0, -s/2, s/2, -s, 0);
      break;

    case 13: // Ruined pillar
      stroke(pal[1]); fill(pal[0], 150);
      beginShape(); vertex(-s/2,-s); vertex(s/2,-s); vertex(s/2,s); vertex(0,s*0.8); vertex(-s/2,s); endShape(CLOSE);
      break;

    case 14: // Möbius loop
      noFill(); stroke(pal[2]); strokeWeight(2);
      bezier(0,0, -s*2,-s, -s*2,s, 0,0); bezier(0,0, s*2,-s, s*2,s, 0,0);
      break;

    case 15: // Layered dots
      fill(pal[0]); noStroke();
      for(float x=-s; x<=s; x+=s/2) for(float y=-s; y<=s; y+=s/2) ellipse(x,y,s/4,s/4);
      break;

    case 16: // Spore ring
      stroke(pal[1]); fill(pal[0], 50);
      beginShape();
      for(int i=0; i<20; i++) { float r=s+random(-s/5,s/5); vertex(cos(i*TWO_PI/20)*r, sin(i*TWO_PI/20)*r); }
      endShape(CLOSE);
      break;

    case 17: // Glitch blocks
      fill(pal[0]); noStroke(); rect(-s*0.8, -s*0.8, s, s);
      fill(pal[1], 150); rect(-s*0.4, -s*0.4, s, s);
      break;

    case 18: // Tornado rings
      noFill(); stroke(pal[2]);
      for(int i=1; i<=4; i++) ellipse(0, -s*i*0.3, s*i*0.4, s*0.2);
      break;

    case 19: // Floating dashed ring
      noFill(); stroke(pal[1]);
      for(int i=0; i<360; i+=20) arc(0,0, s*2, s*2, radians(i), radians(i+10));
      break;
  }
}

// =========================================
// Background + post-processing
// =========================================
void drawBackground() {
  for (int r = 1600; r > 0; r -= 10) {
    float t = map(r, 0, 1600, 0, 1);
    color c = lerpColor(color(30, 10, 40, 255), color(10, 8, 15, 255), t);
    fill(c); noStroke();
    ellipse(W / 2, H / 2, r, r);
  }
}

void drawGrainOverlay() {
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    float noise = random(-15, 15);
    color c = pixels[i];
    pixels[i] = color(
      constrain(red(c)+noise, 0, 255),
      constrain(green(c)+noise, 0, 255),
      constrain(blue(c)+noise, 0, 255)
    );
  }
  updatePixels();
}

int[] sortByZ() {
  int n = data.getRowCount();
  int[] idx = new int[n];
  for (int i = 0; i < n; i++) idx[i] = i;

  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (data.getRow(idx[j]).getFloat("z") > data.getRow(idx[j+1]).getFloat("z")) {
        int tmp = idx[j];
        idx[j] = idx[j+1];
        idx[j+1] = tmp;
      }
    }
  }
  return idx;
}
