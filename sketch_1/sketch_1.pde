PImage img;
PrintWriter output;
int fragmentCount = 0;

// Controls the grid density for scanning.
// Smaller values generate more fragments.
// Here we aim for about 30–50 fragments, so we use a larger step size.
int stepSize = 40; 

void setup() {
  size(800, 800); 
  
  // 1. Load the image generated in Part 1
  img = loadImage("dataset_extended_image.png"); // <-- make sure the filename is correct
  
  // Safety check: if the image is not found, stop execution without crashing
  if (img == null) {
    println("⚠️ Critical error: image not found! Please check the path and filename above.");
    return; // Stop further execution to prevent NullPointerException
  }
  
  img.resize(width, height); 
  
  // ... (rest of CSV creation code remains unchanged)
  output = createWriter("fragments_data.csv");
  output.println("id,x,y,z,scale,twist");
  // ... etc.

  
  img.loadPixels();
  background(20);
  
  // 3. Iterate through pixels and extract features
  for (int y = 0; y < height; y += stepSize) {
    for (int x = 0; x < width; x += stepSize) {
      int loc = x + y * width;
      color c = img.pixels[loc];
      
      // Extract red channel (represents dark circus aesthetic) and brightness (represents density)
      float r = red(c);
      float bright = brightness(c);
      
      // Rule: only generate fragments in areas with high red or brightness values
      if (r > 80 || bright > 100) { 
        
        // --- Cross-platform translation: mapping 2D pixels to Blender 3D coordinates ---
        
        // Map X and Y coordinates to Blender space (-10 to 10)
        float blenderX = map(x, 0, width, -10, 10);
        float blenderY = map(y, 0, height, 10, -10); // invert Y axis for Blender convention
        
        // Use brightness to determine Z position (height), creating a surreal floating effect
        float blenderZ = map(bright, 0, 255, 0, 15);
        
        // Variation parameter 1 (Scale): darker red creates larger fragments
        float scale = map(r, 0, 255, 0.5, 3.0);
        
        // Variation parameter 2 (Twist): use Perlin noise to simulate chaotic distortion (-180° to 180°)
        float twist = map(noise(x * 0.05, y * 0.05), 0, 1, -180, 180);
        
        // 4. Write computed data into CSV file
        output.println(fragmentCount + "," + blenderX + "," + blenderY + "," + blenderZ + "," + scale + "," + twist);
        fragmentCount++;
        
        // 5. Visual preview in Processing (circles represent generated fragments)
        fill(c);
        noStroke();
        ellipse(x, y, scale * 5, scale * 5);
      }
    }
  }
  
  // Save and close file
  output.flush();
  output.close();
  
  println("✅ Success! Extracted " + fragmentCount + " fragment data points from the image!");
  println("CSV file has been saved in the root directory of this Processing project.");
  
  noLoop(); // Run only once, no continuous rendering needed
}
