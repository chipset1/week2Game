abstract class GameState {
	GameStateManager gsm;

	abstract void init();
	abstract void update();
	abstract void display();
	
	void restartLevel(){
		
	}
}