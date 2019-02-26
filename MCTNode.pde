
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
    // balance exploration and exploitation by calculating Upper Confidence Bound    
    float uctValue = totalValue / (numVisits + epsilon);
    uctValue += cParam * sqrt(2 * log(parent.getTotalVisits() + 1) / (numVisits + epsilon));
    return uctValue;
  }

  public float getLCBValue(float cParam) {
    // balance exploration and exploitation by calculating Lower Confidence Bound
    float scValue = totalValue / (numVisits + epsilon);
    scValue -= cParam * sqrt(2 * log(parent.getTotalVisits()) / (numVisits + epsilon));
    return scValue;
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
