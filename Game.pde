class Game {
  int n = 19; // size of board
  int pieces[][] = new int[n][n]; // board
  int oCaptures = 0; // captures by player 1
  int tCaptures = 0; // captures by player 2
  int turn; // current turn
  int winner = 0; // the winner
  String mode; // game mode chosen through menu
  boolean winDelay = false; // prevents accidental return to menu

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
    if (mode.equals("local")) {
      int[] hmc = humanMoveCheck();
      int[] move = {hmc[1], hmc[2]};
      if (hmc[0] == 1 && isValidMove(pieces, move)) {
        // a valid move has been played by the human
        int captures = isCaptureMove(pieces, turn, move);
        pieces[hmc[1]][hmc[2]] = turn;
        if (captures != 0) {
          if (turn == 1) {
            oCaptures++;
          } else {
            tCaptures++;
          }
        }
        if (turn == 1) {
          turn = 2;
        } else if (turn == 2) {
          turn = 1;
        }
      }
    }
  }


  int winCheck() {
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

  private boolean winHelper(int c1, int c2, int c3, int c4, int c5) {
    return c1 != 0 && c1 == c2 && c2 == c3 && c3 == c4 && c4 == c5;
  }
}