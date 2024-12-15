#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <ctype.h>

int32_t inputCol() {
  printf ("Enter column A-G: ");
  int32_t colNum;
  char col;
  //check if input is a-g or A-G
  scanf (" %c", &col);
  col = toupper(col);
  colNum = col - '0';
  colNum -= 17;
  if(isdigit(col) || colNum > 6) {
    printf("Invalid input, try again\n");
    return inputCol();
  }
  return colNum;
}

// function that prints array
void printArray(int32_t* arr) {
        int counter = 0;
for(int i = 0; i < 6; ++i) {
for (int j = 0; j < 7; ++j) {
printf ("%d ",arr[counter++]);
}
printf("\n");
}
printf("A B C D E F G\n");
}

void player1() {
  printf("Player 1's turn\n");
}

void player2() {
  printf("Player 2's turn\n");
}