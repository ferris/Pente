public class MCTNode {
  private static final float epsilon = 1e-6; // used to prevent division by zero
  private MCTNode parent;
  private MCTNode[] children;
  private float numVisits;
  private float totalValue;
  private GameState state; // State of this node

  public MCTNode(GameState state) {
    this.parent = null;
    this.state = state.getDuplicate();;
  }

  public MCTNode(MCTNode parent) {
    this.parent = parent;
    this.state = parent.getGameState().getDuplicate();
  }

  public void generateChildren() {
    int[][] possibleMoves = state.getSortedMovePool();
    children = new MCTNode[possibleMoves.length];
    for (int i = 0; i < children.length; ++i) {
      children[i] = new MCTNode(this);
      children[i].getGameState().playMove(possibleMoves[i]);
    }
  }

  public float getUCBValue(float cParam) {
    // initialize ucb with small random number to break unexplored node ties in a random fashion
    float uctValue = random(1) * epsilon;
    // balance exploration and exploitation by calculating Upper Confidence Bound
    uctValue += totalValue / (numVisits + epsilon);
    uctValue += cParam * sqrt(2 * log(parent.getTotalVisits() + 1) / (numVisits + epsilon));
    return uctValue;
  }

  public float getLCBValue(float cParam) {
    // initialize ucl with small random number to break unexplored node ties in a random fashion
    float uctValue = random(1) * epsilon;
    // balance exploration and exploitation by calculating Lower Confidence Bound
    uctValue += totalValue / (numVisits + epsilon);
    uctValue -= cParam * sqrt(2 * log(parent.getTotalVisits()) / (numVisits + epsilon));
    return uctValue;
  }
  
  public float getSCValue() {
    return (totalValue / (numVisits + epsilon)) + (1 / (sqrt(numVisits) + epsilon));
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
