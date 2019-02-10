int[] humanMoveCheck() {
  // returns {moveMade, row, column}
  int[] retArr = {0, -1, -1};
  if (155 < mouseX && mouseX <= 646 && 52 <= mouseY && mouseY <= 543) {
    noFill();
    stroke(16, 24, 60);
    ellipse((mouseX/26)*26+9, (mouseY/26)*26+13, 20, 20);
    if (mouseReleased) {
      retArr[0] = 1;
      retArr[1] = ((mouseY - 52) - (mouseY - 52) % 26) / 26; // row
      retArr[2] = ((mouseX - 155) - (mouseX - 155) % 26) / 26; // col
    }
  }
  return retArr;
}