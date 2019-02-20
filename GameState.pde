import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

class GameState {
  public static final int BOARD_SIZE = 9; // size of board
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


  int[][] getMovePool() {
    int[] bounds = getSearchField();
    int[][] connectionBoard = getConnectionBoard();
    List<int[]> possibleMoves = new ArrayList<int[]>();
    for (int i = bounds[0]; i <= bounds[1]; ++i) {
      for (int j = bounds[2]; j <= bounds[3]; ++j) {
        if (connectionBoard[i][j] >= 0) {
          possibleMoves.add(new int[]{i, j, connectionBoard[i][j]});
        }
      }
    }
    int[][] movePool = new int[possibleMoves.size()][3];
    possibleMoves.toArray(movePool);
    return movePool;
  }
  
  int[][] getSortedMovePool() {
    int[][] movePool = getMovePool();
    quickSortMoves(movePool, 0, movePool.length - 1);
    return movePool;
  }

  private void quickSortMoves(int[][] moveArr, int left, int right) {
    // randomized quicksort that sorts moves by their connection values
    if (left >= right) {
      return;
    }
    int k = int(random(left, right));
    int[] temp = moveArr[k];
    moveArr[k] = moveArr[left];
    moveArr[left] = temp;
    int[] lessThanGreaterThan = threeWayPartitionMoves(moveArr, left, right);
    quickSortMoves(moveArr, left, lessThanGreaterThan[0]-1);
    quickSortMoves(moveArr, lessThanGreaterThan[1]+1, right);
  }

  private int[] threeWayPartitionMoves(int[][] moveArr, int left, int right) {
    // 3-way partition for quicksort to handle few equal elements in array
    int lessThan = left; // the part that is less than the pivot
    int i = left; // array is scanned from left to right
    int greaterThan = right; // the part that is greater than the pivot
    int pivot = moveArr[left][2]; // 1st element in array, randomized in parent method
    while (i <= greaterThan) {
      if (moveArr[i][2] < pivot) {
        int[] temp = moveArr[lessThan];
        moveArr[lessThan] = moveArr[i];
        moveArr[i] = temp;
        lessThan++;
        i++;
      } else if (moveArr[i][2] > pivot) {
        int[] temp = moveArr[i];
        moveArr[i] = moveArr[greaterThan];
        moveArr[greaterThan] = temp;
        greaterThan--;
      } else {
        i++;
      }
    }
    return new int[]{ lessThan, greaterThan };
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

  int[][] getConnectionBoard() {
    int[] boundaries = getSearchField();
    int[][] connectionBoard = new int[BOARD_SIZE][BOARD_SIZE]; // new value array of same size as board
    // cycle through search field
    for (int i = boundaries[0]; i <= boundaries[1]; ++i) {
      for (int j = boundaries[2]; j <= boundaries[3]; ++j) {
        // if there is a piece then do not check
        if (board[i][j] != 0) {
          // a negative one represents a piece
          connectionBoard[i][j] = -1;
        } else {
          int k_LowerBound = max(boundaries[0], i-4);
          int k_UpperBound = 1 + min(boundaries[1], i+4);
          int l_LowerBound = max(boundaries[2], j-4);
          int l_UpperBound = 1 + min(boundaries[3], j+4);
          for (int k = k_LowerBound; k < k_UpperBound; ++k) {
            // vertical (|)
            if (board[k][j] != 0) {
              connectionBoard[i][j] += 1;
            }
            for (int l = l_LowerBound; l < l_UpperBound; ++l) {
              // horizontal (-)
              if (k == k_LowerBound && board[i][l] != 0) {
                connectionBoard[i][j] += 1;
              }
              // diagonal back (\)
              if (k-i == l-j && board[k][l] != 0) {
                connectionBoard[i][j] += 1;
              }
              // diagonal fowards (/)
              if (i-k == l-j && board[k][l] != 0) {
                connectionBoard[i][j] += 1;
              }
            }
          }
        }
      }
    }
    return connectionBoard;
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
