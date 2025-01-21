// io.bC
// Shows how to do simple I/O in bC
// Compile:
//    /y/shared/Engineering/cs-drbc/cs445/bC io.bC > io.tm
//    Delete the last 2 lines.
// Run:
//    /y/shared/Engineering/cs-drbc/cs445/tmbc io.tm
//    g
//    --- enter integers to play the game
//    q

main() {
   int x;
   x = 1;

   while x != 2 do {
      outputc('D');outputc('o');outputc(' ');outputc('y');outputc('o');outputc('u');outputc(' ');outputc('w');outputc('a');outputc('n');outputc('t');
      outnl();      
      outputc(' ');outputc(' ');outputc('1');outputc('.');outputc(' ');outputc('C');outputc('o');outputc('n');outputc('t');outputc('i');outputc('n');outputc('u');outputc('e');
      outnl();
      outputc(' ');outputc(' ');outputc('2');outputc('.');outputc(' ');outputc('S');outputc('t');outputc('o');outputc('p');
      outnl();
      x = input();
   }
}
