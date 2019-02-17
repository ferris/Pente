import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

public class GameAI {
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
    MCTNode currentNode;
    int valueEstimate;
    while (millis() - beginTime < calculationTime) {
      currentNode = treePolicy(root);
      valueEstimate = currentNode.defaultPolicy();
      currentNode.backUp(valueEstimate);
      timesCalculated += 1;
    }
    MCTNode bestChild = root.bestChild(0);
    // get best child and return
    int timeTaken = millis() - beginTime;
    // float chanceOfWinning = root.children[bestChild].totalValue / root.children[bestChild].numVisits;
    // println("Percent chance of winning: " + nfc(100*chanceOfWinning, 2) + "%");
    println("Calculated " + timesCalculated + "games in " + timeTaken + " ms");
    return bestChild.state.getPreviousMove();
  }

  // private MCTNode treePolicy(MCTNode node) {
  //   while (!node.isLeaf() && node.winner == 0) {
  //   }
  // }

  // private expand(MCTNode node) {
  //   int[][] possibleMoves = node.state.getPossibleMoves();
  //   node.children = new MCTNode[possibleMoves.length];
  //   for (int i = 0; i < children.length; ++i) {
  //     children[i] = node.getDuplicate();
  //     children[i].playMove(possibleMoves[i]);
  //   }
  //   return bestChild(node, 1.41421);
  // }
}

public class MCTNode {
  // general Monte Carlo Tree Search attributes
  private static final float epsilon = 1e-6;
  public MCTNode[] children;
  public float numVisits, totalValue;
  // State of this node
  public GameState state;

  public MCTNode(GameState state) {
    this.state = state;
  }

  private boolean isLeaf() {
    return children == null;
  }
}