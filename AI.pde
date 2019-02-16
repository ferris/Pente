import java.util.LinkedList;
import java.util.List;
import java.util.Arrays;
import java.util.Random;


public class MCTNode {
  // general Monte Carlo Tree Search attributes
  Random rand = new Random();
  static final double epsilon = 1e-6;
  MCTNode[] children;
  double numVisits, totalValue;
  // Pente specific attributes
  private int[][] board;
  private int[] move;
  private int oCaptures;
  private int tCaptures;

  public MCTNode(int[][] board, int oCaptures, int tCaptures, int[] move, int player) {
    // deep copy to prevent collisions
    this.board = new int[Game.n][Game.n];
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        this.board[i][j] = board[i][j];
      }
    }
    // copy current capture values
    this.oCaptures = oCaptures;
    this.tCaptures = tCaptures;
    // copy move
    this.move = move.clone();
    // update capture values and board to reflect move
    if (player == 1) {
      this.oCaptures += game.isCaptureMove(this.board, player, this.move);
    } else if (player == 2) {
      this.tCaptures += game.isCaptureMove(this.board, player, this.move);
    }
    this.board[move[0]][move[1]] = player;
  }

  public void selectAction() {
    List<MCTNode> visited = new LinkedList<MCTNode>();
    MCTNode current = this;
    visited.add(this);
    while (!current.isLeaf()) {
      current = current.select();
      //println("Adding: " + current);
      visited.add(current);
    }
    current.expand();
    MCTNode newNode = current.select();
    visited.add(newNode);
    int win = simulate(newNode);
    for (MCTNode node : visited) {
      node.updateStats(win);
    }
  }

  private MCTNode select() {
    MCTNode selected = null;
    double bestValue = Double.MIN_VALUE;
    for (MCTNode child : children) {
      // initialize uct with small random number to break unexplored node ties in a random fashion
      double uctValue = rand.nextDouble() * epsilon;
      // balance exploration and exploitation by applying UCT1 (Upper Confidence Bound 1 applied to trees)
      uctValue += child.totalValue / (child.numVisits + epsilon);
      uctValue += Math.sqrt(Math.log(numVisits+1) / (child.numVisits + epsilon));
      //println("UCT value = " + uctValue);
      if (uctValue > bestValue) {
        bestValue = uctValue;
        selected = child;
      }
    }
    //println("Returning: " + selected);
    return selected;
  }

  private void expand() {
    int[] bounds = ai.searchField(this.board);
    int[][] possibleMoves = new int[((bounds[1]+1)-bounds[0])*((bounds[3]+1)-bounds[2])][2];
    short diff = 0;
    for (int i = bounds[0]; i < bounds[1]; ++i) {
      for (int j = bounds[2]; j < bounds[3]; ++j) {
        int[] currentMove = {i, j};
        if (game.isValidMove(this.board, currentMove)) {
          possibleMoves[(i-bounds[0])*((bounds[3]+1)-bounds[2])+(j-bounds[2])-diff] = currentMove;
        } else {
          diff++;
        }
      }
    }
    possibleMoves = Arrays.copyOf(possibleMoves, possibleMoves.length-diff);
    // construct children using possible moves
    children = new MCTNode[possibleMoves.length];
    for (int i = 0; i < children.length; ++i) {
      children[i] = new MCTNode(
        this.board,
        this.oCaptures,
        this.tCaptures,
        possibleMoves[i],
        new int[]{0, 2, 1}[this.board[move[0]][move[1]]]
      );
    }
  }

  public int simulate(MCTNode nodeToSimulate) {
    return rand.nextInt(2); // TODO: get rid of this: it's currently a coin flip
  }

  public void updateStats(int win) {
    numVisits++;
    totalValue += win;
  }

  public boolean isLeaf() {
    return children == null;
  }
}


public class GameAI {
  private int trials;

  GameAI (int trials) {
    this.trials = trials;
  }

  public int[] getComputerMove(int[][] board, int oCaptures, int tCaptures, int[] prevMove, int player) {
    int beginTime = millis();
    // create tree
    MCTNode root = new MCTNode(board, oCaptures, tCaptures, prevMove, player);
    // analyze
    for (int i = 0; i < this.trials; ++i) {
      root.selectAction();
    }
    // get best child and return
    int bestChild = 0;
    for (int i = 0; i < root.children.length; ++i) {
      if (root.children[i].numVisits > root.children[bestChild].numVisits) {
        bestChild = i;
      }
    }
    int timeTaken = millis() - beginTime;
    println("Processing time: " + timeTaken + "ms");
    return root.children[bestChild].move;
  }

  public int[] searchField(int[][] board) {
    // {top, bottom, left, right}
    int[] boundaries = new int[] {Game.n, 0, Game.n, 0};
    for (int i = 0; i < Game.n; ++i) {
      for (int j = 0; j < Game.n; ++j) {
        if (board[i][j] != 0) {
          // there is a piece at [i][j]
          boundaries[0] = min(boundaries[0], max(0, i-4));
          boundaries[1] = max(boundaries[1], min(Game.n-1, i+4));
          boundaries[2] = min(boundaries[2], max(0, j-4));
          boundaries[3] = max(boundaries[3], min(Game.n-1, j+4));
        }
      }
    }
    return boundaries;
  }
}