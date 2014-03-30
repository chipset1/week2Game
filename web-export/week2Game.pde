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
class Animation1 extends GameState{
	Player player;
	boolean showText = false;
	float start ;
	float endStart ;

	int bAlpha = 10;

	Animation1(GameStateManager gsm){
 		this.gsm = gsm;
 	}
	void init(){
		player = new Player(width/2, height -30);
		start = millis();
	}

	void update(){
		player.update();
		gsm.hud.bulletCount = player.max_bullets;	
	}

	void display(){
		fill(20,bAlpha);
		rect(0,0, width, height);
		player.display();
		
		 coolEffect();
		fill(#F173E7);
		// wait for 2 seconds before showing the person and text
		if(millis() - start > 3000 ){
			rect(width/2, height/2, 20,20);	
			if(player.max_bullets < 500)text("You will need these!",width/2 + 40, height /2 + 20);
			player.max_bullets++;
			bAlpha +=0.1;
		} 
		if(player.max_bullets >= 500){
			gsm.nextState();
		} 
		

		
		
	}

	void coolEffect(){
				fill(random(100,123));
				String s = ""+random(500,2000);
				rect(random(width),random(height),random(20),random(20));	
	}
}
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
class EndMenuState extends GameState{

	EndMenuState(GameStateManager gsm){
		this.gsm = gsm;
	}	

	void init(){

	}

	void update(){
		background(0);
	}

	void display(){
		text("THE END thanks for playing", width/2, height/2);
	}

	void restartLevel(){
		//gsm.nextState();	
	}


}
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
class EntityManager{
	//TODO make lists static and reinitilize objects on death 
	ArrayList<Entity> entities = new ArrayList<Entity>();
	ArrayList<Enemy> enemies = new ArrayList<Enemy>();
	ArrayList<Bullet> bullets = new ArrayList<Bullet>();


	Player player;

	boolean isUpdating;
	// this might be over kill 
	ArrayList<Entity> addedEntities = new ArrayList<Entity>();

	int count(){
		return entities.size();
	}
	int enemyCount(){
		return enemies.size();
	}	

	void addPlayer(Player p){
		player = p;
	}

	void removeAll(){
		for (int i = 0; i < entities.size(); ++i) {
			Entity e = entities.get(i);
			e.isExpired = true;
		}
	}

	void killAllEnemies(){
		for (int i = 0; i < entities.size(); i++) {
			Entity e = entities.get(i);
			if(e.isExpired != true){
				if(e instanceof Enemy){
				e.isExpired = true;	
				}
			}
		}
	}

	void add(Entity entity){
		if(!isUpdating){
			addEntity(entity);
		}else{
			addedEntities.add(entity);
		}
	}

	void addEntity(Entity entity){
		entities.add(entity);
		if(entity instanceof Bullet){
			bullets.add((Bullet)entity);
		} 
		if(entity instanceof Enemy){
			enemies.add((Enemy)entity);
		}
	}

	void update(){
		isUpdating = true;
		for (Entity e : entities) {
			e.update();
		}

		isUpdating = false;

		for (Entity e : addedEntities) {
			// use entity manager add NOT entities.add
			add(e);
		}

		addedEntities.clear();

		for(int i = entities.size() -1; i >= 0; i--){
			Entity e = entities.get(i);
			if(e.isExpired){
				entities.remove(e);
				if(e instanceof Bullet){
					bullets.remove((Bullet)e);	
				}
				if(e instanceof Enemy){
					enemies.remove((Enemy)e);
				}
			}
		}
		handleCollisions();
	}
	//seperates the enemies
	void handleCollisions(){
		for(Enemy e: enemies){
			if(e.isCollided(player.position)){
				//println("player is dead");
				player.isExpired = true;
				break;
			}
			bulletCollision(e);
		}
	}

