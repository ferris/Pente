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
 Last updated 2019/01/16
*/

// SAVE NOTES:
/*
  • Everything is now  " a e s t h e t i c "
  • We could optimize the framework for when every piece is drawn, not every frame.
  • Now it's time to get online multiplayer working.
  • Then we can move on and try to get the impossible computer working.
  • After that we can make a percentage of impossible usage and minimax scoring in order to change the difficulty
*/

String version = "Alpha 2.0.0";
String room = "mainMenu";
boolean mouseReleased = false;
Game game;

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
  } else if (room.equals("local2player")) {
    game.drawBoard();
    game.drawPieces();
    game.turnGeneration();
    game.drawTurnIndication();
    game.winnerAlert();
  } else if (room.equals("singleMenu")) {
    singleMenu();
  }
  mouseReleased = false;
}

void mouseClicked() {
  mouseReleased = true;
}