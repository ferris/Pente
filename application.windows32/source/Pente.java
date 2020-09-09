import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.lang.Runtime; 
import java.util.concurrent.Callable; 
import java.util.concurrent.Executors; 
import java.util.concurrent.ExecutorService; 
import java.util.concurrent.Future; 
import java.util.ArrayList; 
import java.util.List; 
import java.util.Arrays; 

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
  ._______                        __               
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
  Processing Pente Code
  Created by Ferris Linde
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

public void setup() {
  // V-sync
  frameRate(120);
  // Text mode "center"
  textAlign(CENTER);
  
  room = "mainMenu";
}

public void draw() {
  //println("frameRate: " + frameRate);
  if (room.equals("mainMenu")) {
    mainMenu();
  } else if (room.equals("modeMenu")) {
    modeMenu();
  } else if (room.equals("singleMenu")) {
    singleMenu();
  } else if (room.equals("zeroMenu")) {
    zeroMenu();
  } else if (room.equals("game")) {
    game.drawBoard();
    if (!game.gameIsOver()) {
      game.turnGeneration();
    }
    game.drawPieces();
    game.drawTurnIndication();
    game.drawCaptureIndication();
    game.winnerAlert();
  }
  mouseReleased = false;
}

public void mouseClicked() {
  mouseReleased = true;
}


class Game {
  private GameState gameState; // the GameState of the current board
  private boolean winDelay = false; // prevents accidental return to menu
  private boolean moveDelay = false; // allows a frame to be drawn before move chosen
  private char[] playerTypes;
  
  public Game(String mode, int startingPlayer) {
    this.gameState = new GameState(startingPlayer);
    //this.mode = mode;
    switch (mode) {
      case "local":
        playerTypes = new char[]{ 'h', 'h' };
        break;
      case "single":
        playerTypes = new char[]{ 'h', 'c' };
        break;
      case "zero":
        playerTypes = new char[]{ 'c', 'c' };
        gameState.playMove(new int[]{6, 6});
        break;
    }
  }

  public void turnGeneration() {
    if (gameState.getWinner() == 0) {
      boolean newMove = false;
      int[] move = new int[2];
      if (moveDelay) {
        if (playerTypes[gameState.getPlayerOfCurrentTurn() - 1] == 'h') {
          int[] hmc = humanMoveCheck();
          move = new int[] {hmc[1], hmc[2]};
          newMove = hmc[0] == 1;
        } else if (playerTypes[gameState.getPlayerOfCurrentTurn() - 1] == 'c') {
          move = ai.getComputerMove(gameState);
          newMove = true;
        }
      } else {
        moveDelay = true;
      }
      if (newMove) {
        moveDelay = false;
        gameState.playMove(move);
      }
    }
  }
  
  private int[] humanMoveCheck() {
    // returns {moveMade, row, column}
    int[] retArr = {0, -1, -1};
    if (146 < mouseX && mouseX <= 652 && 46 <= mouseY && mouseY <= 552) {
      noFill();
      stroke(2);
      stroke(16, 24, 60);
      ellipse(39*floor((mouseX-165+15)/39)+165, 39*floor((mouseY-65+15)/39)+65, 30, 30);
      //ellipse((mouseX-((mouseX+30)%39)), (mouseY-((mouseY+30)%39)), 30, 30);
      //ellipse((mouseX/39)*39+9, (mouseY/39)*39+13, 20, 20);
      if (mouseReleased) {
        retArr[0] = 1;
        retArr[1] = floor((mouseY-65+15)/39); // row
        retArr[2] = floor((mouseX-165+15)/39); // col
      }
    }
    return retArr;
  }

  public boolean gameIsOver() {
    return gameState.getWinner() != 0;
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
    for (int i = 65; i <= 533; i+=39) {
      if (floor((i - 65) / 39) % 6 == 0) {
        strokeWeight(3);
      } else {
        strokeWeight(1);
      }
      line(165, i, 633, i);
      line(i+100, 65, i+100, 532);
    }
    // guider overlay
    strokeWeight(3);
    strokeWeight(2);
    strokeWeight(3);
    ellipse(282, 182, 2, 2);
    ellipse(516, 182, 2, 2);
    ellipse(282, 416, 2, 2);
    ellipse(516, 416, 2, 2);
  }