	void bulletCollision(Enemy e){
		for(int i =0;i < bullets.size(); i++){
			Bullet b = bullets.get(i);
				if(e.isCollided(b.position) && b.isPlayerBullet){
					e.isExpired = true;
					//println("ps ex");
					//ps.enemyExplode(e.position.x, e.position.y);
				}
				if(player.isCollided(b.position) && !b.isPlayerBullet){
					//println("player got shot");
					//ps.enemyExplode(player.position.x, player.position.y);
					player.isExpired = true;
				}

		}
	}

	public void display(){
		for (Entity e : entities) {
			e.display();
		}
	}
}//
abstract class GameState {
	GameStateManager gsm;

	abstract void init();
	abstract void update();
	abstract void display();
	
	void restartLevel(){
		
	}
}
class GameStateManager {
	ArrayList<GameState> gameStates;
	int currentState;
	// not sure if this is good 
	EntityManager entityManager;
	Hud hud;
	// used for player to stop updating
	boolean eCanUpdate = true;
	//int MENUSTATE = 
	
	GameStateManager() {
		gameStates = new ArrayList<GameState>();
		hud = new Hud();
		currentState = 0;
		entityManager = new EntityManager();
		// currentState = MENUSTATE;
		// currentState = LEVEL1STATE;
		gameStates.add(new MenuState(this));
		hud.currentLevelText = "1";
		gameStates.add(new Level1State(this));
		gameStates.add(new Level2State(this));
		gameStates.add(new Level3State(this));
		gameStates.add(new Level4State(this));
		gameStates.add(new Level5State(this));
		gameStates.add(new Animation1(this));
		gameStates.add(new Level6State(this));
		gameStates.add(new EndMenuState(this));
		setState(0);
	}

	void addPlayer(Player p){
		entityManager.addPlayer(p);
	}

	//go to next level
	void nextState(){
		currentState++;
		gameStates.get(currentState).init();
	}

	void setState(int state) {
    	currentState = state;
    	//hud.currentLevelText = ""+currentState+1;
		gameStates.get(currentState).init();
	}

	void addEntity(Entity e){
		if(e == null){
			return;	
		}
		entityManager.add(e);	
	}

	void removeAll(){
		entityManager.removeAll();
	}
	
	void update() {
		gameStates.get(currentState).update();
		if(eCanUpdate)entityManager.update();
		if(keyPressed && key == ' '){
		 gameStates.get(currentState).restartLevel();	
		}

	}
	
	void display() {
		gameStates.get(currentState).display();
		entityManager.display();
		
		hud.update();

	}
	
	void keyPressed() {
	}
	
	void keyReleased() {
	}
}
class Hud{
	int hudWidth, hudHeight;
	int fontSize= 16;
	
	int currentLevel = 1;
	int bulletCount  = 0;
	PFont guiFont;
	String currentLevelText;
	String gameOverText;
	String bulletCountText;

	Hud(){
		hudWidth = width;
		hudHeight = height;
		//setup text()
		gameOverText = "Game Over";
		guiFont = createFont("Anonymous Pro Minus", fontSize);
		textFont(guiFont);
	}



	void update(){
		updateHUD();
	}

	void updateHUD(){
		fill(255);
		//text(frameRate, 40,40);
		bulletCountText = "no. of bullets " + bulletCount;
		fill(255);
		text(bulletCountText, 25, hudHeight - 50, 0);
	}
	
	void endGame(){
		
	}
}
class Keyboard {
  Boolean holdingUp,holdingRight,holdingLeft,holdingDown,holdingZ,
  holdingW,holdingA,holdingS,holdingD,holdingM;
  
  Keyboard() {
    holdingUp=holdingRight=holdingLeft=holdingDown=holdingZ=holdingW=holdingA=holdingS=holdingD=holdingM=false;
  }

