import java.util.*;


class ABTree {
    private ABNode root;

    ABTree(int[][] board, int[] move) {
        this.root = new ABNode(board, move);
        for (int i = 0; i < board.length; ++i) {
            if (board[i].length != board.length) {
                throw new IllegalArgumentException("Board must be a square!");
            }
        }
        this.root.board = board;
        if (move.length != 2) {
            throw new IllegalArgumentException("Move has to be of length 2; {x, y}");
        }
        this.root.move = move;
        this.root.children = new ArrayList<ABNode>();
    }
}

class ABNode {
    private int[][] board;
    private int[] move;
    private int captures;
    private ABNode parent;
    private List<ABNode> children;

    ABNode(int[][] board, int[] move) {
        this.board = board;
        this.move = move;
    }

    void generateChildren(int player) {
        for (int i = 0; i < Game.n; ++i) {
            for (int j = 0; j < Game.n; ++j) {
                int[] move = {i, j};
                if (game.isValidMove(this.board, move)) {
                    int index = this.children.size();
                    this.children.add(new ABNode(this.board, move));
                    ABNode child = children.get(index);
                    child.parent = this;
                    child.captures = this.captures;
                    child.captures += game.isCaptureMove(child.board, player, child.move);
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

    int[] AlphaBeta(int[][] board, int depth, int player) {
        int beginTime = millis();
        int[] fakeMove = {-1, -1};
        ABTree tree = new ABTree(board, fakeMove);
        ABObj m = minValue(tree.root, depth, player, new ABObj(Integer.MIN_VALUE, fakeMove), new ABObj(Integer.MAX_VALUE, fakeMove));
        int timeTaken = millis() - beginTime;
        print("Processing time: " + timeTaken);
        return m.move;
    }
    
    ABObj minValue(ABNode node, int depth, int player, ABObj alpha, ABObj beta) {
        // figure out the opposite player tile (1 = blue; 2 = orange)
        int unplayer;
        if (player == 1) {
            unplayer = 2;
        } else {
            unplayer = 1;
        }
        // return heuristic if leaf
        if (depth == 0) {
            if (player == 2) {
                return new ABObj(heuristic(node.board), node.move);
            } else {
                return new ABObj(heuristic(node.board) * -1, node.move);
            }
        }
        // find children for children
        node.generateChildren(player);
        for (int i = 0; i < node.children.size(); ++i) {
            ABObj m = maxValue(node.children.get(i), depth-1, unplayer, alpha, beta);
            if (m.value < beta.value) {
                beta.value = m.value; // TODO: FIGURE OUT IF IT'S VALUE OR THE OBJ??
            }
            if (alpha.value >= beta.value) {
                break;
            }
        }
        return beta;
    }

    ABObj maxValue(ABNode node, int depth, int player, ABObj alpha, ABObj beta) {
        // figure out the opposite player tile (1 = blue; 2 = orange)
        int unplayer;
        if (player == 1) {
            unplayer = 2;
        } else {
            unplayer = 1;
        }
        // return heuristic if leaf
        if (depth == 0) {
            if (player == 2) {
                return new ABObj(heuristic(node.board), node.move);
            } else {
                return new ABObj(heuristic(node.board) * -1, node.move);
            }
        }
        // find children for children
        node.generateChildren(player);
        for (int i = 0; i < node.children.size(); ++i) {
            ABObj m = minValue(node.children.get(i), depth-1, unplayer, alpha, beta);
            if (m.value > alpha.value) {
                alpha.value = m.value; // TODO: FIGURE OUT IF IT'S VALUE OR THE OBJ??
            }
            if (alpha.value >= beta.value) {
                break;
            }
        }
        return alpha;
    }
    

    int heuristic(int[][] board) {
        // this is a super dumb heuristic
        // all it does is see how many tiles are on the board
        int tileCount = 0;
        int unTileCount = 0;

        for (int i = 0; i < board.length; ++i) {
            for (int j = 0; j < board[i].length; ++j) {
                if (board[i][j] == 2) {
                    tileCount++;
                } else if (board[i][j] == 1) {
                    unTileCount++;
                }
            }
        }
        return tileCount - unTileCount;
    }
}
