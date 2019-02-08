import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Pente extends PApplet {

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

public void setup() {
  // V-sync
  frameRate(60);
  // Text mode "center"
  textAlign(CENTER);

  
}

public void draw() {
  if (room.equals("mainMenu")) {
    mainMenu();
  } else if (room.equals("modeMenu")) {
    modeMenu();
  } else if (room.equals("local2player")) {
    game.drawBoard();
    game.capture();
    game.drawPieces();
    game.turnGeneration();
    game.drawTurnIndication();
    game.winnerAlert();
  } else if (room.equals("singleMenu")) {
    singleMenu();
  }
  mouseReleased = false;
}

public void mouseClicked() {
  mouseReleased = true;
}

class AlphaBeta {
    int[] prevMove;
}
class Game {
  int pieces[][] = new int[19][19];
  private int order[][] = new int[19][19];
  int turnCount = 0;
  int turn;
  int winner = 0;
  String mode;
  boolean winDelay = false;

  public Game(String mode, int startingPlayer) {
    this.mode = mode;
    this.turn = startingPlayer;
  }


  // BACK END METHODS
  public void capture() {
    //rows
    for (int r = 0; r < pieces.length -3; ++r) {
      for (int c = 0; c < pieces[r].length - 3; ++c) {
        if (captureHelper(pieces[r][c], pieces[r][c+1], pieces[r][c+2], pieces[r][c+3])) {
          pieces[r][c+1] = 0;
          pieces[r][c+2] = 0;
        }
      }
    }
    // columns
    for (int r = 0; r < pieces.length -3; ++r) {
      for (int c = 0; c < pieces[r].length - 3; ++c) {
        if (captureHelper(pieces[r][c], pieces[r+1][c], pieces[r+2][c], pieces[r+3][c])) {
          pieces[r+1][c] = 0;
          pieces[r+2][c] = 0;
        }
      }
    }
    // down diagnol
    for (int r = 0; r < pieces.length -3; ++r) {
      for (int c = 0; c < pieces.length -3; ++c) {
        if (captureHelper(pieces[r][c], pieces[r+1][c+1], pieces[r+2][c+2], pieces[r+3][c+3])) {
          pieces[r+1][c+1] = 0;
          pieces[r+2][c+2] = 0;
        }
      }
    }
    // up diagnol
    for (int r = 3; r < pieces.length; ++r) {
      for (int c = 0; c < pieces.length -3; ++c) {
        if (captureHelper(pieces[r][c], pieces[r-1][c+1], pieces[r-2][c+2], pieces[r-3][c+3])) {
          pieces[r-1][c+1] = 0;
          pieces[r-2][c+2] = 0;
        }
      }
    }
  }

  public void turnGeneration() {
    if (mode.equals("local")) {
      humanMoveCheck();
    }
  }

  public void placeMarble(int r, int c) {
    if (spotFree(r, c)) {
      turnCount++;
      order[r][c] = turnCount;
      pieces[r][c] = turn;
      if (turn == 1) {
        turn = 2;
      } else if (turn == 2) {
        turn = 1;
      }
    }
  }

  public int winCheck() {
    // row check
    for (int r = 0; r < pieces.length - 4; ++r) {
      for (int c = 0; c < pieces[r].length; ++c) {
        if (winHelper(pieces[r][c],pieces[r+1][c],pieces[r+2][c],pieces[r+3][c],pieces[r+4][c])) {
          return pieces[r][c];
        }
      }
    }
    // column check
    for (int r = 0; r < pieces.length; ++r) {
      for (int c = 0; c < pieces[r].length - 4; ++c) {
        if (winHelper(pieces[r][c],pieces[r][c+1],pieces[r][c+2],pieces[r][c+3],pieces[r][c+4])) {
          return pieces[r][c];
        }
      }
    }
    // down diagonal
    for (int r = 0; r < pieces.length - 4; ++r) {
      for (int c = 0; c < pieces[r].length - 4; ++c) {
        if (winHelper(pieces[r][c],pieces[r+1][c+1],pieces[r+2][c+2],pieces[r+3][c+3],pieces[r+4][c+4])) {
          return pieces[r][c];
        }
      }
    }
    // up diagonal
    for (int r = 4; r < pieces.length; ++r) {
      for (int c = 0; c < pieces[r].length - 4; ++c) {
        if (winHelper(pieces[r][c],pieces[r-1][c+1],pieces[r-2][c+2],pieces[r-3][c+3],pieces[r-4][c+4])) {
          return pieces[r][c];
        }
      }
    }
    return 0;
  }


  // FRONT END METHODS
  public void drawBoard() {
    // base of the board
    strokeWeight(1);
    background(5, 6, 62);
    noStroke();
    fill(214, 151, 97);
    rect(103, 3, 591, 591);
    fill(105, 60, 81);
    stroke(16, 24, 60);
    rect(108, 8, 581, 581);
    fill(214, 151, 97);
    rect(113, 13, 571, 571);
    // grid lines
    stroke(16, 24, 60);
    for (int i = 65; i <= 533; i+=26) {
      line(165, i, 633, i);
      line(i+100, 65, i+100, 532);
    }
    // guider overlay
    strokeWeight(3);
    line(165, 300, 663, 300);
    line(400, 65, 400, 563);
    strokeWeight(2);
    arc(140, 300, 104, 104, radians(241), radians(480), CHORD);
    arc(659, 300, 104, 104, radians(62), radians(298), CHORD);
    arc(399, 40, 104, 104, radians(331), radians(570), CHORD);
    arc(399, 559, 104, 104, radians(152), radians(388), CHORD);
    strokeWeight(3);
    ellipse(321, 221, 2, 2);
    ellipse(243, 143, 2, 2);
    ellipse(477, 221, 2, 2);
    ellipse(555, 143, 2, 2);
    ellipse(243, 455, 2, 2);
    ellipse(321, 377, 2, 2);
    ellipse(477, 377, 2, 2);
    ellipse(555, 455, 2, 2);
  }

  public void drawPieces() {
    for (int i = 0; i < pieces.length; ++i) {
      for (int j = 0; j < pieces[i].length; ++j) {
        if (pieces[i][j] == 1) {
          strokeWeight(2);
          stroke(10, 120, 140);
          fill(90, 200, 220);
          ellipse(j*26+165, i*26+65, 20, 20);
        } else if (pieces[i][j] == 2) {
          strokeWeight(2);
          stroke(175, 60, 0);
          fill(255, 140, 0);
          ellipse(j*26+165, i*26+65, 20, 20);
        }
      }
    }
  }

  public void drawTurnIndication() {
    noStroke();
    fill(8, 10, 102);
    rect(710, 80, 74, 85);
    textSize(12);
    fill(255);
    text("Turn:", 747, 95);
    if (turn == 1) {
      stroke(10, 120, 140);
      fill(90, 200, 220);
      rect(714, 100, 66, 60, 7);
      fill(0, 110, 130);
      text("BLUE", 747, 130);
    } else if (turn == 2) {
      stroke(175, 60, 0);
      fill(255, 140, 0);
      rect(714, 100, 66, 60, 7);
      fill(175, 60, 0);
      text("ORANGE", 747, 130);
    }
  }

  public void winnerAlert() {
    if (winner == 0) {
      winner = winCheck();
    }
    if (winner != 0) {
      int darkC;
      int lightC;
      String alertText;
      if (winner == 2) {
        darkC = color(175, 60, 0);
        lightC = color(255, 140, 0);
        alertText = "Orange Wins!";
      } else {
        darkC = color(0, 110, 130);
        lightC = color(90, 200, 220);
        alertText = "Blue Wins!";
      }
      stroke(darkC);
      strokeWeight(10);
      fill(lightC);
      rect(150, 150, 500, 300, 50);
      rect(150, 500, 500, 100, 50);
      textSize(64);
      fill(darkC);
      text(alertText, 400, 300);
      textSize(16);
      text("Back to Menu", 400, 525);
      if (mouseX > 150 && mouseX < 550 && mouseY > 150 && mouseY < 600) {
        if (mouseReleased && winDelay) {
          room = "mainMenu";
        }
      }
      winDelay = true;
    }
  }

  
  // PRIVATE HELPERS
  private boolean captureHelper(int c1, int c2, int c3, int c4) {
    return c1 != 0 && c1 == c4 && c2 == c3 && c1 != c2;
  }

  private boolean spotFree(int r, int c) {
    return pieces[r][c] == 0 && winner == 0;
  }

  private boolean winHelper(int c1, int c2, int c3, int c4, int c5) {
    return c1 != 0 && c1 == c2 && c2 == c3 && c3 == c4 && c4 == c5;
  }
}
public void humanMoveCheck() {
  if (155 < mouseX && mouseX <= 646 && 52 <= mouseY && mouseY <= 543) {
    noFill();
    stroke(16, 24, 60);
    ellipse((mouseX/26)*26+9, (mouseY/26)*26+13, 20, 20);
    if (mouseReleased) {
      int r = ((mouseY - 52) - (mouseY - 52) % 26) / 26;
      int c = ((mouseX - 155) - (mouseX - 155) % 26) / 26;
      game.placeMarble(r, c);
    }
  }
}
public void mainMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(150, 300, 500, 100, 50);
  textAlign(CENTER);
  textSize(11);
  text(version, 765, 10);
  textSize(118);
  text("Pente", 400, 200);
  fill(236, 240, 241);
  textSize(72);
  text("PLAY", 400, 375);

  // play button
  if (mouseReleased && mouseX > 150 && mouseX < 650 && mouseY < 400 && mouseY > 150) {
    room = "modeMenu";
  }
}