  void pressKey(int key,int keyCode) {
    if (keyCode == UP) {
      holdingUp = true;
    }
    if (keyCode == LEFT) {
      holdingLeft = true;
    }
    if (keyCode == RIGHT) {
      holdingRight = true;
    }
    if (keyCode == DOWN) {
      holdingDown = true;
    }
    if (key == 'z' || key == 'Z') {
      holdingZ = true;      
    }
    if (key == 'w' || key == 'W') {
      holdingW = true;      
    }
    if (key == 'a' || key == 'A') {
      holdingA = true;      
    }
    if (key == 's' || key == 'S') {
      holdingS = true;      
    }
    if (key == 'd' || key == 'D') {
      holdingD = true;      
    }
    if (key == 'm' || key == 'M') {
      holdingM = true;      
    }
   
    /* // reminder: for keys with letters, check "key"
       // instead of "keyCode" !
    if (key == 'r') {
      // reset program?
    }
    if (key == ' ') {
      holdingSpace = true;
    }*/
  }
  void releaseKey(int key,int keyCode) {
    if(key == 'z') {
      holdingZ = false;
    }
    if (keyCode == UP) {
      holdingUp = false;
    }
    if (keyCode == LEFT) {
      holdingLeft = false;
    }
    if (keyCode == RIGHT) {
      holdingRight = false;
    }
    if (keyCode == DOWN) {
      holdingDown = false;
    }
    if (key == 'z' || key == 'Z') {
      holdingZ = false;      
    }
    if (key == 'w' || key == 'W') {
      holdingW = false;      
    }
    if (key == 'a' || key == 'A') {
      holdingA = false;      
    }
    if (key == 's' || key == 'S') {
      holdingS = false;      
    }
    if (key == 'd' || key == 'D') {
      holdingD = false;      
    }
    if (key == 'm' || key == 'M') {
      holdingD = false;      
    }
  }
}
class Level1State extends GameState {
	Map map;
 	Player player;
	Enemy e1;
 	Level1State(GameStateManager gsm){
 		this.gsm = gsm;
   		init();
 	}

	void init(){
		player = new Player(width/2, height/2);
		player.max_bullets = 5;
		map = new Map(0,0,width,height);
		e1 = new Enemy(width/2, 100);
		gsm.addEntity(e1);
		gsm.addPlayer(player);
	}

	void restartLevel(){
		gsm.removeAll();
		init();
		//clear screen
	}

	void update(){
		background(123);
		player.update();
		
		map.withinMapBounds(player.position);
		aim();
		if(player.isMoving() || levelComplete()){
			if(!e1.isExpired) gsm.addEntity(e1.shootAt(player.position,1000));
			levelUpdate();
			gsm.eCanUpdate = true;
		}else{
			gsm.eCanUpdate = false;
		}
	}

	boolean levelComplete(){
		return gsm.entityManager.enemyCount() <=0;
	}
	void levelUpdate(){
		// if all the enemies in the level are dead show the exit zone and then transtion to next level
		if(levelComplete()){
			map.displayExitZone();
			if(map.inExitZone(player.position)){

				if(map.playTrasition(1000)){
					player.stopMovement(); // stop the player from moving 
					player.fillColor = (int) random(255);
				}else if(map.transOver){
					gsm.setState(LEVEL2STATE);
				}
			}
		}
		
		pTryToFire();
	}

	void pTryToFire(){
		if (mousePressed) {
	        PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	        Bullet b = player.shoot(player.position,shot_vel);
        	gsm.addEntity(b);
    	} 
	}

	void display(){
		gsm.hud.bulletCount = player.max_bullets;
		map.display();
		player.display();
	}

	void aim(){
		  PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
		  shot_vel.normalize();
		  PVector pos = player.position.get();
		  shot_vel.mult(20);
		  pos.add(shot_vel);
		  player.displayRectCrossHair(pos,10, 10);
		  if(mousePressed){
		      gsm.addEntity(player.shoot(pos, shot_vel));
		 }
	}
}
class Level2State extends GameState {
	Map map;
 	Player player;
 	Enemy e1,e2,e3;
 	Level2State(GameStateManager gsm){
 		this.gsm = gsm;
   		//init();
 	}

	void init(){
		player = new Player(width/2, height/2);
		player.max_bullets = 5;
		map = new Map(0,0,width,height);
		e1 = new Enemy(width/2, 100);
		e2 = new Enemy(width/2 - 200, 100);
		e3 = new Enemy(width/2 + 200, 100);
		gsm.addEntity(e1);
		gsm.addEntity(e2);
		gsm.addEntity(e3);
		gsm.addPlayer(player);
	}

