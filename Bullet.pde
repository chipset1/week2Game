class Bullet extends Entity
{
	color c;
	// enemy only die if this is true
	boolean isPlayerBullet = false;
	float w,h;
	Bullet(PVector pos, PVector vel, color _c, boolean pb){
		isPlayerBullet = pb;
		position = pos.get();
		velocity = vel.get();
		velocity.limit(10);
		w= h = radius = 8;
		c = _c;
	}

	void display(){
		fill(c);
		rect(position.x, position.y,w,h);
	}

	void update(){
		position.add(velocity);
		if(position.x <0 || position.x > width || position.y < 0 || position.y > height){
			//ps.bulletExplode(position.x, position.y);
			this.isExpired = true;
		}
	//	if(velocity.magSq() > 0) orientation = velocity.heading();
	}

}//end of Bullet class
