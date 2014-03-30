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