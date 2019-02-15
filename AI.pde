import java.util.*;


class ABTree {
  private ABNode root;

  ABTree(byte[][] board, byte oCaptures, byte tCaptures, byte[] move) {
    this.root = new ABNode(board, oCaptures, tCaptures, move);
    for (int i = 0; i < board.length; ++i) {
      if (board[i].length != board.length) {
        throw new IllegalArgumentException("Board must be a square!");
      }
    }
  }
}

class ABNode {
  private short value;
  private byte[][] board;
  private byte[] move;
  private byte oCaptures;
  private byte tCaptures;
  private ABNode parent;
  private List<ABNode> children = new ArrayList<ABNode>();

  ABNode(byte[][] board, byte oCaptures, byte tCaptures, byte[] move) {
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
  }

  void generateChildren(byte player) {
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        byte[] move = {i, j};
        if (game.isValidMove(this.board, move)) {
          int index = this.children.size();
          this.children.add(new ABNode(this.board, this.oCaptures, this.tCaptures, move));
          ABNode child = children.get(index);
          child.parent = this;
          if (player == 1) {
            child.oCaptures += game.isCaptureMove(child.board, player, child.move);
          } else if (player == 2) {
            child.tCaptures += game.isCaptureMove(child.board, player, child.move);
          }
          child.board[move[0]][move[1]] = player;
        }
      }
    }
  }
}


class ABObj {
  short value;
  byte[] move;

  ABObj(short value, byte[] move) {
    this.value = value;
    if (move.length != 2) {
      throw new IllegalArgumentException("Move has to be of length 2; {x, y}");
    }
    this.move = move;
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
    // generate ABP value board and find the maximum value within
    short[][] abValueBoard = new short[Game.n][Game.n];
    short bestValue = 0;
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        print("Now analyzing move: "); println((i*Game.n)+j+1);
        if (board[i][j] == 0) {
          ABNode testingNode = new ABNode(board, oCaptures, tCaptures, new byte[]{i, j});
          // deletable start (during second stage where this is moved to ABNode's constructor)
          if (player == 1) {
            testingNode.oCaptures += game.isCaptureMove(testingNode.board, player, testingNode.move);
          } else if (player == 2) {
            testingNode.tCaptures += game.isCaptureMove(testingNode.board, player, testingNode.move);
          }
          testingNode.board[i][j] = player;
          // deletable end
          abValueBoard[i][j] = alphabeta(testingNode, byte(depth-1), Short.MIN_VALUE, Short.MAX_VALUE, unPlayer);
          int currentMemory = int((Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory())/1048576);
          print("current_memory: "); print(currentMemory); println(" MiB");
          if (currentMemory > 1024) {
            println("Garbage collecting!");
            System.gc();
          }
          if (player == 1) {
            bestValue = (short)(min(bestValue, abValueBoard[i][j]));
          } else if (player == 2) {
            bestValue = (short)(max(bestValue, abValueBoard[i][j]));
          }
        }
      }
    }
    // cycle through board looking for the max value moves
    List<byte[]> suitableMoves = new ArrayList<byte[]>();
    for (byte i = 0; i < Game.n; ++i) {
      for (byte j = 0; j < Game.n; ++j) {
        if (abValueBoard[i][j] == bestValue) {
          suitableMoves.add(new byte[]{i, j});
        }
      }
    }
    int timeTaken = millis() - beginTime;
    println("Processing time: " + timeTaken + "ms");
    println("value: " + bestValue);
    return suitableMoves.get(int(random(0, suitableMoves.size())));
  }

  short alphabeta(ABNode node, byte currentDepth, short alpha, short beta, byte player) {
    if (currentDepth == 0) {
      // leaf node
      node.value = heuristic(node.board, node.oCaptures, node.tCaptures);
      return node.value;
    } else if (player == 2) {
      // maximizing player
      node.value = Short.MIN_VALUE;
      node.generateChildren(player);
      Iterator<ABNode> i = node.children.iterator();
      while (i.hasNext()) {
        node.value = (short)(max(node.value, alphabeta(i.next(), byte(currentDepth-1), alpha, beta, byte(1))));
        i.remove();
        alpha = (short)(max(alpha, node.value));
        if (alpha >= beta) {
          break; // beta cut-off
        }
      }
      /*
      for (ABNode child : node.children) {
        node.value = (short)(max(node.value, alphabeta(child, byte(currentDepth-1), alpha, beta, byte(1))));
        alpha = (short)(max(alpha, node.value));
        if (alpha >= beta) {
          break; // beta cut-off
        }
      }
      */
      return node.value;
    } else {
      // minimizing player
      node.value = Short.MAX_VALUE;
      node.generateChildren(player);
      Iterator<ABNode> i = node.children.iterator();
      while (i.hasNext()) {
        node.value = (short)(min(node.value, alphabeta(i.next(), byte(currentDepth-1), alpha, beta, byte(2))));
        if (currentDepth < depth - 1) {
          i.remove();
        }
        beta = (short)(min(beta, node.value));
        if (alpha >= beta) {
          break; // alpha cut-off
        }
      }
      /*
      for (ABNode child : node.children) {
        node.value = (short)(min(node.value, alphabeta(child, byte(currentDepth-1), alpha, beta, byte(2))));
        beta = (short)(min(beta, node.value));
        if (alpha >= beta) {
          break; // alpha cut-off
        }
      }
      */
      return node.value;
    }
  }

  short heuristic(byte[][] board, byte oCaptures, byte tCaptures) {
    return captureDifferenceHt(oCaptures, tCaptures);
  }

  short captureDifferenceHt(byte oCaptures, byte tCaptures) {
    //println("diff" + str(tCaptures - oCaptures));
    return (short)(tCaptures - oCaptures);
  }
}
