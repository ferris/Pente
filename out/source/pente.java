import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 

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
*/

String version = "Alpha 2.0.1";
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
  } else if (room.equals("game")) {
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

public void mouseClicked() {
  mouseReleased = true;
}



class ABTree {
  private ABNode root;

  ABTree(int[][] board, int[] move) {
    this.root = new ABNode(board, move);
    for (int i = 0; i < board.length; ++i) {
      if (board[i].length != board.length) {
        throw new IllegalArgumentException("Board must be a square!");
      }
    }
    this.root.board = board;
    if (move.length != 2) {
      throw new IllegalArgumentException("Move has to be of length 2; {x, y}");
    }
    this.root.move = move;
  }
}

class ABNode {
  private int[][] board;
  private int[] move;
  private int captures;
  private ABNode parent;
  private List<ABNode> children = new ArrayList<ABNode>();

  ABNode(int[][] board, int[] move) {
    // deep copy to prevent collisions
    this.board = new int[Game.n][Game.n];
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        this.board[i][j] = board[i][j];
      }
    }
    this.move = move.clone();
  }

  public void generateChildren(int player) {
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        int[] move = {i, j};
        if (game.isValidMove(this.board, move)) {
          int index = this.children.size();
          this.children.add(new ABNode(this.board, move));
          ABNode child = children.get(index);
          child.parent = this;
          child.captures = this.captures;
          child.captures += game.isCaptureMove(child.board, player, child.move);
          child.board[move[0]][move[1]] = player;
        }
      }
    }
  }
}


class ABObj {
  int value;
  int[] move;

  ABObj(int value, int[] move) {
    this.value = value;
    if (move.length != 2) {
      throw new IllegalArgumentException("Move has to be of length 2; {x, y}");
    }
    this.move = move;
  }
}


class GameAI {
  private final int SIZE = 19;
  private int[] prevMove;
  private int oCaptures = 0;
  private int tCaptures = 0;

  public int[] alphaBeta(int[][] board, int depth, int player) {
    int beginTime = millis();
    int[] fakeMove = {-1, -1};
    ABTree tree = new ABTree(board, fakeMove);
    ABObj m = minValue(
      tree.root, // node
      depth, // depth
      player, // player
      new ABObj(Integer.MIN_VALUE, fakeMove), // alpha
      new ABObj(Integer.MAX_VALUE, fakeMove) // beta
    );
    int timeTaken = millis() - beginTime;
    println("Processing time: " + timeTaken + "ms");
    println("value: " + m.value);
    return m.move;
  }
  
  public ABObj minValue(ABNode node, int depth, int player, ABObj alpha, ABObj beta) {
    // figure out the opposite player tile (1 = blue; 2 = orange)
    int unplayer;
    if (player == 1) {
      unplayer = 2;
    } else {
      unplayer = 1;
    }
    // return heuristic if leaf
    if (depth == 0) {
      if (player == 2) {
        return new ABObj(heuristic(node.board), node.move);
      } else {
        return new ABObj(heuristic(node.board) * -1, node.move);
      }
    }
    // find children for children
    node.generateChildren(player);
    for (int i = 0; i < node.children.size(); ++i) {
      ABObj m = maxValue(node.children.get(i), depth-1, unplayer, alpha, beta);
      if (m.value < beta.value) {
        if (node.parent == null) {
          beta = m; // return both child value and child move if root
        } else {
          beta.value = m.value;
          beta.move = node.move.clone();
        }
      }
      if (alpha.value >= beta.value) {
        break;
      }
    }
    return beta;
  }

  public ABObj maxValue(ABNode node, int depth, int player, ABObj alpha, ABObj beta) {
    // figure out the opposite player tile (1 = blue; 2 = orange)
    int unplayer;
    if (player == 1) {
      unplayer = 2;
    } else {
      unplayer = 1;
    }
    // return heuristic if leaf
    if (depth == 0) {
      if (player == 2) {
        return new ABObj(heuristic(node.board), node.move);
      } else {
        return new ABObj(heuristic(node.board) * -1, node.move);
      }
    }
    // find children for children
    node.generateChildren(player);
    for (int i = 0; i < node.children.size(); ++i) {
      ABObj m = minValue(node.children.get(i), depth-1, unplayer, alpha, beta);
      if (m.value > alpha.value) {
        print("l" + depth + " pv" + m.value);
        alpha.value = m.value;
        alpha.move = node.move.clone();
      }
      if (alpha.value >= beta.value) {
        break;
      }
    }
    return alpha;
  }
  