public void modeMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(200, 50, 400, 100, 50);
  rect(200, 250, 400, 100, 50);
  rect(200, 450, 400, 100, 50);
  rect(75, 50, 50, 500, 25);
  fill(236, 240, 241);
  triangle(85, 275, 115, 305, 115, 245);
  textAlign(CENTER);
  textSize(118);
  textSize(42);
  text("Single Player", 400, 115);
  text("Local Multiplayer", 400, 315);
  text("Online Multiplayer", 400, 515);

  // BUTTONS
  // single player button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 150 && mouseY > 50) {
    room = "singleMenu";
  }
  // local multiplayer button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    game = new Game("local", 1);
    room = "local2player";
  }
  // online multiplayer button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    room = "mainMenu";
  }
  // back button
  if (mouseReleased && mouseX > 75 && mouseX < 125 && mouseY < 550 && mouseY > 50) {
    room = "mainMenu";
  }
}


public void singleMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(200, 50, 400, 100, 50);
  rect(200, 250, 400, 100, 50);
  rect(200, 450, 400, 100, 50);
  rect(75, 50, 50, 500, 25);
  fill(236, 240, 241);
  triangle(85, 275, 115, 305, 115, 245);
  textAlign(CENTER);
  textSize(118);
  textSize(42);
  text("Easy", 400, 115);
  text("Medium", 400, 315);
  text("Hard", 400, 515);

  // BUTTONS
  // easy button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 150 && mouseY > 50) {
    room = "mainMenu";
  }
  // medium button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    room = "mainMenu";
  }
  // hard button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    room = "mainMenu";
  }
  // back button
  if (mouseReleased && mouseX > 75 && mouseX < 125 && mouseY < 550 && mouseY > 50) {
    room = "modeMenu";
  }
}


  public void settings() {  size(800, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Pente" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
