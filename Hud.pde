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
