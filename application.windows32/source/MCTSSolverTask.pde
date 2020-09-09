
public static class MCTSSolverTask implements Callable<Float> {
  public static GameAI parentAI;
  public static MCTNode treeRoot;
  private MCTNode childToAnalyze;

  public MCTSSolverTask(MCTNode childToAnalyze) {
    this.childToAnalyze = childToAnalyze;
  }

  public Float call() {
    return parentAI.MCTSSolver(childToAnalyze);
  }
}
