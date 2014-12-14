import ddf.minim.analysis.*;
import ddf.minim.*;

PImage img;
PImage originalImg;
String imgFileName = "PIA15635.jpg";
Minim minim;
AudioInput in;
FFT fft;

int originalBlackValue = -9000000 + 0xff000000; 
int blackValue = 0;
int brigthnessValue = 60;
int whiteValue = -13000000;

int row = 0;
int column = 0;

void setup() {
  originalImg = loadImage(imgFileName);
  originalImg.loadPixels();
  size(originalImg.width, originalImg.height);
  img = createImage(originalImg.width, originalImg.height, ARGB);
  minim = new Minim(this);  
  in = minim.getLineIn();
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  //fft.logAverages(22, 3); 
}

void draw() {
  //img.copy(originalImg, 0, 0, originalImg.width, originalImg.height, 0, 0, originalImg.width, originalImg.height);
  
  img.loadPixels();
  
  fft.forward(in.mix);

  int fftSpecSize = (int)(fft.specSize() / 20);

  for(int i = 0; i < fftSpecSize; i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    float fftValue = fft.getBand(i);
    
    int minV = (int)((float)i / fftSpecSize * 255.0);
    int maxV = (int)((float)(i + 1) / fftSpecSize * 255.0);
    
    println(minV);
    
    for (int y = 0; y < originalImg.height; y++) {
      for (int x = 0; x < originalImg.width; x++) {
        int srcV = originalImg.pixels[x + y * originalImg.width];
        int srcR = (srcV & 0xff0000) >> 16;
        int srcG = (srcV & 0xff00) >> 8;
        int srcB = srcV & 0xff;
        int gray = (srcR + srcG + srcB) / 3;
        
        if (gray >= minV && gray < maxV) {
          int targetX = x;
          int targetY = (int)(y + fftValue * 10) % originalImg.height;
          img.pixels[targetX + targetY * originalImg.width] = srcV;
        }
      }
    }
  }

  img.updatePixels();
  
  image(img, 0, 0);
}

