#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

use Bioinformatics::Pattern;
use Bioinformatics::Restriction;






my $usage= << "JUS";
  Title:    mkoestl_Ex05
  usage:    mkoestl_Ex05 -file [inputFile]
  
  options: -file|f  [REQUIRED]   Input fasta file
           -help|h               print this message     

  results: calculate fragments sizes after restriction enzm has cutted given dna sequence
JUS

########c#########
my $opt_file;
my $opt_help;
GetOptions(
  "h|help|" => \$opt_help,
  "file|f=s" => \$opt_file);

#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (! -f $opt_file) {
    print "$opt_file is no valid file \n$usage";
    exit;
}

my $dna_seq = @{Bioinformatics::Pattern::getFastaSeqs($opt_file)}[0];
my $resPattern="[ag]gatc[ct]";
my @pos_Array = Bioinformatics::Pattern::getPatternMatchPositions(
                    "sequence"=> $dna_seq,
                    "pattern"=> $resPattern,
                    "is_circular"=>"TRUE");

my @frags = Bioinformatics::Restriction::getFragmentLengths(
            "pos_array"=> \@pos_Array,
            "seq_Length"=>length($dna_seq),
            "is_circular"=>"TRUE");

print "If sequence : \n\n $dna_seq \n\n is cutted with restriction enzymPatter $resPattern following gragment lengths appear: \n\n"; 
foreach (@frags)
{
    print "$_\n";
}
########a#########
#my $dna_seq ="ccggatccggatccggcccggatcgcgcgcgcgcgcgcgcgcgggatcccgtagctacggatcc";

#my @pos = Bioinformatics::Pattern::getPatternMatchPositions(
#"sequence"=> $dna_seq,
#"pattern"=> "[ag]gatc[ct]",
#"is_circular"=>"TRUE");

#print "@pos \n\n";

########b#########
#my @frags = Bioinformatics::Restriction::getFragmentLengths(
#    "pos_array" => \@pos,
#    "seq_Length" => length($dna_seq),
#    "is_circular"=>"TRUE");

#print "@frags \n";





