public class GameAI {
  private static final float EXPLORATION_PARAMETER = 2;
  private int calculationTime;

  public GameAI(int calculationTime) {
    this.calculationTime = calculationTime;
  }
  
  //public int[] getComputerMove(GameState currentGameState) {
  public MCTNode getComputerMove(GameState currentGameState) {
    int beginTime = millis();
    // create tree
    MCTNode root = new MCTNode(currentGameState);
    // analyze within time
    int timesRun = 0;
    //while (millis() - beginTime < calculationTime) {
    while (timesRun < 5000) {
      float turnValue = MCTSSolver(root);
      // break if proven win or loss
      if (turnValue == Float.POSITIVE_INFINITY || turnValue == Float.NEGATIVE_INFINITY) {
        println("INSTANT = " + turnValue);
        break;
      }
      timesRun++;
    }
    // get best child and return
    MCTNode sChild = secureChild(root, 1);
    int timeTaken = millis() - beginTime;
    println("Best child value: " + sChild.getTotalValue());
    println("Best child simulations: " + sChild.getTotalVisits());
    println("Ran " + timesRun + " times in " + timeTaken + " ms");
    print("[");print(sChild.getGameState().getPreviousMove()[0]);print("] [");print(sChild.getGameState().getPreviousMove()[1]);println("]");
    //return sChild.getGameState().getPreviousMove();
    return sChild;
  }

  private float MCTSSolver(MCTNode n) {
    if (n.getGameState().getWinner() == (3 - n.getGameState().getPlayerOfCurrentTurn())) {
      n.setValue(Float.POSITIVE_INFINITY);
      return Float.NEGATIVE_INFINITY;
    } else if (n.getGameState().getWinner() == n.getGameState().getPlayerOfCurrentTurn()) {
      return Float.POSITIVE_INFINITY; // I think I can remove this (it shouldn't ever run)
    }
    MCTNode bestChild;
    float result;
    if (n.isLeaf()) {
      bestChild = expand(n);
    } else {
      bestChild = select(n, EXPLORATION_PARAMETER);
    }
    n.addOneToVisits();
    if (bestChild.getTotalValue() != Float.POSITIVE_INFINITY && bestChild.getTotalValue() != Float.NEGATIVE_INFINITY) {
      if (bestChild.getTotalVisits() == 0) {
        result = -1 * playOut(bestChild);
        n.addToValue(result);
        return result;
      } else {
        result = -1 * MCTSSolver(bestChild);
      }
    } else {
      result = bestChild.getTotalValue();
    }
    if (result == Float.POSITIVE_INFINITY) {
      n.setValue(Float.NEGATIVE_INFINITY);
      return result;
    } else if (result == Float.NEGATIVE_INFINITY) {
      for (MCTNode child : n.getChildren()) {
        if (child.getTotalValue() != result) {
          result = -1;
          n.addToValue(result);
          return result;
        }
      }
      n.setValue(Float.POSITIVE_INFINITY);
      return result;
    }
    n.addToValue(result);
    return result;
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

  private MCTNode expand(MCTNode node) {
    node.generateChildren(); //<>//
    int playerToMove = node.getGameState().getPlayerOfCurrentTurn();
    for (MCTNode child : node.getChildren()) { //<>//
      if (child.getGameState().getWinner() == playerToMove) { //<>//
        child.setValue(Float.POSITIVE_INFINITY); //<>//
        break;
      } else if (child.getGameState().tessCheck() == playerToMove) {
        child.generateChildren();
        for (MCTNode grandchild : child.getChildren()) {
          int childUnCaptures = child.getGameState().getCaptureCount()[2-playerToMove];
          int grandchildUnCaptures = grandchild.getGameState().getCaptureCount()[2-playerToMove];
          if (grandchildUnCaptures > childUnCaptures && grandchild.getGameState().tessCheck() != playerToMove) {
            if (grandchild.getGameState().tessCheck() != playerToMove) {
              return select(node, EXPLORATION_PARAMETER); //<>//
            }
          } else if (grandchild.getGameState().getWinner() == 3 - playerToMove) {
            return select(node, EXPLORATION_PARAMETER); //<>//
          }
        }
        child.setValue(Float.POSITIVE_INFINITY); //<>//
      }
    }
    return select(node, EXPLORATION_PARAMETER);
  }

  private float playOut(MCTNode node) {
    node.addOneToVisits();
    GameState state = node.getGameState().getDuplicate();
    int[][] conBoard = state.getConnectionBoard();
    while (state.getWinner() == 0 || state.isTie()) {
      int[][] movePool = state.getMovePool(conBoard);
      if (movePool.length == 0) { break; }
      // get two possible moves, choose the one with the greater connection value
      int[] moveOption1 = movePool[int(random(movePool.length))];
      int[] moveOption2 = movePool[int(random(movePool.length))];
      int[] move = new int[2];
      if (moveOption1[2] >= moveOption2[2]) {
        move[0] = moveOption1[0];
        move[1] = moveOption1[1];
      } else {
        move[0] = moveOption2[0];
        move[1] = moveOption2[1];
      }
      int[] cc = state.getCaptureCount();
      state.playMove(move);
      conBoard = state.getConnectionBoard(conBoard, cc);
    }
    float result = (state.getWinner() == node.getGameState().getPlayerOfCurrentTurn()) ? -1 : 1;
    node.addToValue(result);
    return result;
  }

  private float playOutH(MCTNode node) {
    node.addOneToVisits();
    GameState state = node.getGameState().getDuplicate();
    while (state.getWinner() == 0 || state.isTie()) {
      int[][] movePool = state.getPossibleMoves();
      if (movePool.length > 0) {
        // get two possible moves, choose the one with the greater connection value
        int[] move = movePool[int(random(movePool.length))];
        // int[] moveOption1 = movePool[int(random(movePool.length))];
        // int[] moveOption2 = movePool[int(random(movePool.length))];
        // int[] move = new int[2];
        // if (moveOption1[2] >= moveOption2[2]) {
        //   move[0] = moveOption1[0];
        //   move[1] = moveOption1[1];
        // } else {
        //   move[0] = moveOption2[0];
        //   move[1] = moveOption2[1];
        // }
        state.playMove(move);
      } else {
        break;
      }
    }
    float result = (state.getWinner() == node.getGameState().getPlayerOfCurrentTurn()) ? -1 : 1;
    node.addToValue(result);
    return result;
  }
  
  private MCTNode secureChild(MCTNode rootNode, float aParam) {
    MCTNode[] children = rootNode.getChildren();
    MCTNode selected = children[0];
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
}
