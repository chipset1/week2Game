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
