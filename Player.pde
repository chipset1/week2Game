class Player extends Entity {
  int frameUntilRespawn = 0;
  float shootTime = 0;// time since last shot
  float speed = 2.5;
  float damping = 0.7;

  int max_bullets = 0;
  boolean canMove = true;

  Player(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    radius = 10;
    fillColor = 255;
  }

  void kill() {
      frameUntilRespawn=120;
  }
  void stopMovement(){
      canMove = false;
  }
  void startMovement(){
    canMove = true;
  }
  // override
  void update() {
    if(!canMove || isExpired){
      return;
    } 
    inputCheck();
    velocity.mult(damping);
    velocity.limit(10);
    position.add(velocity);
  }

  // plays when player is dead
  void deathAni(){
    
  }

  void displayCirCrossHair(PVector pos,float w,float h){
      stroke(255);
      noFill();
      ellipse(pos.x, pos.y, w,h);
      line(pos.x + w/2, pos.y + h/2, mouseX,mouseY);
  }

  void displayRectCrossHair(PVector pos,float w,float h){
      stroke(255);
      noFill();
      rect(pos.x, pos.y, w,h);
      line(pos.x + w/2, pos.y, mouseX,mouseY);
  }

  //@override
  void display() {
    if(isExpired){
      return;
    }
    //ps.enemyExplode(position.x, position.y);
    fill(fillColor);
    rect(position.x, position.y, radius, radius);
  }

  Bullet fastShoot(PVector pos, PVector shot_vel){
        max_bullets--;
        shootTime = millis();
        return new Bullet(pos, shot_vel, 255, true);
  }

  Bullet shoot(PVector pos, PVector shot_vel){
      if(max_bullets > 0 && millis() - shootTime > 500){
        max_bullets--;
        shootTime = millis();
        return new Bullet(pos, shot_vel, 255, true);
      }
      return null;
  }

  boolean isMoving(){
      return keyboard.holdingLeft || keyboard.holdingRight || keyboard.holdingDown || keyboard.holdingUp || keyboard.holdingA ||keyboard.holdingD || keyboard.holdingW || keyboard.holdingS;
  }

  void inputCheck() {
    //arrows input check
    if (keyboard.holdingLeft) {
      velocity.x -= speed;
    } 
    else if ( keyboard.holdingRight ) {
      velocity.x += speed;
    }
    if (keyboard.holdingUp) {
      velocity.y -= speed;
    }
    else if (keyboard.holdingDown) {
      velocity.y += speed;
    }
    // wasd input check
    if (keyboard.holdingA) {
      velocity.x -= speed;
    } 
    else if ( keyboard.holdingD ) {
      velocity.x += speed;
    }
    if (keyboard.holdingW) {
      velocity.y -= speed;
    }
    else if (keyboard.holdingS) {
      velocity.y += speed;
    }
  }
}// end of player class