  public void drawPieces() {
    int[][] pieces = gameState.getBoard();
    for (int i = 0; i < GameState.BOARD_SIZE; ++i) {
      for (int j = 0; j < GameState.BOARD_SIZE; ++j) {
        if (pieces[i][j] == 1) {
          strokeWeight(3);
          stroke(10, 120, 140);
          fill(90, 200, 220);
          ellipse(j*39+165, i*39+65, 33, 33);
        } else if (pieces[i][j] == 2) {
          strokeWeight(3);
          stroke(175, 60, 0);
          fill(255, 140, 0);
          ellipse(j*39+165, i*39+65, 33, 33);
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
    if (gameState.getPlayerOfCurrentTurn() == 1) {
      stroke(10, 120, 140);
      fill(90, 200, 220);
      rect(714, 100, 66, 60, 7);
      fill(0, 110, 130);
      text("BLUE", 747, 130);
    } else {
      stroke(175, 60, 0);
      fill(255, 140, 0);
      rect(714, 100, 66, 60, 7);
      fill(175, 60, 0);
      text("ORANGE", 747, 130);
    }
  }

  public void drawCaptureIndication() {
    int[] captures = gameState.getCaptureCount();
    noStroke();
    fill(8, 10, 102);
    rect(10, 80, 76, 179);
    textSize(12);
    fill(255);
    text("Captures:", 47, 95);
    stroke(16, 24, 60);
    strokeWeight(1);
    fill(105, 60, 81);
    rect(13, 99, 70, 156, 7);
    fill(214, 151, 97);
    rect(16, 102, 64, 150, 5);
    fill(16, 24, 60);
    text(Integer.toString(captures[1]), 32, 120);
    text(Integer.toString(captures[0]), 64, 120);
    for (int i = 0; i < captures[1]; ++i) {
      stroke(10, 120, 140);
      fill(90, 200, 220);
      ellipse(32, 136+(i*25), 20, 20);
    } 
    for (int i = 0; i < captures[0]; ++i) {
      stroke(175, 60, 0);
      fill(255, 140, 0);
      ellipse(64, 136+(i*25), 20, 20);
    }
    stroke(16, 24, 60);
    line(48, 102, 48, 252);
  }

  public void winnerAlert() {
    int winner = gameState.getWinner();
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
}





public class GameAI {
  private static final float EXPLORATION_PARAMETER = 1;
  private int calculationTime;
  private ExecutorService executorService;
  private int availableProcessors;

  public GameAI(int calculationTime) {
    this.calculationTime = calculationTime;
    availableProcessors = Runtime.getRuntime().availableProcessors();
    executorService = Executors.newFixedThreadPool(availableProcessors);
  }
  
  public int[] getComputerMove(GameState currentGameState) {
    int beginTime = millis();
    // create tree
    MCTNode root = new MCTNode(currentGameState);
    MCTSSolverTask.treeRoot = root;
    MCTSSolverTask.parentAI = this;
    // analyze within time
    while (millis() - beginTime < calculationTime) {
      float turnValue = ParallelMCTSSolver(root);
      // stop (break) to return if proven win or loss
      if (turnValue == Float.POSITIVE_INFINITY || turnValue == Float.NEGATIVE_INFINITY) {
        break;
      }
    }
    // return the move from the best child's GameState
    return secureChild(root, 1).getGameState().getPreviousMove();
  }

  private float ParallelMCTSSolver(MCTNode rootNode) {
    if (rootNode.isLeaf()) {
      expand(rootNode);
    }
    MCTNode[] bestChildren = selectFew(rootNode, EXPLORATION_PARAMETER, availableProcessors);
    ArrayList<MCTSSolverTask> tasks = new ArrayList<MCTSSolverTask>();
    for (MCTNode child : bestChildren) {
      rootNode.addOneToVisits();
      if (child.getTotalValue() == Float.POSITIVE_INFINITY) {
        rootNode.setValue(Float.NEGATIVE_INFINITY);
        return Float.POSITIVE_INFINITY;
      }
      tasks.add(new MCTSSolverTask(child));
    }
    if (tasks.size() == 0) {
      for (MCTNode child : rootNode.getChildren()) {
        if (child.getTotalValue() != Float.NEGATIVE_INFINITY) {
          rootNode.addToValue(-1 * availableProcessors);
          return -1;
        }
      }
    }
    // analyze all results
    List<Future<Float>> results;
    float sumOfResults = 0;
    try {
      results = executorService.invokeAll(tasks);
      for (Future<Float> futureResult : results) {
        Float result = futureResult.get();
        if (result != Float.POSITIVE_INFINITY && result != Float.NEGATIVE_INFINITY) {
          sumOfResults += result;
        }
      }
    } catch (Exception e) {
      println(e);
    }
    rootNode.addToValue(sumOfResults);
    return sumOfResults;
  }

  private float MCTSSolver(MCTNode n) {
    if (n.getGameState().getWinner() == (3 - n.getGameState().getPlayerOfCurrentTurn())) {
      n.setValue(Float.POSITIVE_INFINITY);
      return Float.NEGATIVE_INFINITY;
    }
    MCTNode bestChild;
    float result;
    if (n.isLeaf()) {
      bestChild = expand(n);
    } else {
      bestChild = select(n, EXPLORATION_PARAMETER);
    }
    n.addOneToVisits();
    float bestChildVal = bestChild.getTotalValue();
    if (bestChildVal != Float.POSITIVE_INFINITY && bestChildVal != Float.NEGATIVE_INFINITY) {
      if (bestChild.getTotalVisits() == 0) {
        result = -1 * playOut(bestChild);
        n.addToValue(result);
        return result;
      } else {
        result = -1 * MCTSSolver(bestChild);
      }
    } else {
      result = bestChildVal;
    }
    if (result == Float.POSITIVE_INFINITY) {
      n.setValue(Float.NEGATIVE_INFINITY);
      return result;
    } else if (result == Float.NEGATIVE_INFINITY) {
      for (MCTNode child : n.getChildren()) {
        if (child.getTotalValue() != result) {
          result = -1;
          n.addToValue(result);
          return result;
        }
      }
      n.setValue(Float.POSITIVE_INFINITY);
      return result;
    }
    n.addToValue(result);
    return result;
  }
  
  private MCTNode select(MCTNode node, float exploreParam) {
    MCTNode selected = node;
    MCTNode[] children = node.getChildren();
    float bestValue = -1 * Float.MAX_VALUE;
    for (MCTNode child : children) {
      float uctValue = child.getUCBValue(exploreParam);
      if (uctValue > bestValue) {
        bestValue = uctValue;
        selected = child;
      }
    }
    return selected;
  }

  private MCTNode[] selectFew(MCTNode node, float exploreParam, int numToSelect) {
    // initialize variables and starting options
    MCTNode[] children = node.getChildren();
    if (children.length == 0) { // special case for no children to prevent NullPointerException
      return new MCTNode[]{node};
    }
    MCTNode[] bestFew = Arrays.copyOfRange(children, 0, min(numToSelect, children.length));
    float[] bestFewValues = new float[bestFew.length];
    for (int i = 0; i < bestFew.length; ++i) {
      bestFewValues[i] = bestFew[i].getUCBValue(exploreParam);
    }
    // look for better options
    for (int i = bestFew.length; i < children.length; ++i) {
      float uctValue = children[i].getUCBValue(exploreParam);
      for (int j = 0; j < bestFew.length; ++j) {
        if (uctValue > bestFewValues[j]) {
          bestFewValues[j] = uctValue;
          bestFew[j] = children[i];
          break;
        }
      }
    }
    return bestFew;
  }

  private MCTNode expand(MCTNode node) {
    node.generateChildren();
    for (MCTNode child : node.getChildren()) {
      if (child.getGameState().someWinConfirmed()) {
        child.setValue(Float.POSITIVE_INFINITY);
        return child;
      }
    }
    return select(node, EXPLORATION_PARAMETER);
  }

  private float playOut(MCTNode node) {
    node.addOneToVisits();
    GameState state = node.getGameState().getDuplicate();
    int[][] conBoard = state.getConnectionBoard();
    while (state.getWinner() == 0 || state.isTie()) {
      int[][] movePool = state.getMovePool(conBoard);
      if (movePool.length == 0) {
        break;
      }
      // get two possible moves, choose the one with the greater connection value
      int[] moveOption1 = movePool[PApplet.parseInt(random(movePool.length))];
      int[] moveOption2 = movePool[PApplet.parseInt(random(movePool.length))];
      int[] move = new int[2];
      if (moveOption1[2] >= moveOption2[2]) {
        move[0] = moveOption1[0];
        move[1] = moveOption1[1];
      } else {
        move[0] = moveOption2[0];
        move[1] = moveOption2[1];
      }
      int[] cc = state.getCaptureCount();
      state.playMove(move);
      conBoard = state.getConnectionBoard(conBoard, cc);
    }
    float result = (state.getWinner() == node.getGameState().getPlayerOfCurrentTurn()) ? -1 : 1;
    node.addToValue(result);
    return result;
  }
  
  private MCTNode secureChild(MCTNode rootNode, float exploreParam) {
    MCTNode[] children = rootNode.getChildren();
    MCTNode selected = children[0];
    float bestValue = -1 * Float.MAX_VALUE;
    for (MCTNode child : children) {
      float scValue = child.getLCBValue(exploreParam);
      if (scValue > bestValue) {
        bestValue = scValue;
        selected = child;
      }
    }
    return selected;
  }
}




class GameState {
  public static final int BOARD_SIZE = 13; // size of board
  private int[][] board = new int[BOARD_SIZE][BOARD_SIZE]; // board
  private int[] captures = new int[2];
  private int turnNum; // current turn
  private int[] prevMove; // previous move
  private int winner = 0; // the winner

  public GameState(int startingPlayer) {
    turnNum = startingPlayer;
  }

  public GameState(int[][] board, int[] captures, int turnNum, int[] prevMove, int winner) {
    for (int i = 0; i < BOARD_SIZE; ++i) {
      for (int j = 0; j < BOARD_SIZE; ++j) {
        this.board[i][j] = board[i][j];
      }
    }
    this.captures = captures.clone();
    this.turnNum = turnNum;
    this.prevMove = prevMove;
    this.winner = winner;
  }

  public boolean isValidMove(int[] move) {
    if (move[0] >= 0 && move[0] < BOARD_SIZE && move[1] >= 0 && move[1] < BOARD_SIZE) {
      return (board[move[0]][move[1]] == 0 && winner == 0);
    }
    return false;
  }

  public void playMove(int[] move) {
    if (isValidMove(move)) {
      board[move[0]][move[1]] = turnNum;
      captures[turnNum-1] += capturesInMove(turnNum, move);
      turnNum = 3 - turnNum;
      prevMove = move.clone();
      winner = winCheck();
    }
  }

  public int winCheck() {
    // five captures check
    for (int i = 0; i < captures.length; ++i) {
      if (captures[i] >= 5) {
        return i+1;
      }
    }
    int r_LowerBound = max(prevMove[0]-4, 0);
    int r_UpperBound = min(prevMove[0]+5, BOARD_SIZE);
    int c_LowerBound = max(prevMove[1]-4, 0);
    int c_UpperBound = min(prevMove[1]+5, BOARD_SIZE);
    // column check
    for (int r = r_LowerBound; r < r_UpperBound - 4; ++r) {
      for (int c = c_LowerBound; c < c_UpperBound; ++c) {
        if (winHelper(board[r][c],board[r+1][c],board[r+2][c],board[r+3][c],board[r+4][c])) {
          return board[r][c];
        }
      }
    }
    // row check
    for (int r = r_LowerBound; r < r_UpperBound; ++r) {
      for (int c = c_LowerBound; c < c_UpperBound - 4; ++c) {
        if (winHelper(board[r][c],board[r][c+1],board[r][c+2],board[r][c+3],board[r][c+4])) {
          return board[r][c];
        }
      }
    }
    // down diagonal
    for (int r = r_LowerBound; r < r_UpperBound - 4; ++r) {
      for (int c = c_LowerBound; c < c_UpperBound - 4; ++c) {
        if (winHelper(board[r][c],board[r+1][c+1],board[r+2][c+2],board[r+3][c+3],board[r+4][c+4])) {
          return board[r][c];
        }
      }
    }
    // up diagonal
    for (int r = r_LowerBound+4; r < r_UpperBound; ++r) {
      for (int c = c_LowerBound; c < c_UpperBound - 4; ++c) {
        if (winHelper(board[r][c],board[r-1][c+1],board[r-2][c+2],board[r-3][c+3],board[r-4][c+4])) {
          return board[r][c];
        }
      }
    }
    return 0;
  }

  private boolean winHelper(int c1, int c2, int c3, int c4, int c5) {
    return c1 != 0 && c1 == c2 && c2 == c3 && c3 == c4 && c4 == c5;
  }

  public int tessCheck() {
    // column check
    for (int r = 0; r < BOARD_SIZE - 5; ++r) {
      for (int c = 0; c < BOARD_SIZE; ++c) {
        if (tessHelper(board[r][c],board[r+1][c],board[r+2][c],board[r+3][c],board[r+4][c],board[r+5][c])) {
          return board[r+1][c];
        }
      }
    }
    // row check
    for (int r = 0; r < BOARD_SIZE; ++r) {
      for (int c = 0; c < BOARD_SIZE - 5; ++c) {
        if (tessHelper(board[r][c],board[r][c+1],board[r][c+2],board[r][c+3],board[r][c+4],board[r][c+5])) {
          return board[r][c+1];
        }
      }
    }
    // down diagonal
    for (int r = 0; r < BOARD_SIZE - 5; ++r) {
      for (int c = 0; c < BOARD_SIZE - 5; ++c) {
        if (tessHelper(board[r][c],board[r+1][c+1],board[r+2][c+2],board[r+3][c+3],board[r+4][c+4],board[r+5][c+5])) {
          return board[r+1][c+1];
        }
      }
    }
    // up diagonal
    for (int r = 5; r < BOARD_SIZE; ++r) {
      for (int c = 0; c < BOARD_SIZE - 5; ++c) {
        if (tessHelper(board[r][c],board[r-1][c+1],board[r-2][c+2],board[r-3][c+3],board[r-4][c+4],board[r-5][c+5])) {
          return board[r-1][c+1];
        }
      }
    }
    return 0;
  }

  private boolean tessHelper(int c1, int c2, int c3, int c4, int c5, int c6) {
    return c1 == 0 && c2 != 0 && c2 == c3 && c3 == c4 && c4 == c5 && c6 == 0;
  }

  public boolean isTie() {
    for (int i = 0; i < BOARD_SIZE; ++i) {
      for (int j = 0; j < BOARD_SIZE; ++j) {
        if (board[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  public int capturesInMove(int movePlayer, int[] move) {
    // checks if capture move and returns number of captures for tallying
    int capCount = 0;
    int unPlayer = 3 - movePlayer;
    int[] sequence = new int[]{movePlayer, unPlayer, unPlayer, movePlayer};
    // check horizontal captures (-)
    if (move[1] > 2) {
      for (int i = 0; i < sequence.length && board[move[0]][move[1]-i] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]][move[1]-1] = 0;
          board[move[0]][move[1]-2] = 0;
        }
      }
    }
    if (move[1] < BOARD_SIZE - 3) {
      for (int i = 0; i < sequence.length && board[move[0]][move[1]+i] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]][move[1]+1] = 0;
          board[move[0]][move[1]+2] = 0;
        }
      }
    }
    // check vertical captures (|)
    if (move[0] > 2) {
      for (int i = 0; i < sequence.length && board[move[0]-i][move[1]] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]-1][move[1]] = 0;
          board[move[0]-2][move[1]] = 0;
        }
      }
    }
    if (move[0] < BOARD_SIZE - 3) {
      for (int i = 0; i < sequence.length && board[move[0]+i][move[1]] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]+1][move[1]] = 0;
          board[move[0]+2][move[1]] = 0;
        }
      }
    }
    // check diagonal captures (\)
    if (move[0] > 2 && move[1] > 2) {
      for (int i = 0; i < sequence.length && board[move[0]-i][move[1]-i] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]-1][move[1]-1] = 0;
          board[move[0]-2][move[1]-2] = 0;
        }
      }
    }
    if (move[0] < BOARD_SIZE - 3 && move[1] < BOARD_SIZE - 3) {
      for (int i = 0; i < sequence.length && board[move[0]+i][move[1]+i] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]+1][move[1]+1] = 0;
          board[move[0]+2][move[1]+2] = 0;
        }
      }
    }
    // check other diagonal captures (/)
    if (move[0] > 2 && move[1] < BOARD_SIZE - 3) {
      for (int i = 0; i < sequence.length && board[move[0]-i][move[1]+i] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]-1][move[1]+1] = 0;
          board[move[0]-2][move[1]+2] = 0;
        }
      }
    }
    if (move[0] < BOARD_SIZE - 3 && move[1] > 2) {
      for (int i = 0; i < sequence.length && board[move[0]+i][move[1]-i] == sequence[i]; ++i) {
        if (i == sequence.length - 1) {
          capCount++;
          board[move[0]+1][move[1]-1] = 0;
          board[move[0]+2][move[1]-2] = 0;
        }
      }
    }
    return capCount;
  }

  public GameState getDuplicate() {
    return new GameState(board, captures, turnNum, prevMove, winner);
  }

  public int[][] getPossibleMoves() {
    // find all possible moves and store in a list
    int[] bounds = this.getSearchField();
    List<int[]> possibleMoves = new ArrayList<int[]>();
    for (int i = bounds[0]; i <= bounds[1]; ++i) {
      for (int j = bounds[2]; j <= bounds[3]; ++j) {
        int[] moveLocation = {i, j};
        if (isValidMove(moveLocation)) {
          possibleMoves.add(moveLocation);
        }
      }
    }
    // convert to array and return that array
    int[][] retArr = new int[possibleMoves.size()][2];
    possibleMoves.toArray(retArr);
    return retArr;
  }

  public int[][] getMovePool() {
    return getMovePool(getConnectionBoard());
  }

  public int[][] getMovePool(int[][] connectionBoard) {
    int[] bounds = getSearchField();
    List<int[]> possibleMoves = new ArrayList<int[]>();
    for (int i = bounds[0]; i < bounds[1]; ++i) {
      for (int j = bounds[2]; j < bounds[3]; ++j) {
        if (connectionBoard[i][j] >= 1) {
          possibleMoves.add(new int[]{i, j, connectionBoard[i][j]});
        }
      }
    }
    int[][] movePool = new int[possibleMoves.size()][3];
    possibleMoves.toArray(movePool);
    return movePool;
  }

  public int[][] getSortedMovePool() {
    return getSortedMovePool(getConnectionBoard());
  }
  
  public int[][] getSortedMovePool(int[][] connectionBoard) {
    int[][] movePool = getMovePool(connectionBoard);
    quickSortMoves(movePool, 0, movePool.length - 1);
    return movePool;
  }

  private void quickSortMoves(int[][] moveArr, int left, int right) {
    // randomized quicksort that sorts moves by their connection values
    if (left >= right) {
      return;
    }
    int k = PApplet.parseInt(random(left, right));
    int[] temp = moveArr[k];
    moveArr[k] = moveArr[left];
    moveArr[left] = temp;
    int[] lessThanGreaterThan = threeWayPartitionMoves(moveArr, left, right);
    quickSortMoves(moveArr, left, lessThanGreaterThan[0]-1);
    quickSortMoves(moveArr, lessThanGreaterThan[1]+1, right);
  }

  private int[] threeWayPartitionMoves(int[][] moveArr, int left, int right) {
    // 3-way partition for quicksort to handle few equal elements in array
    int greaterThan = left; // the part that is less than the pivot
    int i = left; // array is scanned from left to right
    int lessThan = right; // the part that is greater than the pivot
    int pivot = moveArr[left][2]; // 1st element in array, randomized in parent method
    while (i <= lessThan) {
      if (moveArr[i][2] > pivot) {
        int[] temp = moveArr[greaterThan];
        moveArr[greaterThan] = moveArr[i];
        moveArr[i] = temp;
        greaterThan++;
        i++;
      } else if (moveArr[i][2] < pivot) {
        int[] temp = moveArr[i];
        moveArr[i] = moveArr[lessThan];
        moveArr[lessThan] = temp;
        lessThan--;
      } else {
        i++;
      }
    }
    return new int[]{ greaterThan, lessThan};
  }

  public int[][] getConnectionBoard() {
    int[] boundaries = getSearchField();
    int[][] connectionBoard = new int[BOARD_SIZE][BOARD_SIZE]; // new value array of same size as board
    // cycle through search field
    for (int i = boundaries[0]; i < boundaries[1]; ++i) {
      for (int j = boundaries[2]; j < boundaries[3]; ++j) {
        if (board[i][j] != 0) {
          // a negative one represents a piece
          connectionBoard[i][j] = -1;
          // vertical (|)
          int v_LowerBound = max(boundaries[0], i-4);
          int v_UpperBound = min(boundaries[1], i+5);
          for (int v = v_LowerBound; v < v_UpperBound; ++v) {
            if (connectionBoard[v][j] != -1) {
              connectionBoard[v][j]++;
            }
          }
          // horizontal (-)
          int h_LowerBound = max(boundaries[2], j-4);
          int h_UpperBound = min(boundaries[3], j+5);
          for (int h = h_LowerBound; h < h_UpperBound; ++h) {
            if (connectionBoard[i][h] != -1) {
              connectionBoard[i][h]++;
            }
          }
            // diagonal back (\)
          int db_LowerBound = max(v_LowerBound-i, h_LowerBound-j);
          int db_UpperBound = min(v_UpperBound-i, h_UpperBound-j);
          for (int df = db_LowerBound; df < db_UpperBound; ++df) {
            if (connectionBoard[i+df][j+df] != -1) {
              connectionBoard[i+df][j+df] ++;
            }
          }
          // diagonal fowards (/)
          int df_LowerBound = max(v_LowerBound-i, j-(h_UpperBound-1));
          int df_UpperBound = min(v_UpperBound-i, j-(h_LowerBound-1));
          for (int df = df_LowerBound; df < df_UpperBound; ++df) {
            if (connectionBoard[i+df][j-df] != -1) {
              connectionBoard[i+df][j-df]++;
            }
          }
        }
      }
    }
    return connectionBoard;
  }

  public int[][] getConnectionBoard(int[][] prevConnectionBoard, int[] prevCaptures) {
    // for simulations: get current state's connection board from previous by looking at prevMove
    // if this is the first move or the previous move was a capture move, we have to recalculate
    if (prevMove == null || prevCaptures[0] != captures[0] || prevCaptures[1] != captures[1]) {
      return getConnectionBoard();
    }
    // if it wasn't a capture move, we can just look at that move
    int[][] connectionBoard = prevConnectionBoard; // no need for deep copy (only called during sims)
    int[] boundaries = getSearchField();
    int i = prevMove[0];
    int j = prevMove[1];
    // update the move's connection board state, and those around that move
    connectionBoard[i][j] = -1;
    // vertical (|)
    int v_LowerBound = max(boundaries[0], i-4);
    int v_UpperBound = min(boundaries[1], i+5);
    for (int v = v_LowerBound; v < v_UpperBound; ++v) {
      if (connectionBoard[v][j] != -1) {
        connectionBoard[v][j]++;
      }
    }
    // horizontal (-)
    int h_LowerBound = max(boundaries[2], j-4);
    int h_UpperBound = min(boundaries[3], j+5);
    for (int h = h_LowerBound; h < h_UpperBound; ++h) {
      if (connectionBoard[i][h] != -1) {
        connectionBoard[i][h]++;
      }
    }
      // diagonal back (\)
    int db_LowerBound = max(v_LowerBound-i, h_LowerBound-j);
    int db_UpperBound = min(v_UpperBound-i, h_UpperBound-j);
    for (int df = db_LowerBound; df < db_UpperBound; ++df) {
      if (connectionBoard[i+df][j+df] != -1) {
        connectionBoard[i+df][j+df] ++;
      }
    }
    // diagonal fowards (/)
    int df_LowerBound = max(v_LowerBound-i, j-(h_UpperBound-1));
    int df_UpperBound = min(v_UpperBound-i, j-(h_LowerBound-1));
    for (int df = df_LowerBound; df < df_UpperBound; ++df) {
      if (connectionBoard[i+df][j-df] != -1) {
        connectionBoard[i+df][j-df]++;
      }
    }
    return connectionBoard;
  }

  private int[] getSearchField() {
    // check special scenario -> is the board empty or not?
    int firstLocationRow = -1;
    emptyCheck:
    for (int i = 0; i < BOARD_SIZE; ++i) {
      for (int j = 0; j < BOARD_SIZE; ++j) {
        if (board[i][j] != 0) {
          firstLocationRow = i;
          break emptyCheck;
        }
      }
    }
    if (firstLocationRow == -1) { // search field is middle of board
      return new int[] {4, BOARD_SIZE - 4, 4, BOARD_SIZE - 4};
    }
    // calculate board boundaries
    int[] boundaries = new int[] {max(0, firstLocationRow - 4), 0, BOARD_SIZE, 0};
    for (int i = firstLocationRow; i < BOARD_SIZE; ++i) {
      for (int j = 0; j < BOARD_SIZE; ++j) {
        if (board[i][j] != 0) {
          // there is a piece at [i][j]
          boundaries[1] = max(boundaries[1], min(BOARD_SIZE, i+4));
          boundaries[2] = min(boundaries[2], max(0, j-4));
          boundaries[3] = max(boundaries[3], min(BOARD_SIZE, j+4));
        }
      }
    }
    return boundaries;
  }

  public boolean someWinConfirmed() {
    return someWinConfirmed(3 - turnNum);
  }

  public boolean someWinConfirmed(int possibleWinner) {
    return winner == possibleWinner || tessWinConfirmed(possibleWinner);
  }

  public boolean tessWinConfirmed() {
    return tessWinConfirmed(3 - turnNum);
  }

  public boolean tessWinConfirmed(int possibleWinner) {
    // ensure that the child check is actually required
    if (tessCheck() != possibleWinner) {
      return false;
    }
    // see if there is a "checkmate" through a tess play
    // everything is done in temporary variables to reduce memory consumption
    MCTNode tempState = new MCTNode(this);
    tempState.generateChildren();
    int tempPlayerCaptures = tempState.getGameState().getCaptureCount()[2 - possibleWinner];
    for (MCTNode tempChild : tempState.getChildren()) {
      int tempChildPlayerCaptures = tempChild.getGameState().getCaptureCount()[2 - possibleWinner];
      if (tempChildPlayerCaptures > tempPlayerCaptures && tempChild.getGameState().tessCheck() != possibleWinner) {
        return false;
      } else if (tempChild.getGameState().getWinner() == 3 - possibleWinner) {
        return false;
      }
    }
    return true;
  }

  public int getPlayerOfCurrentTurn() {
    return turnNum;
  }

  public int[] getCaptureCount() {
    return captures;
  }

  public int getWinner() {
    return winner;
  }

  public int[] getPreviousMove() {
    return prevMove;
  }

  public int[][] getBoard() {
    return board;
  }
}

