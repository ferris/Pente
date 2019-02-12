import java.util.*;


class ABTree {
  private ABNode root;

  ABTree(int[][] board, int oCaptures, int tCaptures, int[] move) {
    this.root = new ABNode(board, oCaptures, tCaptures, move);
    for (int i = 0; i < board.length; ++i) {
      if (board[i].length != board.length) {
        throw new IllegalArgumentException("Board must be a square!");
      }
    }
    // this.root.board = board;
    // this.root.move = move;
  }
}

class ABNode {
  private int value;
  private int[][] board;
  private int[] move;
  private int oCaptures;
  private int tCaptures;
  private ABNode parent;
  private List<ABNode> children = new ArrayList<ABNode>();

  ABNode(int[][] board, int oCaptures, int tCaptures, int[] move) {
    // deep copy to prevent collisions
    this.board = new int[Game.n][Game.n];
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        this.board[i][j] = board[i][j];
      }
    }
    this.oCaptures = oCaptures;
    this.tCaptures = tCaptures;
    this.move = move.clone();
  }

  void generateChildren(int player) {
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        int[] move = {i, j};
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
  int value;
  int[] move;

  ABObj(int value, int[] move) {
    this.value = value;
    if (move.length != 2) {
      throw new IllegalArgumentException("Move has to be of length 2; {x, y}");
    }
    this.move = move;
  }
}


class GameAI {
  private final int SIZE = 19;
  private int[] prevMove;
  private int oCaptures = 0;
  private int tCaptures = 0;

  public int[] getComputerMove(int[][] board, int oCaptures, int tCaptures, int depth, int player) {
    int beginTime = millis();
    ABTree tree = new ABTree(board, oCaptures, tCaptures, new int[] {-1, -1});
    int value = alphabeta(tree.root, depth, Integer.MIN_VALUE, Integer.MAX_VALUE, player);
    print("val" +  value);
    List<ABNode> suitableMoves = new ArrayList<ABNode>();
    for (ABNode child : tree.root.children) {
      if (child.value == value) {
        suitableMoves.add(child);
      }
    }
    int timeTaken = millis() - beginTime;
    println("Processing time: " + timeTaken + "ms");
    println("value: " + value);
    return suitableMoves.get(int(random(0, suitableMoves.size()))).move;
  }

  int alphabeta(ABNode node, int depth, int alpha, int beta, int player) {
    if (depth == 0) {
      // leaf node
      node.value = heuristic(node.board, node.oCaptures, node.tCaptures);
      return node.value;
    } else if (player == 2) {
      // maximizing player
      node.value = Integer.MIN_VALUE;
      node.generateChildren(player);
      for (ABNode child : node.children) {
        node.value = max(node.value, alphabeta(child, depth-1, alpha, beta, 1));
        alpha = max(alpha, node.value);
        if (alpha >= beta) {
          break; // beta cut-off
        }
      }
      return node.value;
    } else {
      // minimizing player
      node.value = Integer.MAX_VALUE;
      node.generateChildren(player);
      for (ABNode child : node.children) {
        node.value = min(node.value, alphabeta(child, depth-1, alpha, beta, 2));
        beta = min(beta, node.value);
        if (alpha >= beta) {
          break; // alpha cut-off
        }
      }
      return node.value;
    }
  }

  int heuristic(int[][] board, int oCaptures, int tCaptures) {
    // this is a super dumb heuristic
    // all it does is see how many tiles are on the board
    // computer tiles - human tiles

    return captureDifferenceHt(oCaptures, tCaptures);

    // println("oCaptures: " + oCaptures);
    // println("tCaptures: " + tCaptures);

    // int tileCount = 0;
    // int unTileCount = 0;

    // for (int i = 0; i < board.length; ++i) {
    //   for (int j = 0; j < board[i].length; ++j) {
    //     if (board[i][j] == 2) {
    //       tileCount++;
    //     } else if (board[i][j] == 1) {
    //       unTileCount++;
    //     }
    //   }
    // }
    // return tileCount - unTileCount;
  }

  int captureDifferenceHt(int oCaptures, int tCaptures) {
    println("diff" + str(tCaptures - oCaptures));
    return tCaptures - oCaptures;
  }
}