  public int heuristic(int[][] board) {
    // this is a super dumb heuristic
    // all it does is see how many tiles are on the board
    // computer tiles - human tiles
    int tileCount = 0;
    int unTileCount = 0;

    for (int i = 0; i < board.length; ++i) {
      for (int j = 0; j < board[i].length; ++j) {
        if (board[i][j] == 2) {
          tileCount++;
        } else if (board[i][j] == 1) {
          unTileCount++;
        }
      }
    }
    return tileCount - unTileCount;
  }
}
class Game {
  public static final int n = 19; // size of board
  private int pieces[][] = new int[n][n]; // board
  private int oCaptures = 0; // captures by player 1
  private int tCaptures = 0; // captures by player 2
  private int turn; // current turn
  private int winner = 0; // the winner
  private String mode; // game mode chosen through menu
  private boolean winDelay = false; // prevents accidental return to menu

  public Game(String mode, int startingPlayer) {
    this.mode = mode;
    this.turn = startingPlayer;
  }


  // BACK END METHODS
  public int isCaptureMove(int[][] board, int movePlayer, int[] move) {
    // checks if capture move and returns number of captures for tallying
    int cCount = 0;

    int unPlayer;
    if (movePlayer == 1) {
      unPlayer = 2;
    } else {
      unPlayer = 1;
    }

    // exception for AI fakeMove
    if (move[0] == -1 && move[1] == -1) {
      return 0;
    }

    // check horizontal captures (-)
    if (move[1] > 2 &&
        board[move[0]][move[1]-1] == unPlayer &&
        board[move[0]][move[1]-2] == unPlayer &&
        board[move[0]][move[1]-3] == movePlayer) {
      board[move[0]][move[1]-1] = 0;
      board[move[0]][move[1]-2] = 0;
      cCount++;
    }

    if (move[1] < n-3 &&
        board[move[0]][move[1]+1] == unPlayer &&
        board[move[0]][move[1]+2] == unPlayer &&
        board[move[0]][move[1]+3] == movePlayer) {
      board[move[0]][move[1]+1] = 0;
      board[move[0]][move[1]+2] = 0;
      cCount++;
    }

    // check vertical captures (|)
    if (move[0] > 2 &&
        board[move[0]-1][move[1]] == unPlayer &&
        board[move[0]-2][move[1]] == unPlayer &&
        board[move[0]-3][move[1]] == movePlayer) {
      board[move[0]-1][move[1]] = 0;
      board[move[0]-2][move[1]] = 0;
      cCount++;
    }

    if (move[0] < n-3 &&
        board[move[0]+1][move[1]] == unPlayer &&
        board[move[0]+2][move[1]] == unPlayer &&
        board[move[0]+3][move[1]] == movePlayer) {
      board[move[0]+1][move[1]] = 0;
      board[move[0]+2][move[1]] = 0;
      cCount++;
    }

    // check diagonal captures (\)
    if (move[0] > 2 && move[1] > 2 &&
        board[move[0]-1][move[1]-1] == unPlayer &&
        board[move[0]-2][move[1]-2] == unPlayer &&
        board[move[0]-3][move[1]-3] == movePlayer) {
      board[move[0]-1][move[1]-1] = 0;
      board[move[0]-2][move[1]-2] = 0;
      cCount++;
    }

    if (move[0] < n-3 && move[1] < n-3 &&
        board[move[0]+1][move[1]+1] == unPlayer &&
        board[move[0]+2][move[1]+2] == unPlayer &&
        board[move[0]+3][move[1]+3] == movePlayer) {
      board[move[0]+1][move[1]+1] = 0;
      board[move[0]+2][move[1]+2] = 0;
      cCount++;
    }

    // check other diagonal captures (/)
    if (move[0] > 2 && move[1] < n-3 &&
        board[move[0]-1][move[1]+1] == unPlayer &&
        board[move[0]-2][move[1]+2] == unPlayer &&
        board[move[0]-3][move[1]+3] == movePlayer) {
      board[move[0]-1][move[1]+1] = 0;
      board[move[0]-2][move[1]+2] = 0;
      cCount++;
    }

    if (move[0] < n-3 && move[1] > 2 &&
        board[move[0]+1][move[1]-1] == unPlayer &&
        board[move[0]+2][move[1]-2] == unPlayer &&
        board[move[0]+3][move[1]-3] == movePlayer) {
      board[move[0]+1][move[1]-1] = 0;
      board[move[0]+2][move[1]-2] = 0;
      cCount++;
    }

    return cCount;
  }


