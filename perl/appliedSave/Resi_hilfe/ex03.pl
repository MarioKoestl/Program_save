#!usr/bin/perl
use strict;
use warnings;
print "Exercise 3 by Marie-Theres Bräuer.\n\n";
######Exercise 3.1########
######accession numbers###
print "Exercise 3.1\n\n";
my $filename_old="swissprot_list.txt";
my $filename_new="swissprot_accession_numbers.txt";
my @returnArray;
open(my $array1,'<'.$filename_old)  or die "Could not open '.$filename_old.' for reading because: .$!\n";
open(my $newfile_h, '>>'.$filename_new) or die "Could not open '.$filename_new.' for appending because: .$!\n";

my $lineCounter=0; #hat immer die zahl der aktuellen Zeile, faengt natuerlich bei Zeile 0 an
foreach my $line (<$array1>)
{
    if ($lineCounter==0 or $lineCounter==1 or $lineCounter==2) {  # die erste, zweite und dritte zeile soll nicht betrachtet werden, kann man ja nichts splitten
        $lineCounter = $lineCounter +1; #obwohl wir diese Zeile nicht betrachten wollen muessn wir den Coutner erhoehen, sonst kommt man immer hier hinein
        next; # darum next = diesen schleifendurchgang beenden, und den naechsten starten
       
    }
    
   # my @list1 = split (/()/,@array1); #!!HIER willst du irgendwie das FILE splitten, du sollst aber die Lines splitten
    my @list1 = split (/ /,$line);  # und nicht mit () splitten, sondern mit den leerzeichen
    
    print "ZEILE: $lineCounter = @list1"; # jetzt ist hier ein array der ersten zeile unterteilt von leerzeichen, und du brauchst das 2 element dieses Arrayz
    # $list1[0] wuerde jetzt ACM1_HUMAN sein, $list1[1] jetzt (P11229)  usw.
    
    push(@returnArray,$list1[1]); #darum jetzt hier einfach das richtige element vom geplitteten array verwenden
    
    $lineCounter = $lineCounter +1 ; # naechste zeile ab jetzt, darum um eins erhoehen
}

print "\nAUSGABE ALLER IDS : @returnArray \n\n";

close ($filename_old);
close ($filename_new);