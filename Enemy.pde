class Enemy extends Entity{

	// add flags for behaviors
	boolean canOverLap = true;
	PVector bounds ;
	int timeUntilStart = 60;
	float shootTime = 0;

	Enemy(float x ,float y){
		position = new PVector(x,y);
		velocity = new PVector(0,0);
		radius = 20;
		fillColor = #ff0000;
	}			

	void setBounds(PVector b){bounds = b;} 

	void update(){
		if(bounds != null) withinMapBounds();
		if(timeUntilStart <= 0){
			tintAlpha = 255;
			position.add(velocity);
		}else{
			timeUntilStart --;
			tintAlpha += 1- timeUntilStart/60;
		}
	}

	Bullet shootAt(PVector target, float shot_length, float shot_mag){
		 if(millis() - shootTime > shot_length){
 			PVector shot_vel = PVector.sub(target, this.position);
 			PVector pos = position.get();
 			shot_vel.normalize();
 			shot_vel.mult(shot_mag);
 			pos.add(shot_vel);
 			shootTime = millis();
			return shoot(position, shot_vel);
		 }
		 return null;
	}

	Bullet shootAt(PVector target, float shot_length){
		 if(millis() - shootTime > shot_length){
 			PVector shot_vel = PVector.sub(target, this.position);
 			PVector pos = position.get();
 			shot_vel.normalize();
 			shot_vel.mult(2);
 			pos.add(shot_vel);
 			shootTime = millis();
			return shoot(position, shot_vel);
		 }
		 return null;
	}

	Bullet shoot(PVector pos, PVector shot_vel){
     	return new Bullet(pos, shot_vel, 255, false);
	}
	// override
	void display(){
		if(!isExpired){
			noStroke();
			fill(fillColor);
			rect(position.x, position.y, radius,radius);
		}
	}

	void withinMapBounds(){
		float buffer = 0;
      	if(position.x > bounds.x + buffer) velocity.x *= -1;
		else if(position.x <      0 + buffer) velocity.x *= -1;
		if(position.y > bounds.y + buffer) velocity.y *= -1;
		else if(position.y <    0 + buffer) velocity.y *= -1;
  }

}// end of enemy class