  public boolean isValidMove(int[][] board, int[] move) {
    if (move[0] >= 0 && move[0] < n && move[1] >= 0 && move[1] < n) {
      return (board[move[0]][move[1]] == 0);
    }
    return false;
  }


  public void turnGeneration() {
    boolean newMove = false;
    int[] move = new int[2];
    if (mode.equals("local")) {
      int[] hmc = humanMoveCheck();
      newMove = hmc[0] == 1;
    } else if (mode.equals("single")) {
      if (turn == 1) {
        int[] hmc = humanMoveCheck();
        move = new int[] {hmc[1], hmc[2]};
        newMove = hmc[0] == 1;
      } else {
        println("computer is thinking");
        GameAI ai = new GameAI();
        move = ai.alphaBeta(pieces, 1, turn);
        print("( ");print(move[0]);print(", ");print(move[1]);println(" )");
        newMove = true;
      }
    }
    if (newMove && isValidMove(pieces, move)) {
      // a valid move has been generated --> make the move
      pieces[move[0]][move[1]] = turn;
      // update captures and switch whose turn it is
      if (turn == 1) {
        oCaptures += isCaptureMove(pieces, turn, move);
        turn = 2;
      } else if (turn == 2) {
        tCaptures += isCaptureMove(pieces, turn, move);
        turn = 1;
      }
    }
  }


  public int winCheck() {
    // five captures check
    if (oCaptures >= 5) {
      return 1;
    } else if (tCaptures >= 5) {
      return 2;
    }
    // row check
    for (int r = 0; r < n - 4; ++r) {
      for (int c = 0; c < n; ++c) {
        if (winHelper(pieces[r][c],pieces[r+1][c],pieces[r+2][c],pieces[r+3][c],pieces[r+4][c])) {
          return pieces[r][c];
        }
      }
    }
    // column check
    for (int r = 0; r < n; ++r) {
      for (int c = 0; c < n - 4; ++c) {
        if (winHelper(pieces[r][c],pieces[r][c+1],pieces[r][c+2],pieces[r][c+3],pieces[r][c+4])) {
          return pieces[r][c];
        }
      }
    }
    // down diagonal
    for (int r = 0; r < n - 4; ++r) {
      for (int c = 0; c < n - 4; ++c) {
        if (winHelper(pieces[r][c],pieces[r+1][c+1],pieces[r+2][c+2],pieces[r+3][c+3],pieces[r+4][c+4])) {
          return pieces[r][c];
        }
      }
    }
    // up diagonal
    for (int r = 4; r < n; ++r) {
      for (int c = 0; c < n - 4; ++c) {
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
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < n; ++j) {
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

  private boolean winHelper(int c1, int c2, int c3, int c4, int c5) {
    return c1 != 0 && c1 == c2 && c2 == c3 && c3 == c4 && c4 == c5;
  }
}
public int[] humanMoveCheck() {
  // returns {moveMade, row, column}
  int[] retArr = {0, -1, -1};
  if (155 < mouseX && mouseX <= 646 && 52 <= mouseY && mouseY <= 543) {
    noFill();
    stroke(16, 24, 60);
    ellipse((mouseX/26)*26+9, (mouseY/26)*26+13, 20, 20);
    if (mouseReleased) {
      retArr[0] = 1;
      retArr[1] = ((mouseY - 52) - (mouseY - 52) % 26) / 26; // row
      retArr[2] = ((mouseX - 155) - (mouseX - 155) % 26) / 26; // col
    }
  }
  return retArr;
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
    room = "game";
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
    //game = new Game("single", int(random(1, 3)));
    game = new Game("single", 2);
    room = "game";
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
