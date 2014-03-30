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