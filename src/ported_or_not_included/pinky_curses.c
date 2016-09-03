/*
   09/03/2016

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

   Compile with:
    gcc -Wall -Wextra -O2 pinky_curses.c -o pinky_curses -lncurses
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>

#include <unistd.h>
#include <signal.h>

#include <ncurses.h>

#define VLA 1000

void unglify_n_print(WINDOW* win, char *);
void sighandler(int num);

void sighandler(int num) {
  endwin();
  exit(EXIT_FAILURE);
}

void unglify_n_print(WINDOW *win, char *str1) {
  int_least16_t color_pair = 1, fg = 1, bg = 1, iclr = 0;
  char *ptr = str1, cclr[1];

  pair_content(color_pair, &fg, &bg);
  for (; *ptr; ptr++) {
    if ('\0' == *ptr) {
      break;
    }
    if ('&' == *ptr)  {
      cclr[0] = *ptr++;
      switch(toupper((unsigned char) *ptr)) {
        case 'B':
          iclr = COLOR_BLUE;
          break;
        case 'M':
          iclr = COLOR_MAGENTA;
          break;
        case 'Y':
          iclr = COLOR_YELLOW;
          break;
        default:
          waddch(win, (chtype)cclr[0]);
          break;
      }
      iclr += (isupper((unsigned char) *ptr) ? 8 : 0);
      wattrset(win, COLOR_PAIR(COLORS + iclr));  /* | A_BOLD */
    } else {
      waddch(win, (chtype)*ptr);
    }
  }
}

int main(void) {
  signal(SIGINT, sighandler);

  int_least16_t x = 0, z = 0;
  char buf[VLA];

  initscr();
  noecho();
  cbreak();
  halfdelay(20);
  nonl();
  intrflush(stdscr, FALSE);
  curs_set(FALSE);

  if(FALSE == (has_colors())) {
    endwin();
    return EXIT_FAILURE;
  }
  start_color();
  for (x = 0; x < COLORS; x++ ) {
    for (z = 0; z < COLORS; z++ ) {
      init_pair((x * COLORS) + z, x, z);
    }
  }

  while (1) {
    clear();
    if (NULL != (fgets(buf, VLA, stdin))) {
      unglify_n_print(stdscr, buf);
    }
    refresh();
  }

  endwin();
  return EXIT_SUCCESS;
}
