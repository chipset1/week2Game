import ddf.minim.*;

Keyboard keyboard;
GameStateManager gsm;
ParticleSystem ps;

int LEVEL1STATE = 1;
int LEVEL2STATE = 2;
int LEVEL3STATE = 3;
int LEVEL4STATE = 4;
int LEVEL5STATE = 5;
int LEVEL6STATE = 6;

void setup(){
  size(720,512);
  gsm = new GameStateManager();
  keyboard = new Keyboard();
  ps = new ParticleSystem();
}

void draw(){
 
  gsm.update();
  gsm.display();

}

public PVector randomVector(){
  PVector pvec = new PVector(random(-1,1), random(-1,1), 0);
  pvec.normalize();
  return pvec;
}

public PVector randomVector(float range){
  PVector pvec = new PVector(random(-range,range), random(-range,range), 0);
  pvec.normalize();
  return pvec;
}

void keyPressed(){
  keyboard.pressKey(key, keyCode);
}

void keyReleased(){
  keyboard.releaseKey(key, keyCode);
}