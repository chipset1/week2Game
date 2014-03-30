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