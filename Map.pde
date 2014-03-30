class Map{
	// enpasulate rooms and chech bounds

	float x,y,w,h;

	int exit_Width =50;
	int exit_Height = 30;
	int exitZoneFill =255;
	float exitZx = width/2;
	float exitZy = 30;

	float startTime = 0;
	boolean transOver = false;
	float strobeFill = 100;


	ArrayList<Block> blocks;

	Map(float _x, float _y, float _w, float _h){
		x = _x;
		y = _y;
		w= _w;
		h = _h; 
		blocks = new ArrayList<Block>();
	}
	// rename
	boolean playTrasition(float length){
		// add sound here too
		if(millis() - startTime >1000){
					startTime = millis();
					return false;
		}
		transOver = true;
		return true;
	}

	void display(){
		noFill();
		rect(x,y,w,h);
	}

	void addBlock(Block b){
		blocks.add(b);
	}

	void updateBlock(PVector pos){
		if(blocks.size() >= 0){
			//println("run");
			for(Block b : blocks){
				b.display();
				b.bounds(pos);
			}
		}
	}
	
	boolean inExitZone(PVector position){
	  if(position.x  < exitZx ) {
      return false;
      }
      if( position.x > exitZx +exit_Width){
      return false;
      }
      if(position.y < exitZy){
      return false;
      }
      if(position.y > exitZy + exit_Height){
      return false;
      }
      return true;
	}

	void displayExitZone(){
		fill(exitZoneFill);
		rect(exitZx,exitZy,exit_Width , exit_Height);
	}	


	boolean withinMapBounds(PVector position){
      if(position.x - 5 < x ) {
      position.x = x;
      return true;
      }
      if( position.x > w -10){
      position.x = w - 10;
      return true;
      }
      if(position.y  < y){
      position.y = 0;
      return true;
      }
      if(position.y> h - 10){
      position.y = h - 10 ;
      return true;
      }
      return false;
  }
}//end of map class

class Block{
	float x,y,w,h;

	Block(float _x,float _y,float _w,float _h){
		x = _x;
		y = _y;
		w = _w;
		h = _h;
	}

	void display(){
		rect(x,y,w,h);
	}

	// bounce of the block
	void bounds(PVector pos){
		if (pos.x < x && pos.x >x+w) {pos.x = x;}
        if (pos.y < y && pos.y > h) {pos.y = y;}
	}

}