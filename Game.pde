import java.lang.Runtime;

class Game {
  private GameState gameState;
  //private String mode; // game mode chosen through menu
  private boolean winDelay = false; // prevents accidental return to menu
  private boolean moveDelay = false; // allows a frame to be drawn before move chosen
  private char[] playerTypes;
  
  // debug purposes
  MCTNode sc;
  // debug end
  public Game(String mode, int startingPlayer) {
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
        break;
    }
    this.gameState = new GameState(startingPlayer);
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
          println();
          println("computer is thinking");
          long memoryBefore = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
          sc = ai.getComputerMove(gameState);
          move = sc.getGameState().getPreviousMove();
          //move = ai.getComputerMove(gameState);
          long memoryAfter = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
          //println("memory_before: " + str(memoryBefore/1048576) + "MiB");
          //println("memory_after: " + str(memoryAfter/1048576) + "MiB");
          //println("memory_change: " + str((memoryAfter-memoryBefore)/1048576) + "MiB");
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

  private void switchAround() {
    
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
    int[][] pieces = gameState.getBoard();
    for (int i = 0; i < GameState.BOARD_SIZE; ++i) {
      for (int j = 0; j < GameState.BOARD_SIZE; ++j) {
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

  void drawTurnIndication() {
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

  void drawCaptureIndication() {
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

  void winnerAlert() {
    int winner = gameState.getWinner();
    if (winner != 0) {
      color darkC;
      color lightC;
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
