/*
 _______                        __               
/       \                      /  |              
$$$$$$$  | ______   _______   _$$ |_     ______  
$$ |__$$ |/      \ /       \ / $$   |   /      \ 
$$    $$//$$$$$$  |$$$$$$$  |$$$$$$/   /$$$$$$  |
$$$$$$$/ $$    $$ |$$ |  $$ |  $$ | __ $$    $$ |
$$ |     $$$$$$$$/ $$ |  $$ |  $$ |/  |$$$$$$$$/ 
$$ |     $$       |$$ |  $$ |  $$  $$/ $$       |
$$/       $$$$$$$/ $$/   $$/    $$$$/   $$$$$$$/

*/

/*
  Pente Development Code
  Written by Ferris Linde
*/

/*
REFERENCES:
- https://medium.com/@quasimik/monte-carlo-tree-search-applied-to-letterpress-34f41c86e238
- https://www.baeldung.com/java-monte-carlo-tree-search
- http://mcts.ai/pubs/mcts-survey-master.pdf
- https://project.dke.maastrichtuniversity.nl/games/files/phd/Nijssen_thesis.pdf
*/

String version = "Monte Carlo Tree Solver";
String room = "mainMenu";
boolean mouseReleased = false;
Game game;
GameAI ai;

void setup() {
  // V-sync
  frameRate(60);
  // Text mode "center"
  textAlign(CENTER);
  size(800, 600);
  // FOR DEBUGING PURPOSES:
  game = new Game("single", 1);
  ai = new GameAI(5000);
  room = "game";
}

void draw() {
  if (room.equals("mainMenu")) {
    mainMenu();
  } else if (room.equals("modeMenu")) {
    modeMenu();
  } else if (room.equals("game")) {
    game.drawBoard();
    game.drawPieces();
    if (!game.gameIsOver()) {
      game.turnGeneration();
    }
    game.drawTurnIndication();
    game.drawCaptureIndication();
    game.winnerAlert();
  }
  mouseReleased = false;
}

void mouseClicked() {
  mouseReleased = true;
}
