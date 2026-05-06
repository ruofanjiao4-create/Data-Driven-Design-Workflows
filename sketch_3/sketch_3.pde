// ============================================================
// Surreal Circus - P3D Real-time Interactive 3D Rendering Engine
// Reads CSV spatial data and reconstructs generative 3D architecture in Processing
// ============================================================

Table data;
int totalFragments = 0;

float minX = 9999, maxX = -9999;
float minY = 9999, maxY = -9999;
float minZ = 9999, maxZ = -9999;

// Cyberpunk / surreal 3D color palette
color[][] palettes = {
  { color(255, 50, 100, 200), color(50, 200, 255, 150) }, // Neon pink + cyber blue
  { color(200, 255, 50, 200), color(50, 100, 255, 150) }, // Toxic green + deep blue
  { color(255, 150, 0,  200), color(150, 0,   255, 150) },// Ruin gold + void purple
  { color(255, 255, 255,200), color(100, 100, 100, 150) } // Pure white + tech gray
};

void setup() {
  // Enable P3D rendering mode
  size(1200, 900, P3D);
  
  // Replace with your actual CSV path
  data = loadTable("C:/Users/jiaor/Desktop/python2/sketch_1/fragments_export.csv", "header");
  totalFragments = data.getRowCount();
  
  // Compute bounds to center the entire structure
  for (TableRow r : data.rows()) {
    float x = r.getFloat("x"); float y = r.getFloat("y"); float z = r.getFloat("z");
    if (x < minX) minX = x; if (x > maxX) maxX = x;
    if (y < minY) minY = y; if (y > maxY) maxY = y;
    if (z < minZ) minZ = z; if (z > maxZ) maxZ = z;
  }
}

void draw() {
  background(10, 12, 18); // Deep cosmic background
  
  // =========================================
  // 1. Lighting setup (core Processing magic)
  // =========================================
  lights(); // Enable default lighting
  ambientLight(40, 40, 50); // Global low light
  
  // Three cyberpunk directional lights
  directionalLight(0, 150, 255, 1, 0, -1);   // Blue cold light (right)
  directionalLight(255, 50, 150, -1, 0, -1); // Pink warm light (left)
  directionalLight(255, 200, 100, 0, 1, -0.5); // Soft gold light (top)

  // =========================================
  // 2. Interactive 3D camera (mouse-controlled)
  // =========================================
  translate(width / 2, height / 2, -500); // Pull camera back
  
  // Mouse-based 3D rotation
  float rotX = map(mouseY, 0, height, PI, -PI);
  float rotY = map(mouseX, 0, width, -PI, PI);
  rotateX(rotX);
  rotateY(rotY);

  // =========================================
  // 3. Reconstruct fragments in 3D space
  // =========================================
  for (int i = 0; i < totalFragments; i++) {
    TableRow row = data.getRow(i);

    int   type  = row.getInt("type");
    int   cGrp  = row.getInt("colorGroup");
    float rawX  = row.getFloat("x");
    float rawY  = row.getFloat("y");
    float rawZ  = row.getFloat("z");
    float scale = row.getFloat("scale");
    float twist = row.getFloat("twist");

    // Map data into Processing 3D space (800x800x800 volume)
    float px = map(rawX, minX, maxX, -400, 400);
    float py = map(rawY, minY, maxY, 400, -400); // flipped Y-axis
    float pz = map(rawZ, minZ, maxZ, -400, 400);
    
    float finalSize = scale * 80;
    color[] pal = palettes[cGrp % 4];

    pushMatrix();
    translate(px, py, pz);
    rotateY(radians(twist * 2));
    rotateX(radians(twist));

    drawP3DFragment(type, finalSize, pal);

    popMatrix();
  }
}

// =========================================
// P3D geometry generation library
// (Reconstruct complex forms from primitives)
// =========================================
void drawP3DFragment(int type, float s, color[] pal) {
  
  int category = type % 5;

  strokeWeight(1);
  switch(category) {
    case 0: // Solid energy block (Box)
      fill(pal[0]);
      noStroke();
      box(s, s * 1.5, s * 0.5);
      break;
      
    case 1: // Wireframe holographic sphere
      noFill();
      stroke(pal[1]);
      sphereDetail(8);
      sphere(s * 0.8);
      break;
      
    case 2: // Spatial slicing planes
      fill(pal[1], 150);
      stroke(pal[0], 200);
      beginShape(QUADS);
      vertex(-s, -s, 0); vertex(s, -s, 0); vertex(s, s, 0); vertex(-s, s, 0);
      vertex(0, -s, -s); vertex(0, s, -s); vertex(0, s, s); vertex(0, -s, s);
      endShape();
      break;
      
    case 3: // Data matrix cluster
      fill(pal[0]);
      noStroke();
      for(float i = -s/2; i <= s/2; i += s/2) {
        for(float j = -s/2; j <= s/2; j += s/2) {
          pushMatrix();
          translate(i, j, 0);
          box(s/4);
          popMatrix();
        }
      }
      break;
      
    case 4: // Distorted pyramid
      fill(pal[0], 180);
      stroke(pal[1]);
      beginShape(TRIANGLES);
      vertex(-s, s, s); vertex(s, s, s); vertex(0, -s, 0);
      vertex(s, s, s); vertex(s, s, -s); vertex(0, -s, 0);
      vertex(s, s, -s); vertex(-s, s, -s); vertex(0, -s, 0);
      vertex(-s, s, -s); vertex(-s, s, s); vertex(0, -s, 0);
      endShape();
      break;
  }
}

// Save high-resolution screenshot of current camera angle ('S' key)
void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("C:/Users/jiaor/Desktop/python2/sketch_1/P3D_Architecture_###.png");
    println("✅ 3D view screenshot saved!");
  }
}
