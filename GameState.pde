import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;

import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

class GameState {
  public static final int BOARD_SIZE = 19; // size of board
  private int[][] board = new int[BOARD_SIZE][BOARD_SIZE]; // board
  private int[] captures = new int[2];
  private int turnNum; // current turn
  private int[] prevMove; // previous move
  private int winner = 0; // the winner

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

  public GameState(int startingPlayer) {
    turnNum = startingPlayer;
  }

  public void playMove(int[] move) {
    if (isValidMove(move)) {
      if (move[0]==0 && move[1] == 4 && board[0][3] == 1 && board[0][2] == 1 && board[0][1] == 1 && board[0][0] == 1 && turnNum == 1) {
        print("aloha"); //<>//
      }
      board[move[0]][move[1]] = turnNum;
      captures[turnNum-1] += capturesInMove(turnNum, move);
      turnNum = 3 - turnNum;
      prevMove = move.clone();
      winner = winCheck();
    }
  }

  public boolean isValidMove(int[] move) {
    if (move[0] >= 0 && move[0] < BOARD_SIZE && move[1] >= 0 && move[1] < BOARD_SIZE) {
      return (board[move[0]][move[1]] == 0 && winner == 0);
    }
    return false;
  }

  int winCheck() {
    // five captures check
    for (int i = 0; i < captures.length; ++i) {
      if (captures[i] >= 5) {
        return i+1;
      }
    }
    // column check
    for (int r = 0; r < BOARD_SIZE - 4; ++r) {
      for (int c = 0; c < BOARD_SIZE; ++c) {
        if (winHelper(board[r][c], board[r+1][c], board[r+2][c], board[r+3][c], board[r+4][c])) {
          return board[r][c];
        }
      }
    }
    // row check
    for (int r = 0; r < BOARD_SIZE; ++r) {
      for (int c = 0; c < BOARD_SIZE - 4; ++c) {
        if (winHelper(board[r][c], board[r][c+1], board[r][c+2], board[r][c+3], board[r][c+4])) {
          return board[r][c];
        }
      }
    }
    // down diagonal
    for (int r = 0; r < BOARD_SIZE - 4; ++r) {
      for (int c = 0; c < BOARD_SIZE - 4; ++c) {
        if (winHelper(board[r][c], board[r+1][c+1], board[r+2][c+2], board[r+3][c+3], board[r+4][c+4])) {
          return board[r][c];
        }
      }
    }
    // up diagonal
    for (int r = 4; r < BOARD_SIZE; ++r) {
      for (int c = 0; c < BOARD_SIZE - 4; ++c) {
        if (winHelper(board[r][c], board[r-1][c+1], board[r-2][c+2], board[r-3][c+3], board[r-4][c+4])) {
          return board[r][c];
        }
      }
    }
    return 0;
  }

  private boolean winHelper(int c1, int c2, int c3, int c4, int c5) {
    return c1 != 0 && c1 == c2 && c2 == c3 && c3 == c4 && c4 == c5;
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

  public int[] getSearchField() {
    // {top, bottom, left, right}
    int[] boundaries = new int[] {BOARD_SIZE, 0, BOARD_SIZE, 0};
    for (int i = 0; i < BOARD_SIZE; ++i) {
      for (int j = 0; j < BOARD_SIZE; ++j) {
        if (board[i][j] != 0) {
          // there is a piece at [i][j]
          boundaries[0] = min(boundaries[0], max(0, i-4));
          boundaries[1] = max(boundaries[1], min(BOARD_SIZE-1, i+4));
          boundaries[2] = min(boundaries[2], max(0, j-4));
          boundaries[3] = max(boundaries[3], min(BOARD_SIZE-1, j+4));
        }
      }
    }
    return boundaries;
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
