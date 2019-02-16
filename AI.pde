import java.util.*;

class ABNode {
  private short value;
  private byte[][] board;
  private byte[] move;
  private byte oCaptures;
  private byte tCaptures;
  private ABNode parent;
  private List<ABNode> children = new ArrayList<ABNode>();

  ABNode(byte[][] board, byte oCaptures, byte tCaptures, byte[] move, byte player) {
    // deep copy to prevent collisions
    this.board = new byte[Game.n][Game.n];
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        this.board[i][j] = board[i][j];
      }
    }
    this.oCaptures = oCaptures;
    this.tCaptures = tCaptures;
    this.move = move.clone();
    if (player == 1) {
      this.oCaptures += game.isCaptureMove(this.board, player, this.move);
    } else if (player == 2) {
      this.tCaptures += game.isCaptureMove(this.board, player, this.move);
    }
    this.board[move[0]][move[1]] = player;
  }
}


class GameAI {
  private final byte SIZE = 19;
  private byte[] prevMove;
  private byte oCaptures = 0;
  private byte tCaptures = 0;
  private byte depth;

  GameAI(byte depth) {
    this.depth = depth;
  }


  public byte[] getComputerMove(byte[][] board, byte oCaptures, byte tCaptures, byte player) {
    // find opposite player
    byte unPlayer;
    if (player == 1) {
      unPlayer = 2;
    } else {
      unPlayer = 1;
    }
    int beginTime = millis();
    short bestValue = 0;
    short currentMax = Short.MIN_VALUE;
    short currentMin = Short.MAX_VALUE;
    short[][] movePool = sortedMovePool(board, player == 2);
    for (short i = 0; i < movePool.length; ++i) {
      print("Now analyzing move: ");println(i);
      byte[] move = {(byte)(movePool[i][0]), (byte)(movePool[i][1])};
      ABNode testingNode = new ABNode(board, oCaptures, tCaptures, move, player);
      if (player == 2) {
        movePool[i][2] = alphabeta(testingNode, byte(depth-1), currentMax, Short.MAX_VALUE, unPlayer);
      } else {
        movePool[i][2] = alphabeta(testingNode, byte(depth-1), Short.MIN_VALUE, currentMin, unPlayer);
      }
      //print("this_value: "); println(abValueBoard[i][j]);
      //print("current_max: "); println(currentMax);
      if (currentMax < movePool[i][2]) {
        println("GOTTA GET NEW MAX");
      }
      int currentMemory = int((Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory())/1048576);
      //print("current_memory: "); print(currentMemory); println(" MiB");
      if (currentMemory > 1024) {
        //println("Garbage collecting!");
        System.gc();
      }
      currentMin = (short)(min(currentMin, movePool[i][2]));
      currentMax = (short)(max(currentMax, movePool[i][2]));
    }
    // cycle through board looking for the best value moves
    if (player == 1) {
      bestValue = currentMin;
    } else if (player == 2) {
      bestValue = currentMax;
    }
    //List<byte[]> suitableMoves = new ArrayList<byte[]>();
    byte[] bestMove = new byte[2];
    for (short i = 0; i < movePool.length; ++i) {
      if (movePool[i][2] == bestValue) {
        bestMove[0] = (byte)(movePool[i][0]);
        bestMove[1] = (byte)(movePool[i][1]);
      }
    }
    int timeTaken = millis() - beginTime;
    println("Processing time: " + timeTaken + "ms");
    println("minval: " + currentMin);
    println("maxval: " + currentMax);
    println("value: " + bestValue);
    return bestMove;
  }

  short alphabeta(ABNode node, byte currentDepth, short alpha, short beta, byte player) {
    byte winner = game.winCheck(node.board);
    if (winner != 0) {
      if (winner == 1) {
        return Short.MIN_VALUE;
      } else {
        return Short.MAX_VALUE;
      }
    } else if (currentDepth == 0) {
      // leaf node
      return heuristic(node.board, node.oCaptures, node.tCaptures);
    } else if (player == 2) {
      // maximizing player
      short value = Short.MIN_VALUE;
      for (byte i = 0; i < Game.n; ++i) {
        for (byte j = 0; j < Game.n; ++j) {
          byte[] move = {i, j};
          if (game.isValidMove(node.board, move)) {
            ABNode child = new ABNode(node.board, node.oCaptures, node.tCaptures, move, player);
            value = (short)(max(value, alphabeta(child, byte(currentDepth-1), alpha, beta, byte(1))));
            alpha = (short)(max(alpha, value));
            if (alpha >= beta) {
              break; // beta cut-off
            }
          }
        }
      }
      return value;
    } else {
      // minimizing player
      short value = Short.MAX_VALUE;
      for (byte i = 0; i < Game.n; ++i) {
        for (byte j = 0; j < Game.n; ++j) {
          byte[] move = {i, j};
          if (game.isValidMove(node.board, move)) {
            ABNode child = new ABNode(node.board, node.oCaptures, node.tCaptures, move, player);
            value = (short)(min(value, alphabeta(child, byte(currentDepth-1), alpha, beta, byte(2))));
            beta = (short)(min(beta, value));
            if (alpha >= beta) {
              break; // alpha cut-off
            }
          }
        }
      }
      return value;
    }
  }

