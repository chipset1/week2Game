class SeekerEnemy extends Enemy {
	PVector target;

	SeekerEnemy(float x, float y){
		super(x,y);
		target = new PVector();
	}

	void update(){
		position.add(velocity);
	}

	void seek(PVector pos){
		target = PVector.sub(pos, position);
		target.normalize();
		if(target.mag() < 10) target.mult(.2);
		velocity.add(target); 
		velocity.limit(2);
		//position.add(velocity);
	}
 
//from the nature of code by Daniel Shiffman
	void separate (ArrayList<SeekerEnemy> elist) {
    float desiredseparation = radius + 3;
    PVector sum = new PVector();
    int count = 0;
    // For every boid in the system, check if it's too close
    for (SeekerEnemy s : elist) {
      float d = PVector.dist(position, s.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, s.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div(count);
      // Our desired vector is the average scaled to maximum speed
      sum.normalize();
      sum.mult(2);
      // Implement Reynolds: Steering = Desired - Velocity
      PVector steer = PVector.sub(sum, velocity);
      velocity.add(steer);
    }
  }


}