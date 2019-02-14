# heuristic script for pente
from math import sqrt

test_board = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,2,0,1,0,1,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,1,2,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,2,2,1,0,1,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,1,0,2,1,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,2,2,0,0,1,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,1,0,2,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,],
              [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,]]

def fibonacci(n):
    return int((1+sqrt(5))**n-(1-sqrt(5))**n)/(2**n*sqrt(5))

def heuristic(board, player):
  # find limit of search field
  top = len(board)
  bottom = 0
  left = len(board[0])
  right = 0
  for i in range(len(board)):
    for j in range(len(board[i])):
      if board[i][j] != 0:
        # there is a piece at [i][j]
        top = min(top, max(0, i-4))
        bottom = max(bottom, min(len(board)-1, i+4))
        left = min(left, max(0, j-4))
        right = max(right, min(len(board[i])-1, j+4))
  # create new value array of same size as board
  value_list = [[[0] * len(board[0]) for i in range(len(board))],
                [[0] * len(board[0]) for i in range(len(board))]]
  # create marbel total var for end adjustment
  marbels = 0
  # cycle through search field
  for i in range(top, bottom+1):
    for j in range(left, right+1):
      # if there is a piece, don't check
      if board[i][j] != 0:
        marbels += 1
        continue
      k_lower_bound = max(top, i-4)
      k_upper_bound = min(bottom, i+4) + 1
      l_lower_bound = max(left, j-4)
      l_upper_bound = min(right, j+4) + 1
      for k in range(k_lower_bound, k_upper_bound):
        # vertical (|)
        if board[k][j] != 0:
          value_list[board[k][j]-1][i][j] += 1
        for l in range(l_lower_bound, l_upper_bound):
          # horizontal (–)
          if k == k_lower_bound and board[i][l] != 0:
            value_list[board[i][l]-1][i][j] += 1
          # diagonal back (\)
          if k-i == l-j and board[k][l] != 0:
            value_list[board[k][l]-1][i][j] += 1
          # diagonal fowards (/)
          if i-k == l-j and board[k][l] != 0:
            value_list[board[k][l]-1][i][j] += 1
  combo_list = [[0] * len(board[0]) for i in range(len(board))]
  for i in range(len(combo_list)):
    for j in range(len(combo_list[i])):
      if player == 2:
        combo_list[i][j] = int(fibonacci(value_list[1][i][j]) - fibonacci(value_list[0][i][j]))
      else:
        combo_list[i][j] = int(fibonacci(value_list[0][i][j]) - fibonacci(value_list[1][i][j]))
  ret_sum = 0
  for i in range(len(combo_list)):
    print(combo_list[i])
    for j in range(len(combo_list[i])):
      ret_sum += combo_list[i][j]
  return int(ret_sum)

print(heuristic(test_board, 2))