	void restartLevel(){
		gsm.removeAll();
		init();
		//clear screen
	}

	void display(){
		gsm.hud.bulletCount = player.max_bullets;
		map.display();
		map.withinMapBounds(player.position);
		player.display();
	}

	void update(){
		background(123);
		player.update();
		aim();
		if(player.isMoving() || levelComplete()){
			// enemy shoot at player
			if(!e1.isExpired) gsm.addEntity(e1.shootAt(player.position,1000));
			if(!e2.isExpired) gsm.addEntity(e2.shootAt(player.position,1000));
			if(!e3.isExpired) gsm.addEntity(e3.shootAt(player.position,1000));
			levelUpdate();
			gsm.eCanUpdate = true;
		}else{
			gsm.eCanUpdate = false;
		}
	}

	boolean levelComplete(){
		return gsm.entityManager.enemyCount() <=0;
	}

	void levelUpdate(){
		// if all the enemies in the level are dead show the exit zone and then transtion to next level
		if(levelComplete()){
			map.displayExitZone();
			if(map.inExitZone(player.position)){
				if(map.playTrasition(1000)){
					player.stopMovement(); // stop the player from moving 
					player.fillColor = (int) random(255);
				}else if(map.transOver){
					// go to level 3 
					gsm.setState(LEVEL3STATE);
				}
			}
		}
		pTryToFire();
	}

	void pTryToFire(){
		if (mousePressed) {
	        PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	        Bullet b = player.shoot(player.position,shot_vel);
        	gsm.addEntity(b);
    	} 
	}

	void aim(){
	  	PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
		shot_vel.normalize();
		PVector pos = player.position.get();
		shot_vel.mult(20);
		pos.add(shot_vel);
		player.displayRectCrossHair(pos,10, 10);
		if(mousePressed){
			gsm.addEntity(player.shoot(pos, shot_vel));
		}	  
	}

}
class Level3State extends GameState{
	Map map;
 	Player player;
 	Enemy e1,e2,e3;
 	Level3State(GameStateManager gsm){
 		this.gsm = gsm;
   		//init();
 	}

	void init(){
		player = new Player(width/2, height/2);
		player.max_bullets = 1;
		map = new Map(0,0,width,height);
		e1 = new Enemy(width/2, 100);
		e2 = new Enemy(width/2 - 200, 100);
		e3 = new Enemy(width/2 + 200, 100);
		gsm.addEntity(e1);
		gsm.addEntity(e2);
		gsm.addEntity(e3);
		gsm.addPlayer(player);
	}

	void restartLevel(){
		gsm.removeAll();
		init();
		//clear screen
	}

	void display(){
		gsm.hud.bulletCount = player.max_bullets;
		map.display();
		map.withinMapBounds(player.position);
		player.display();
	}

	void update(){
		background(123);
		player.update();
		aim();
		if(player.isMoving() || levelComplete()){
			// enemy shoot at player
			if(!e1.isExpired) gsm.addEntity(e1.shootAt(player.position,500));
			if(!e2.isExpired) gsm.addEntity(e2.shootAt(player.position,500));
			if(!e3.isExpired) gsm.addEntity(e3.shootAt(player.position,500));
			levelUpdate();
			gsm.eCanUpdate = true;
		}else{
			gsm.eCanUpdate = false;
		}
	}

	boolean levelComplete(){
		return gsm.entityManager.enemyCount() <=0;
	}

	void levelUpdate(){
		// if all the enemies in the level are dead show the exit zone and then transtion to next level
		if(levelComplete()){
			map.displayExitZone();
			if(map.inExitZone(player.position)){
				if(map.playTrasition(1000)){
					player.stopMovement(); // stop the player from moving 
					player.fillColor = (int) random(255);
				}else if(map.transOver){
					// go to level 3 
					// should make uses static ints
					gsm.setState(LEVEL4STATE);
				}
			}
		}
		
		pTryToFire();
	}

