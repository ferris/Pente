public class GameAI {
  private static final float EXPLORATION_PARAMETER = 1.41421;
  private int calculationTime;

  public GameAI(int calculationTime) {
    this.calculationTime = calculationTime;
  }

  private float MCTSSolver(MCTNode n) {
    if (n.getGameState().getWinner() == n.getGameState().getPlayerOfCurrentTurn()) {
      return Float.POSITIVE_INFINITY;
    } else if (n.getGameState().getWinner() == 3 - n.getGameState().getPlayerOfCurrentTurn()) {
      return Float.NEGATIVE_INFINITY;
    }
    MCTNode bestChild;
    float delta;
    if (n.isLeaf()) {
      bestChild = expand(n);
    } else {
      bestChild = select(n, EXPLORATION_PARAMETER);
    }
    n.addOneToVisits();
    if (bestChild.getTotalValue() != Float.POSITIVE_INFINITY && bestChild.getTotalValue() != Float.NEGATIVE_INFINITY) {
      if (bestChild.getTotalVisits() == 0) {
        delta = -1 * playOut(bestChild);
        n.addToValue(delta);
        return delta;
      } else {
        delta = -1 * MCTSSolver(bestChild); //<>//
      }
    } else {
      delta = bestChild.getTotalValue();
    }
    if (delta == Float.POSITIVE_INFINITY) {
      n.setValue(Float.NEGATIVE_INFINITY);
    } else if (delta == Float.NEGATIVE_INFINITY) {
      for (MCTNode child : n.getChildren()) {
        if (child.getTotalValue() != delta) {
          delta = -1;
          n.addToValue(delta);
          return delta;
        }
      }
      n.setValue(Float.POSITIVE_INFINITY);
      return delta;
    }
    n.addToValue(delta);
    return delta;
  }

  public int[] getComputerMove(GameState currentGameState) {
    int beginTime = millis();
    // create tree
    MCTNode root = new MCTNode(currentGameState);
    // analyze within time
    int timesRun = 0;
    while (millis() - beginTime < calculationTime) {
      float rootVal = MCTSSolver(root);
      // break if proven win or loss
      if (rootVal == Float.POSITIVE_INFINITY || rootVal == Float.NEGATIVE_INFINITY) {
        print("INSTANT");
        break;
      }
      timesRun++;
    }
    // get best child and return
    MCTNode sChild = secureChild(root, 1); //<>//
    int timeTaken = millis() - beginTime;
    println("Best child value: " + sChild.getTotalValue());
    println("Best child simulations: " + sChild.getTotalVisits());
    println("Ran " + timesRun + " times in " + timeTaken + " ms");
    return sChild.getGameState().getPreviousMove();
  }

  private MCTNode expand(MCTNode node) {
    node.generateChildren();
    return select(node, EXPLORATION_PARAMETER);
  }

  private MCTNode select(MCTNode node, float exploreParam) {
    MCTNode selected = node;
    MCTNode[] children = node.getChildren();
    float bestValue = -1 * Float.MAX_VALUE;
    for (MCTNode child : children) {
      float uctValue = child.getUCTValue(exploreParam);
      if (uctValue > bestValue) {
        bestValue = uctValue;
        selected = child;
      }
    }
    return selected;
  }

  private MCTNode secureChild(MCTNode rootNode, float aParam) {
    MCTNode selected = null;
    MCTNode[] children = rootNode.getChildren();
    float bestValue = -1 * Float.MAX_VALUE;
    for (MCTNode child : children) {
      float scValue = child.getSCValue(aParam);
      if (scValue > bestValue) {
        bestValue = scValue;
        selected = child;
      }
    }
    return selected;
  }

  private float playOut(MCTNode node) {
    node.addOneToVisits();
    GameState state = node.getGameState().getDuplicate();
    while (state.getWinner() == 0 || state.isTie()) {
      //print("loop#3");
      int[][] possibleMoves = state.getPossibleMoves();
      if (possibleMoves.length > 0) {
        state.playMove(possibleMoves[int(random(possibleMoves.length))]);
      } else {
        break;
      }
    }
    float delta = (state.getWinner() == node.getGameState().getPlayerOfCurrentTurn()) ? 1 : -1;
    node.addToValue(delta);
    return delta;
  }
}

public class MCTNode {
  // general Monte Carlo Tree Search attributes
  private static final float epsilon = 1e-6;
  private MCTNode parent;
  private MCTNode[] children;
  private float numVisits;
  private float totalValue;
  // State of this node
  private GameState state;

  public MCTNode(GameState state) {
    this.parent = null;
    this.state = state.getDuplicate();;
  }

  public MCTNode(MCTNode parent) {
    this.parent = parent;
    this.state = parent.getGameState().getDuplicate();
  }

  public void generateChildren() {
    int[][] possibleMoves = state.getPossibleMoves();
    children = new MCTNode[possibleMoves.length];
    for (int i = 0; i < children.length; ++i) {
      if (possibleMoves[i][0]==0 && possibleMoves[i][1] == 4 && this.getGameState().getBoard()[0][3] == 1 && this.getGameState().getBoard()[0][2] == 1 && this.getGameState().getBoard()[0][1] == 1 && this.getGameState().getPlayerOfCurrentTurn() == 1) {
        println("fiver");
      }
      children[i] = new MCTNode(this);
      children[i].getGameState().playMove(possibleMoves[i]);
    }
  }

  public float getUCTValue(float exploreParam) {
    // initialize uct with small random number to break unexplored node ties in a random fashion
    float uctValue = random(1) * epsilon;
    // balance exploration and exploitation by applying UCT1 (Upper Confidence Bound 1 applied to trees)
    uctValue += totalValue / (numVisits + epsilon);
    uctValue += exploreParam * sqrt(log(parent.getTotalVisits() + 1) / (numVisits + epsilon));
    return uctValue;
  }

  public float getSCValue(float aParam) {
    return totalValue + (aParam / sqrt(numVisits));
  }

  public GameState getGameState() {
    return state;
  }

  public MCTNode getParent() {
    return parent;
  }

  public MCTNode[] getChildren() {
    return children;
  }

  public void updateTotals(float totalSimulationChange, float totalValueChange) {
    numVisits += totalSimulationChange;
    totalValue += totalValueChange;
  }

  public void addOneToVisits() {
    numVisits++;
  }

  public void addToValue(float num) {
    totalValue += num;
  }

  public void setValue(float num) {
    totalValue = num;
  }

  public float getTotalVisits() {
    return numVisits;
  }

  public float getTotalValue() {
    return totalValue;
  }

  private boolean isLeaf() {
    return children == null;
  }
}
