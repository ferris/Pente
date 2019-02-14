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

String version = "Alpha 2.1.0";
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
}

void draw() {
  if (room.equals("mainMenu")) {
    mainMenu();
  } else if (room.equals("modeMenu")) {
    modeMenu();
  } else if (room.equals("game")) {
    game.drawBoard();
    game.drawPieces();
    game.turnGeneration();
    game.drawTurnIndication();
    game.drawCaptureIndication();
    game.winnerAlert();
  }
  mouseReleased = false;
}

void mouseClicked() {
  mouseReleased = true;
}