	void pTryToFire(){
		if (mousePressed) {
	        PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	        Bullet b = player.shoot(player.position,shot_vel);
        	gsm.addEntity(b);
    	} 
	}

	void aim(){
	  	PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
		shot_vel.normalize();
		PVector pos = player.position.get();
		shot_vel.mult(20);
		pos.add(shot_vel);
		player.displayRectCrossHair(pos,10, 10);
		if(mousePressed){
			gsm.addEntity(player.shoot(pos, shot_vel));
		}	  
	}
}
class Level4State extends GameState{
	Map map;
 	Player player;
 	Enemy e1,e2,e3;
 	Level4State(GameStateManager gsm){
 		this.gsm = gsm;
   		//init();
 	}

	void init(){
		player = new Player(width/2, height/2);
		player.max_bullets = 1;
		map = new Map(0,0,width,height);
		e1 = new Enemy(width/2, 100);
		e2 = new Enemy(width/2 - 200, 100);
		e3 = new Enemy(width/2 + 200, 100);
		gsm.addEntity(e1);
		gsm.addEntity(e2);
		gsm.addEntity(e3);
		gsm.addPlayer(player);
	}

	void restartLevel(){
		gsm.removeAll();
		init();
		//clear screen
	}

	void display(){
		gsm.hud.bulletCount = player.max_bullets;
		map.display();
		map.withinMapBounds(player.position);
		player.display();
	}

	void update(){
		background(123);
		player.update();
		aim();
		if(player.isMoving() || levelComplete()){
			// enemy shoot at player
			if(!e1.isExpired) gsm.addEntity(e1.shootAt(player.position,50));
			if(!e2.isExpired) gsm.addEntity(e2.shootAt(player.position,50));
			if(!e3.isExpired) gsm.addEntity(e3.shootAt(player.position,50));
			levelUpdate();
			gsm.eCanUpdate = true;
		}else{
			gsm.eCanUpdate = false;
		}
	}

	boolean levelComplete(){
		return gsm.entityManager.enemyCount() <=0;
	}

	void levelUpdate(){
		// if all the enemies in the level are dead show the exit zone and then transtion to next level
		if(levelComplete()){
			map.displayExitZone();
			if(map.inExitZone(player.position)){
				if(map.playTrasition(1000)){
					player.stopMovement(); // stop the player from moving 
					player.fillColor = (int) random(255);
				}else if(map.transOver){
					// go to level 3 
					// should make uses static ints
					gsm.setState(LEVEL5STATE);
				}
			}
		}
		
		pTryToFire();
	}

	void pTryToFire(){
		if (mousePressed) {
	        PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	        Bullet b = player.shoot(player.position,shot_vel);
        	gsm.addEntity(b);
    	} 
	}

	void aim(){
	  	PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
		shot_vel.normalize();
		PVector pos = player.position.get();
		shot_vel.mult(20);
		pos.add(shot_vel);
		player.displayRectCrossHair(pos,10, 10);
		if(mousePressed){
			gsm.addEntity(player.shoot(pos, shot_vel));
		}	  
	}
}
class Level5State extends GameState{
	Map map;
 	Player player;
 	SeekerEnemy e1,e2,e3;
 	Level5State(GameStateManager gsm){
 		this.gsm = gsm;
   		//init();
 	}

	void init(){
		player = new Player(width/2, height/2);
		player.max_bullets = 1;
		gsm.hud.currentLevelText = "5";
		map = new Map(0,0,width,height);

		e1 = new SeekerEnemy(width/2, 100);
		e2 = new SeekerEnemy(width/2 - 200, 100);
		e3 = new SeekerEnemy(width/2 + 200, 100);

		gsm.addEntity(e1);
		gsm.addEntity(e2);
		gsm.addEntity(e3);
		gsm.addPlayer(player);
	}

	void restartLevel(){
		gsm.removeAll();
		init();
		//clear screen
	}

	void display(){
		gsm.hud.bulletCount = player.max_bullets;
		map.display();
		map.withinMapBounds(player.position);
		player.display();
	}

