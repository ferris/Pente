public class GameAI {
  private static final float EXPLORATION_PARAMETER = 1.41421;
  private int calculationTime;

  public GameAI(int calculationTime) {
    this.calculationTime = calculationTime;
  }

  public int[] getComputerMove(GameState currentGameState) {
    int beginTime = millis();
    // create tree
    MCTNode root = new MCTNode(currentGameState);
    // analyze within time
    int timesCalculated = 0;
    MCTNode currentNode = root;
    while (millis() - beginTime < calculationTime) {
      currentNode = treePolicy(root);
      float winnerEstimate = defaultPolicy(currentNode.getGameState());
      backUp(currentNode, winnerEstimate);
      timesCalculated += 1;
    }
    MCTNode bestChild = bestChild(root, 0);
    // get best child and return
    int timeTaken = millis() - beginTime;
    println("Best child value: " + bestChild.getTotalValue());
    println("Best child simulations: " + bestChild.getTotalSimulations());
    println("Percent chance of winning: " + nfc(100*bestChild.getTotalValue()/bestChild.getTotalSimulations(), 2) + "%");
    println("Calculated " + timesCalculated + "games in " + timeTaken + " ms");
    return bestChild.state.getPreviousMove();
  }

  private MCTNode treePolicy(MCTNode node) {
    while (!node.isTerminal()) {
      if (node.isLeaf()) {
        return expand(node);
      } else {
        node = bestChild(node, EXPLORATION_PARAMETER);
      }
    }
    return node;
  }

  private MCTNode expand(MCTNode node) {
    node.generateChildren();
    return bestChild(node, EXPLORATION_PARAMETER);
  }

  private MCTNode bestChild(MCTNode node, float exploreParam) {
    MCTNode selected = null;
    MCTNode[] children = node.getChildren();
    float bestValue = Float.MIN_VALUE;
    for (MCTNode child : children) {
      float uctValue = child.getUCTValue(exploreParam);
      if (uctValue > bestValue) {
        bestValue = uctValue;
        selected = child;
      }
    }
    return selected;
  }

  private float defaultPolicy(GameState state) {
    state = state.getDuplicate();
    while (state.getWinner() == 0) {
      int[][] possibleMoves = state.getPossibleMoves();
      state.playMove(possibleMoves[int(random(possibleMoves.length))]);
    }
    return state.getWinner();
  }

  private void backUp(MCTNode node, float winnerEstimate) {
    while (node != null) {
      float valueChange = winnerEstimate == node.getGameState().getPlayerOfCurrentTurn() ? 0 : 1;
      node.updateTotals(1, valueChange);
      node = node.getParent();
    }
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
      children[i] = new MCTNode(this);
      children[i].getGameState().playMove(possibleMoves[i]);
    }
  }

  public float getUCTValue(float exploreParam) {
    // initialize uct with small random number to break unexplored node ties in a random fashion
    float uctValue = random(1) * epsilon;
    // balance exploration and exploitation by applying UCT1 (Upper Confidence Bound 1 applied to trees)
    uctValue += totalValue / (numVisits + epsilon);
    uctValue += exploreParam * sqrt(log(parent.getTotalSimulations() + 1) / (numVisits + epsilon));
    return uctValue;
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

  public float getTotalSimulations() {
    return numVisits;
  }

  public float getTotalValue() {
    return totalValue;
  }

  private boolean isLeaf() {
    return children == null;
  }
  
  private boolean isTerminal() {
    return state.getWinner() != 0;
  }
}