public class MCTNode {
  private static final float epsilon = 1e-6f; // used to prevent division by zero
  private MCTNode parent;
  private MCTNode[] children;
  private float numVisits;
  private float totalValue;
  private GameState state; // State of this node

  public MCTNode(GameState state) {
    this.parent = null;
    this.state = state.getDuplicate();;
  }

  public MCTNode(MCTNode parent) {
    this.parent = parent;
    this.state = parent.getGameState().getDuplicate();
  }

  public void generateChildren() {
    int[][] possibleMoves = state.getSortedMovePool();
    children = new MCTNode[possibleMoves.length];
    for (int i = 0; i < children.length; ++i) {
      children[i] = new MCTNode(this);
      children[i].getGameState().playMove(possibleMoves[i]);
    }
  }

  public float getUCBValue(float cParam) {
    // balance exploration and exploitation by calculating Upper Confidence Bound    
    float uctValue = totalValue / (numVisits + epsilon);
    uctValue += cParam * sqrt(2 * log(parent.getTotalVisits() + 1) / (numVisits + epsilon));
    return uctValue;
  }

  public float getLCBValue(float cParam) {
    // balance exploration and exploitation by calculating Lower Confidence Bound
    float scValue = totalValue / (numVisits + epsilon);
    scValue -= cParam * sqrt(2 * log(parent.getTotalVisits()) / (numVisits + epsilon));
    return scValue;
  }