	void update(){
		background(123);
		player.update();
		aim();
		map.updateBlock(player.position);
		if(player.isMoving() || levelComplete()){
			// enemy shoot at player
			// if(!e1.isExpired) gsm.addEntity(e1.shootAt(player.position,200));
			// if(!e2.isExpired) gsm.addEntity(e2.shootAt(player.position,200));
			if(!e3.isExpired) gsm.addEntity(e3.shootAt(player.position,200));
			levelUpdate();
			e1.seek(player.position);
			e2.seek(player.position);
			e3.seek(player.position);
			gsm.eCanUpdate = true;
		}else{
			gsm.eCanUpdate = false;
		}
	}

	boolean levelComplete(){
		return gsm.entityManager.enemyCount() <=0;
	}

	void levelUpdate(){
		// if all the enemies in the level are dead show the exit zone and then transtion to next level
		if(levelComplete()){
			map.displayExitZone();
			if(map.inExitZone(player.position)){
				if(map.playTrasition(1000)){
					player.stopMovement(); // stop the player from moving 
					player.fillColor = (int) random(255);
				}else if(map.transOver){
					gsm.setState(LEVEL6STATE);
				}
			}
		}
		
		pTryToFire();
	}

	void pTryToFire(){
		if (mousePressed) {
	        PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	        Bullet b = player.shoot(player.position,shot_vel);
        	gsm.addEntity(b);
    	} 
	}

	void aim(){
		  PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
		  shot_vel.normalize();
		  PVector pos = player.position.get();
		  shot_vel.mult(20);
		  pos.add(shot_vel);
		  player.displayRectCrossHair(pos,10, 10);
		  if(mousePressed){
		      gsm.addEntity(player.shoot(pos, shot_vel));
		 }
	}
}
class Level6State extends GameState{

	Map map;
 	Player player;
 	ArrayList<SeekerEnemy> elist = new ArrayList<SeekerEnemy>();
 	Enemy e1,e2,e3;
 	Level6State(GameStateManager gsm){
 		this.gsm = gsm;
   		//init();
 	}

	void init(){
		player = new Player(width/2, height/2);
		player.max_bullets = 500;
		gsm.hud.currentLevelText = "5";
		map = new Map(0,0,width,height);
		e1 = new Enemy(width/2, 100);
		e2 = new Enemy(width/2 - 200, 100);
		e3 = new Enemy(width/2 + 200, 100);
		gsm.addEntity(e1);
		gsm.addEntity(e2);
		gsm.addEntity(e3);
    	gsm.addPlayer(player);
		addEnemies();
	}

	void restartLevel(){
		gsm.removeAll();
		init();
		//clear screen
	}

	void addEnemies(){
		for (int i = 0; i < 10; ++i) {
			float x = i;
			float y = floor(i / 10);

			SeekerEnemy s = new SeekerEnemy(60 * x  +100, 30 * y + height /2 + 200);
			elist.add(s);
			gsm.addEntity(s);
		}
		for (int i = 0; i < 10; ++i) {
			float x = i;
			float y = floor(i / 10);

			SeekerEnemy s = new SeekerEnemy(60 * x  +100, 30 * y + 50);
			elist.add(s);
			gsm.addEntity(s);
		}

	}

	void display(){
		gsm.hud.bulletCount = player.max_bullets;
		map.display();
		map.withinMapBounds(player.position);
		player.display();
	}

	void update(){
		background(123);
		player.update();
		aim();
		map.updateBlock(player.position);
		if(player.isMoving() || levelComplete()){
			// enemy shoot at player
			levelUpdate();
			if(!e1.isExpired) gsm.addEntity(e1.shootAt(player.position,50,10));
			if(!e2.isExpired) gsm.addEntity(e2.shootAt(player.position,50,10));
			if(!e3.isExpired) gsm.addEntity(e3.shootAt(player.position,50,10));
			for (int i = 0; i < elist.size(); ++i) {
				elist.get(i).seek(player.position);	
				elist.get(i).separate(elist);
			}
			gsm.eCanUpdate = true;
		}else{
			gsm.eCanUpdate = false;
		}
	}

