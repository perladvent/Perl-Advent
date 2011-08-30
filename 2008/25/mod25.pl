use Term::Animation;
use Curses;

#You may need to disable color for lamer terminals
(my $anim = Term::Animation->new)->color(1);

#Build a snowman
$anim->new_entity(
		  position      => [25, 2, 10],
		  shape         => do{ read(DATA, $_, 557); $_ },
		  color         => do{ read(DATA, $_, 426); $_ }
		 );
#Discard comment
seek(DATA, 49, 1);

#Pack a projectile
$snowball = [ do{ read(DATA, $_, 11); $_ }, do{ read(DATA, $_, 7); $_ } ];

#Lob it
$anim->new_entity(
		  shape         => $snowball,
		  position      => [-3, 6, 2],
		  callback_args => [0, $anim->gen_path( 0,9,2,    #begin
						       47,9,2,    #end
						       [(0)x6,1], #change
						       my $step=7)] );
halfdelay(2);
getch() && $anim->animate() for( 1..$step );
sleep 3 && $anim->end();

__DATA__
            .-~~\
           /     \ _
           ~x   .-~_)_
             ~x".-~   ~-.
         ,.  ( /         \   ,.
         ||   T  o  o     Y  ||
       ==:l   l   <       !  I;==
          \\   \  .__/   /  //
           \\ ,r"-,___.-'r.//
            }^ \.( )   _.'//.
           /    }~Xi--~  //  \
          Y    Y I\ \    "    Y
          |    | |o\ \        |
          |    l_l  Y T       |  -Row
          l      "o l_j       !
           \                 /
    ___,.---^.     o       .^---.._____
"~~~          "           ~            ~~~"
            bbbbb
           b     b b
           bb   bbbbb
             bbb
         yy  b               yy
         yy      K  K        yy
       yyyy       Y          yyyy
          yy                yy
           yy  r rrrrrrr R yy
               RRR R  RRRRyy
                RRRRRRR  yy
               R RR R  r
               R RKr R
               RRR  R R          KKKK
                 rK RRR

                   K             #Some terminals don't do light black
   _
= (_)
 _
(_|
