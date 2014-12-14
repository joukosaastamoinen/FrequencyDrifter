import ddf.minim.analysis.*;
import ddf.minim.*;

PImage img;
PImage originalImg;
String imgFileName = "PIA15635.jpg";
Minim minim;
AudioInput in;
FFT fft;

int iterationCount = 30000;
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
  fft.logAverages(22, 3); 
  img.copy(originalImg, 0, 0, originalImg.width, originalImg.height, 0, 0, originalImg.width, originalImg.height);
}

void draw() {  
  img.loadPixels();
  
  fft.forward(in.mix);

  int fftSpecSize = (int)(fft.specSize() / 20);

  for(int i = 0; i < fftSpecSize; i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    float fftValue = fft.getBand(i);
    
    int minV = (int)((float)i / fftSpecSize * 255.0);
    int maxV = (int)((float)(i + 1) / fftSpecSize * 255.0);
    
    int j = 0;    
    while (j < iterationCount) {
      int x = (int)random(originalImg.width);
      int y = (int)random(originalImg.height);
      
      int srcX = x;
      int srcY = (int)(y + fftValue * 10) % originalImg.height;
      
      int srcV = originalImg.pixels[srcX + srcY * originalImg.width];
      int srcR = (srcV & 0xff0000) >> 16;
      int srcG = (srcV & 0xff00) >> 8;
      int srcB = srcV & 0xff;
      int gray = (srcR + srcG + srcB) / 3;
      
      if (gray >= minV && gray < maxV) {
        img.pixels[x + y * originalImg.width] = srcV;
      }
      
      j++;
    }
  }

  img.updatePixels();
  
  image(img, 0, 0);
}