  short[][] sortedMovePool(byte[][] board, boolean highToLow) {
    short[][] fiboBoard = fibonacciValueBoard(board); //<>//
    short[][] movePool = new short[Game.n*Game.n][3];
    short diff = 0;
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        if (fiboBoard[i][j] == Short.MIN_VALUE && board[i][j] != 0) {
          diff++;
        } else {
          movePool[(i*Game.n)+j-diff][0] = i;
          movePool[(i*Game.n)+j-diff][1] = j;
          movePool[(i*Game.n)+j-diff][2] = fiboBoard[i][j];
        }
      }
    }
    movePool = Arrays.copyOf(movePool, movePool.length-diff);
    // now sort
    short n = (short)(movePool.length);
    // Build heap (rearrange array)
    for (short i = (short)(n/2-1); i >= 0; i--) {
      heapifyPool(movePool, n, i);
    }
    // One by one extract an element from heap
    for (short i=(short)(n-1); i>=0; i--) {
      // Move current root to end
      short[] temp = movePool[0];
      movePool[0] = movePool[i];
      movePool[i] = temp;
      // call max heapify on the reduced heap
      heapifyPool(movePool, i, (short)(0));
    }
    if (highToLow) { // reverse list
      for (short i = 0; i < movePool.length/2; i++) {
        short[] temp = movePool[i];
        movePool[i] = movePool[movePool.length-i-1];
        movePool[movePool.length-i-1] = temp;
      }
    }
    return movePool;
  }

  void heapifyPool(short arr[][], short n, short i) {
    short largest = i; // Initialize largest as root
    short l = (short)(2*i + 1); // left = 2*i + 1
    short r = (short)(2*i + 2); // right = 2*i + 2
    // If left child is larger than root
    if (l < n && arr[l][2] > arr[largest][2]) {
      largest = l;
    }
    // If right child is larger than largest so far
    if (r < n && arr[r][2] > arr[largest][2]) {
      largest = r;
    }
    // If largest is not root
    if (largest != i) {
      short[] swap = arr[i];
      arr[i] = arr[largest];
      arr[largest] = swap;
      // Recursively heapify the affected sub-tree
      heapifyPool(arr, n, largest);
    }
  }

  short heuristic(byte[][] board, byte oCaptures, byte tCaptures) {
    // float captureWeight = 1.0;
    // float fibonacciWeight = 1.0;
    // short captureValue = captureDifferenceHt(oCaptures, tCaptures);
    // short fibonacciValue = fibonacciBoardHt(board);
    // return (short)(floor((fibonacciWeight*fibonacciValue) + (captureWeight*captureValue)));
    return fibonacciBoardHt(board);
  }

  short captureDifferenceHt(byte oCaptures, byte tCaptures) {
    return (short)(tCaptures - oCaptures);
  }

  short fibonacciBoardHt(byte[][] board) {
    // get the value board
    short[][] fiboBoard = fibonacciValueBoard(board);
    short totalPieces = 0;
    // find the sum of all values in the list
    short retSum = 0;
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        if (fiboBoard[i][j] == Short.MIN_VALUE) {
          totalPieces++;
        } else {
          retSum += fiboBoard[i][j];
        }
      }
    }
    return (short)(retSum/totalPieces);
  }

  short[][] fibonacciValueBoard(byte[][] board) {
    byte top = Game.n;
    byte bottom = 0;
    byte left = Game.n;
    byte right = 0;
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        if (board[i][j] != 0) {
          // there is a piece at [i][j]
          top = (byte)(min(top, max(0, i-4)));
          bottom = (byte)(max(bottom, min(Game.n-1, i+4)));
          left = (byte)(min(left, max(0, j-4)));
          right = (byte)(max(right, min(Game.n-1, j+4)));
        }
      }
    }
    short[][][] valueList = new short[2][Game.n][Game.n]; // new value array of same size as board
    // cycle through search field
    for (byte i = top; i <= bottom; ++i) {
      for (byte j = left; j <= right; ++j) {
        // if there is a piece then do not check
        if (board[i][j] != 0) {
          // a negative one represents a piece
          valueList[0][i][j] = Short.MIN_VALUE;
          valueList[1][i][j] = Short.MIN_VALUE;
          continue;
        } else {
          byte k_LowerBound = (byte)(max(top, i-4));
          byte k_UpperBound = (byte)(min(bottom, i+4) +1);
          byte l_LowerBound = (byte)(max(left, j-4));
          byte l_UpperBound = (byte)(min(right, j+4) +1);
          for (byte k = k_LowerBound; k < k_UpperBound; ++k) {
            // vertical (|)
            if (board[k][j] != 0) {
              valueList[board[k][j]-1][i][j] += 1;
            }
            for (byte l = l_LowerBound; l < l_UpperBound; ++l) {
              // horizontal (-)
              if (k == k_LowerBound && board[i][j] != 0) {
                valueList[board[i][l]-1][i][j] += 1;
              }
              // diagonal back (\)
              if (k-i == l-j && board[k][l] != 0) {
                valueList[board[k][l]-1][i][j] += 1;
              }
              // diagonal fowards (/)
              if (i-k == l-j && board[k][l] != 0) {
                valueList[board[k][l]-1][i][j] += 1;
              }
            }
          }
        }
      }
    }
    // combine the lists
    short[][] comboList = new short[Game.n][Game.n];
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        if (valueList[0][i][j] == Short.MIN_VALUE && valueList[1][i][j] == Short.MIN_VALUE) {
          // piece present check
          comboList[i][j] = Short.MIN_VALUE;
        } else {
          // calculate fibonacci values for both players
          short oVal = valueList[0][i][j];
          short tVal = valueList[1][i][j];
          short tFibb = (short)(floor((pow(((1+sqrt(5))/2.0), tVal)-pow(((1-sqrt(5))/2.0),tVal))/sqrt(5)));
          short oFibb = (short)(floor((pow(((1+sqrt(5))/2.0), oVal)-pow(((1-sqrt(5))/2.0),oVal))/sqrt(5)));
          comboList[i][j] = (short)(tFibb - oFibb);
        }
      }
    }
    return comboList;
  }
}
