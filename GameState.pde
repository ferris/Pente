import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

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

  int[][] getMovePool(int[][] connectionBoard) {
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

  int[][] getConnectionBoard(int[][] prevConnectionBoard, int[] prevCaptures) {
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
