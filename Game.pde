class Game {
  public static final byte n = 19; // size of board
  private byte pieces[][] = new byte[n][n]; // board
  private byte oCaptures = 0; // captures by player 1
  private byte tCaptures = 0; // captures by player 2
  private byte turn; // current turn
  private byte winner = 0; // the winner
  private String mode; // game mode chosen through menu
  private boolean winDelay = false; // prevents accidental return to menu

  public Game(String mode, byte startingPlayer) {
    this.mode = mode;
    this.turn = startingPlayer;
  }


  // BACK END METHODS
  public byte isCaptureMove(byte[][] board, byte movePlayer, byte[] move) {
    // checks if capture move and returns number of captures for tallying
    byte cCount = 0;

    byte unPlayer;
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


  public boolean isValidMove(byte[][] board, byte[] move) {
    if (move[0] >= 0 && move[0] < n && move[1] >= 0 && move[1] < n) {
      return (board[move[0]][move[1]] == 0);
    }
    return false;
  }


  public void turnGeneration() {
    boolean newMove = false;
    byte[] move = new byte[2];
    if (mode.equals("local")) {
      byte[] hmc = humanMoveCheck();
      move = new byte[] {hmc[1], hmc[2]};
      newMove = hmc[0] == 1;
    } else if (mode.equals("single")) {
      if (turn == 1) {
        byte[] hmc = humanMoveCheck();
        move = new byte[] {hmc[1], hmc[2]};
        newMove = hmc[0] == 1;
      } else {
        println();
        println("computer is thinking");
        memoryBefore = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
        move = ai.getComputerMove(pieces, oCaptures, tCaptures, turn);
        print("[");print(move[0]);print("] [");print(move[1]);println("]");
        memoryAfter = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
        println("memory_before: " + str(memoryBefore/1048576) + "MiB");
        println("memory_after: " + str(memoryAfter/1048576) + "MiB");
        println("memory_change: " + str((memoryAfter-memoryBefore)/1048576) + "MiB");
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


  byte winCheck() {
    // five captures check
    if (oCaptures >= 5) {
      return 1;
    } else if (tCaptures >= 5) {
      return 2;
    }
    // column check
    for (int r = 0; r < n - 4; ++r) {
      for (int c = 0; c < n; ++c) {
        if (winHelper(pieces[r][c],pieces[r+1][c],pieces[r+2][c],pieces[r+3][c],pieces[r+4][c])) {
          return pieces[r][c];
        }
      }
    }
    // row check
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

  void drawTurnIndication() {
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

  void drawCaptureIndication() {
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
    text(Byte.toString(tCaptures), 32, 120);
    text(Byte.toString(oCaptures), 64, 120);
    for (byte i = 0; i < tCaptures; ++i) {
      stroke(10, 120, 140);
      fill(90, 200, 220);
      ellipse(32, 136+(i*25), 20, 20);
    } 
    for (byte i = 0; i < oCaptures; ++i) {
      stroke(175, 60, 0);
      fill(255, 140, 0);
      ellipse(64, 136+(i*25), 20, 20);
    }
    stroke(16, 24, 60);
    line(48, 102, 48, 252);
  }

  void winnerAlert() {
    if (winner == 0) {
      winner = winCheck();
    }
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

  
  // PRIVATE HELPERS

  private boolean winHelper(byte c1, byte c2, byte c3, byte c4, byte c5) {
    return c1 != 0 && c1 == c2 && c2 == c3 && c3 == c4 && c4 == c5;
  }
}
