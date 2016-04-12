#!/usr/bin/perl

use strict;
use warnings;
use Class::Struct;

struct(Item=> {
   value  => '$',
   up => '$',
   left => '$',
   
});




my @W =("3 3","3 2","0 7");
my @N = ("1 0 2","4 6 5");
my @S = [[]];

print "Initializing West parameters......\n";
for(my $lineCount=0;$lineCount< scalar(@W);$lineCount++)
{
    my @C = split(/ /,$W[$lineCount]);
    for(my $c =0; $c < scalar(@C)+1;$c++)
    {
        print "modifying : S[$lineCount][$c] \n";
        if ($c==0 and $lineCount==0) {
            my $it = Item->new();
            $it->left(-1);
            $it->up(-1);
            $S[$lineCount][$c]=$it;
        }elsif ($c==0) {
            my $it = Item->new();
            $it->left(-1);
            $S[$lineCount][$c]=$it;
        }elsif ($c>0) {
            my $it = Item->new();
            $it->left($C[$c-1]);
            $S[$lineCount][$c]=$it;
        }
        
     }
    print "\n";
}
print "Initializing Nord parameters......\n";

my @C2 = split(/ /,$N[0]);
for(my $c =0; $c < scalar(@C2);$c++)
{
    $S[0][$c]->up(-1);
}

for(my $lineCount=0;$lineCount< scalar(@N);$lineCount++)
{
    my @C = split(/ /,$N[$lineCount]);
    for(my $c =0; $c < scalar(@C);$c++)
    {
        print "modifying : S[",$lineCount+1,"][$c] \n";
        $S[$lineCount+1][$c]->up($C[$c]);    
     }
    print "\n";
    
}



###Left
print "LEFT\n";
foreach (@S)
{
    foreach (@$_)
    {
        my $item = $_;
        print $item->left ."\t";
    }
    print "\n";
}
###UP
print "UP\n";
foreach (@S)
{
    foreach (@$_)
    {
        my $item = $_;
        print $item->up ."\t";
    }
    print "\n";
}


#starting initialazing alle [j][0] and [0][i] and [0][0]

$S[0][0]->value(0); 

for(my $i = 1; $i< scalar @{$S[0]} ; $i++)
{
	$S[0][$i]->value($S[0][$i-1]->value + $S[0][$i]->left);
}

for(my $j = 1; $j< scalar @S; $j++)
{
	$S[$j][0]->value($S[$j-1][0]->value + $S[$j][0]->up);
}


# Starting with REAL problem solving
for(my $j = 1; $j< scalar @S; $j++)
{
	for(my $i = 1; $i< scalar @{$S[$j]} ; $i++)
	{
		$S[$j][$i]->value( max($S[$j-1][$i]->value + $S[$j][$i]->up, $S[$j][$i-1]->value + $S[$j][$i]->left)); # maxValue of this position can either be the maxValue on the left + the cost to get from left to cur Pos. or the maxValue above + the cost to get to the cur Pos.
	}
}


###Value
print "Value\n";
foreach (@S)
{
    foreach (@$_)
    {
        my $item = $_;
        print $item->value ."\t";
    }
    print "\n";
}



my $j = scalar(@S)-1;
my $i = scalar(@{$S[$j]})-1;
my @solution=();
my $s="";
push(@solution,"($j,$i)");
while ($i >0 and $j >0)
{
	if(($S[$j-1][$i]->value + $S[$j][$i]->up) == $S[$j][$i]->value)
	{
		$s=$j-1;
		push(@solution,"($s,$i)");
		$j=$j-1;
	}elsif($S[$j][$i-1]->value + $S[$j][$i]->left == $S[$j][$i]->value)
	{
		$s = $i-1;
		push(@solution,"($j,$s)");
		$i=$i-1;
	}
}

print reverse @solution ;

sub max
{
	return ($_[0], $_[1])[$_[0] < $_[1]]
}

