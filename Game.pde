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

  int winCheck() {
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