	boolean levelComplete(){
		return gsm.entityManager.enemyCount() <=0;
	}

	void levelUpdate(){
		// if all the enemies in the level are dead show the exit zone and then transtion to next level
		if(levelComplete()){
			map.displayExitZone();
			if(map.inExitZone(player.position)){
				if(map.playTrasition(1000)){
					player.stopMovement(); // stop the player from moving 
					player.fillColor = (int) random(255);
				}else if(map.transOver){
					gsm.nextState();
				}
			}
		}
		
		pTryToFire();
	}

	void pTryToFire(){
		if (mousePressed) {
	        PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	        Bullet b = player.fastShoot(player.position,shot_vel);
        	gsm.addEntity(b);
    	} 
	}

	void aim(){
		  PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
		  shot_vel.normalize();
		  PVector pos = player.position.get();
		  shot_vel.mult(20);
		  pos.add(shot_vel);
		  player.displayRectCrossHair(pos,10, 10);
		  if(mousePressed){
		      gsm.addEntity(player.fastShoot(pos, shot_vel));
		 }
	}
	
	// void aim(){
	// 	PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	// 	shot_vel.normalize();
	// 	PVector pos = player.position.get();
	// 	shot_vel.mult(10);
	// 	pos.add(shot_vel);
	// 	PVector rand = randomVector();
	// 	rand.mult(random(1,3));
	// 	rectMode(CENTER);
	// 	pos.add(rand);
	// 	player.displayRectCrossHair(pos,25, 25);
	// 	rectMode(CORNER);
	// 	if(mousePressed){
	// 	    gsm.addEntity(player.shoot(pos, shot_vel));
	// 	}
	// }


}
class Level7State {


	// void aim(){
	// 	PVector shot_vel = PVector.sub(new PVector(mouseX, mouseY), player.position);
	// 	shot_vel.normalize();
	// 	PVector pos = player.position.get();
	// 	shot_vel.mult(10);
	// 	pos.add(shot_vel);
	// 	PVector rand = randomVector();
	// 	rand.mult(random(1,3));
	// 	rectMode(CENTER);
	// 	pos.add(rand);
	// 	player.displayRectCrossHair(pos,25, 25);
	// 	rectMode(CORNER);
	// 	if(mousePressed){
	// 	    gsm.addEntity(player.shoot(pos, shot_vel));
	// 	}
	// }
}
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
class MenuState extends GameState{

	MenuState(GameStateManager gsm){
		this.gsm = gsm;
	}	

	void init(){

	}

	void update(){
		background(0);
	}

	void display(){
		text("Week 2 game \n press space to start", width/2, height/2);
	}

	void restartLevel(){
		gsm.nextState();	
	}

}
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
// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {


  ArrayList<Particle> particles;   
  color c1 = color(204, 153, 0);
 

  ParticleSystem() {
    particles = new ArrayList(); 
  }
  void run() {
      for (int i = particles.size()-1; i >= 0; i--) {
          Particle p = particles.get(i);
          p.run();
          if (p.isDead()) {
            particles.remove(i);
          }
      }
  }

  void addParticle(float x, float y) {
    particles.add(new Particle(x,y));
  }

  void applyForce(PVector f) {
    for (int i = 0; i < particles.size(); ++i) {
      Particle p = particles.get(i);
      p.applyForce(f);
    }
  }

  void enemyExplode(float x, float y){
     for(int i = 0; i < 30; i++){
        Particle p = new Particle(x,y);
        p.lifespan = 500;
        p.vel = randomVector();
        p.strokeColor = 123;
        particles.add(p);
      } 
  }

  //(float x, float y, PVector _vel,float lifespan, float size, color _c)
  void enemyExplode(float x, float y, float lifespan, int strokeColor){
     for(int i = 0; i < 10; i++){
     //   Particle p = new Particle(x,y,explodeVec,c, random(0.3,0.6));
        Particle p = new Particle(x,y);
        p.lifespan = lifespan;
        p.vel.mult(random(6,8));
        p.strokeColor = strokeColor;
        particles.add(p);
      } 
  }

