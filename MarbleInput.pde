void humanMoveCheck() {
  if (155 < mouseX && mouseX <= 646 && 52 <= mouseY && mouseY <= 543) {
    noFill();
    stroke(16, 24, 60);
    ellipse((mouseX/26)*26+9, (mouseY/26)*26+13, 20, 20);
    if (mouseReleased) {
      int r = ((mouseY - 52) - (mouseY - 52) % 26) / 26;
      int c = ((mouseX - 155) - (mouseX - 155) % 26) / 26;
      game.placeMarble(r, c);
    }
  }
}