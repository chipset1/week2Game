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