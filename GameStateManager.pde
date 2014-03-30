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