// Simple Particle System
//From based off the nature of code
class Particle {

  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan = 355;
  float offset = 2;
  color strokeColor = color(random(122,222), 125,255);
  float strokeSize = random(.1,2.1)*2;
  float strokeAlpha = 255;
	  Particle(float x, float y) {
      acc = new PVector(0, 0);
      vel = new PVector(random(-1,1),random(-1,1));
      loc = new PVector(x, y);
      lifespan = 300;
      offset = random(1, 4);

	  }
   
  void run() {
    update();
    render();
  }

  void applyForce(PVector f) {
    acc.add(f);
  }

  // Method to update location
  void update() {

       // denormalized floats cause significant performance issues
    if (abs(vel.x) + abs(vel.y) < 0.00000000001f){
      vel.mult(0);
    } 
        
    vel.add(acc);
    loc.add(vel);
    acc.mult(0);
    lifespan -= 2.0;
  }

  void bounds(){
      if (loc.x < 0) {vel.x= abs(vel.x);} 
      else if (loc.x > width) {vel.x = -abs(vel.x);}
      if (loc.z < 0) {vel.y = abs(vel.y);} 
      else if (loc.y > height) {vel.y = -abs(vel.y);}
      if(loc.y < 0) {vel.y = abs(vel.y);} 
  }

 // Method to display
   void render() {
    if(lifespan > 0){
        return;
    }
    fadeAlpha();
    // fix this later    
    offset = map(lifespan, 0, 255, 0, 2);
    stroke(123, 255);
    
    rect(loc.x, loc.y,20,20);
  }

  void fadeAlpha(){
    // fade starts when life span is less than 80
    if(lifespan < 80) {
      strokeAlpha = map(lifespan, 0, 80, 0, 255);
    }
  }

  void die(){
      lifespan = 0;
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } 
    else {
      return false;
    }
  }
}// 
