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