  void hitPlayerExplode(float x, float y, PVector heading){
    // heading is the enemies velocity on death
    for (int i = 0; i < 40; i++) {
        Particle p = new Particle(x,y);
        p.lifespan = 250;
        p.strokeColor = 255;
        //p.vel = heading;
        p.vel = PVector.add(randomVector(.2), heading);
        //p.vel.mult(random(.3,.4));
        //p.vel.limit(20);
        particles.add(p);       
    } 
  }

  void bulletExplode(float x, float y){
      for(int i = 0; i < 5; i++){
        println("be");
        // color the particles white 25% of the time
        color c = random(1.0) > .25 ? color(random(120,150), 255,255): 255;
        Particle p = new Particle(x,y);
        p.lifespan = 250;
        p.strokeColor = c;
        particles.add(p);
      }
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } 
    else {
      return false;
    }
  }
  
}
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
class SoundManager{
	boolean muted = false;
	PApplet sketch;
	Minim minim;

	ArrayList<PlayerQueue> queuedSounds;
	ArrayList <String> queuedSoundNames;

	private class PlayerQueue{
		// holds refeence to minim player
		private	ArrayList <AudioPlayer> players;
		private String path;

		public PlayerQueue(String audioPath){
			path = audioPath;
			//println(audioPath);
			players = new ArrayList<AudioPlayer>();
			// load minim player in
			appendPlayer();
		}
		
		private void appendPlayer(){
      		AudioPlayer player = minim.loadFile(path);
      		players.add(player);
    	}

		public void close(){
			for (int i = 0; i < players.size(); ++i) {
				players.get(i).close();	
			}
		}

		public void play(){
			int freePlayerIndex = -1;
			for (int i = 0; i < players.size(); ++i) {
				// set index at the last player thats not playing
				if(players.get(i).isPlaying() == false){
					freePlayerIndex = i ;
					break;
				}	
			}

			// set index at last shot in the list
			if(freePlayerIndex == -1){
				appendPlayer();
				freePlayerIndex = players.size()-1;
			}

			players.get(freePlayerIndex).play();
			// set player play back to the beginning
			players.get(freePlayerIndex).rewind();
		}

		public void setMute(boolean m){
		      for(int i = 0; i < players.size(); i++){
		        if(m){
		          players.get(i).mute();
		        }
		        else{
		          players.get(i).unmute(); 
		        }
		      }
    	}
	} // end of player queue class	

	SoundManager(PApplet _sketch){
		sketch =  _sketch;
		// we pass this to Minim so that it can load files from the data directory
		minim = new Minim(_sketch);
		//console.log(minim);
		queuedSounds = new ArrayList<PlayerQueue>();
		queuedSoundNames = new ArrayList<String>();
	}

	void setMute(boolean isMuted){
		muted = isMuted;

		for (int i = 0; i < queuedSounds.size(); ++i) {
			queuedSounds.get(i).setMute(muted);	
		}
	}

	boolean isMute(){
		return muted;
	}

	void mute(){
		// empty funtion to corespond to the javascript function 
		// change later
	}

	void unmute(){
		// empty funtion to corespond to the javascript function 
		// change later
	}

	void addSound(String soundName){
		queuedSounds.add(new PlayerQueue("audio/" + soundName + ".wav"));
		queuedSoundNames.add(soundName);	
	}

	void playSound(String soundName){
		// don't play is muted
		if(muted){
			return;
		}	

		int index = -1;
		// search sound based on string name
		for (int i = 0; i < queuedSoundNames.size(); i++) {
			if(soundName.equals(queuedSoundNames.get(i))){
				index = i;
				break;
			}	
		}
		// if the sound is found play to sound
		if(index != -1){
			queuedSounds.get(index).play();
		}
	}

	void stop(){
		// closes all the players and minim
		for (int i = 0; i < queuedSounds.size(); ++i) {
			queuedSounds.get(i).close();	
		}
		minim.stop();
	}

}// end of sound manager class