  public GameState getGameState() {
    return state;
  }

  public MCTNode getParent() {
    return parent;
  }

  public MCTNode[] getChildren() {
    return children;
  }

  public void addOneToVisits() {
    numVisits++;
  }

  public void addToValue(float num) {
    totalValue += num;
  }

  public void setValue(float num) {
    totalValue = num;
  }

  public float getTotalVisits() {
    return numVisits;
  }

  public float getTotalValue() {
    return totalValue;
  }

  private boolean isLeaf() {
    return children == null;
  }
}

public static class MCTSSolverTask implements Callable<Float> {
  public static GameAI parentAI;
  public static MCTNode treeRoot;
  private MCTNode childToAnalyze;

  public MCTSSolverTask(MCTNode childToAnalyze) {
    this.childToAnalyze = childToAnalyze;
  }

  public Float call() {
    return parentAI.MCTSSolver(childToAnalyze);
  }
}

public void mainMenu() {
  noStroke();
  background(26, 188, 156);
  fill(44, 62, 80);
  rect(150, 300, 500, 100, 50);
  textAlign(CENTER);
  textSize(11);
  text(version, 730, 10);
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
  text("Zero Players", 400, 515);

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
  // zero players button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    room = "zeroMenu";
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
    game = new Game("single", 1);
    ai = new GameAI(4000);
    room = "game";
  }
  // medium button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    game = new Game("single", 1);
    ai = new GameAI(8000);
    room = "game";
  }
  // hard button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    game = new Game("single", 1);
    ai = new GameAI(16000);
    room = "game";
  }
  // back button
  if (mouseReleased && mouseX > 75 && mouseX < 125 && mouseY < 550 && mouseY > 50) {
    room = "modeMenu";
  }
}

public void zeroMenu() {
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
  text("Dumb", 400, 115);
  text("Competent", 400, 315);
  text("Smart", 400, 515);
  // BUTTONS
  // dumb button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 150 && mouseY > 50) {
    game = new Game("zero", 1);
    ai = new GameAI(1000);
    room = "game";
  }
  // competent button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 350 && mouseY > 250) {
    game = new Game("zero", 1);
    ai = new GameAI(4000);
    room = "game";
  }
  // smart button
  if (mouseReleased && mouseX > 200 && mouseX < 600 && mouseY < 550 && mouseY > 450) {
    game = new Game("zero", 1);
    ai = new GameAI(16000);
    room = "game";
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
