abstract class Entity {
	PImage img;

	float tintAlpha = 20;
	float tintColor = 255;

	int fillColor = 255;

	// original_position used for restarting the level
	PVector original_position, position, velocity;
	float orientation;

	// not really the radius. its the diameter / width and height
	float radius = -1;

	boolean isExpired = false;

	public PVector getSize() { return img == null ? new PVector(0,0) : new PVector(img.width,img.height); }

	abstract void update();

	void display(){

	}

	boolean isCollided(PVector pos){
		if(dist(pos.x, pos.y, this.position.x, this.position.y) < radius){
			return true;
		}
		return false;
	}

	// fix
	boolean colidesWith(PVector pos){
		return false;
    //	return withinBoundingBox(pos, this.position, new PVector(this.radius, this.radius));
    	//return withinBoundingBox(this.position, pos, new PVector(eSize, eSize));
  	}

}
