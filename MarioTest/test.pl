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
            $it->value(0);
            $it->left(-1);
            $it->up(-1);
            $S[$lineCount][$c]=$it;
        }elsif ($c==0) {
            my $it = Item->new();
            $it->value(0);
            $it->left(-1);
            $S[$lineCount][$c]=$it;
        }elsif ($c>0) {
            my $it = Item->new();
            $it->value(0);
            $it->left($C[$c-1]);
            $S[$lineCount][$c]=$it;
        }
        
     }
    print "\n";
}

print $S[1][0]->left;

print "Initializing Nord parameters......\n";


my @C2 = split(/ /,$N[0]);
for(my $c =0; $c < scalar(@C2);$c++)
{
    my $it = $S[0][$c];
    $it->up(-1);
}

for(my $lineCount=0;$lineCount< scalar(@N);$lineCount++)
{
    my @C = split(/ /,$N[$lineCount]);
    for(my $c =0; $c < scalar(@C);$c++)
    {
        print "modifying : S[",$lineCount+1,"][$c] \n";
        
        my $it = $S[$lineCount+1][$c];
        $it->up($C[$c]);    
        
     }
    print "\n";
    
}



###Value

print $S[0  ][0]->value;

print "VALUE\n";
foreach (@S)
{
    foreach (@$_)
    {
        my $item = $_;
        print $item->value ."\t";
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
#my $item = $S[0][2];
#print $item->left;


