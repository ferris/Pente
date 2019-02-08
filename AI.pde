import java.util.*

class ABTree {
    private ABNode root;

    ABTree(int[][] board, int[] move) {
        root = new ABNode();
        root.board = this.board;
        root.move = this.move;
        root.children = new ArrayList<ABNode>();
    }

    static class ABNode {
        private int[][] board;
        private int[] move;
        private ABNode parent;
        private List<ABNode> children;
    }
}

class GameAI {
    private int[] prevMove;
    private int n = 19;
    private int oCaptures = 0;
    private int tCaptures = 1;

    int[] AlphaBeta(int[][] board, int depth, int player) {
        int beginTime = millis();
        int[] fakeMove = [-1, -1];
        ABTree tree = new ABTree(this.board, fakeMove);
        // m = minValue(tree.root, this.depth, this.player, (Integer.MIN_VALUE, fakeMove), (Integer.MAX_VALUE, fakeMove))
        int timeTaken = millis() - beginTime;
        print("Processing time: " + timeTaken);
    }
}