#!/usr/bin/perl
package lib::Eggnog;
use warnings;
use strict;

#(Function read tsv by line create hash with GroupName and list of TaxonID.protien)
# Hash id = GroupId, hash value = list of "TaxonId.ProteinId"
# so this hash represents all homologes for the given GroupId jey
sub createTsvHash
{
    shift(@_);  # first parameter is the module name itself
    my $f = shift(@_);
    my %hash;
    open(my $fh, "<", $f) || die "Couldn't open '".$f."' for reading because: ".$!;

    while(my $line = <$fh>){
        chomp($line);
        my @split = split(/\t/,$line);
        my @list = split(/,/,$split[5]);
        $hash{$split[1]}=\@list;
    }
    close($fh);
    return \%hash; 
}
#get all lines from annotation file
#HashId = groupId, hash value = list of protein count for this groupId, the corresponding functionalId and a description
sub getTSVHash_anno
{
    shift(@_);  # first parameter is the module name itself
    my $f = shift(@_);
    my %hash;
    open(my $fh, "<", $f) || die "Couldn't open '".$f."' for reading because: ".$!;

    while(my $line = <$fh>){
        chomp($line);
        my @split = split(/\t/,$line);
        my @list; # this list contains the protein count for this groupId, the corresponding functionalId and a description
        push(@list,$split[2]);
        push(@list,$split[4]);
        push(@list,$split[5]);
        $hash{$split[1]}=\@list;
    }
    close($fh);
    return \%hash; 
    
}

# check for valid with file species list) ID can be inserted
sub containSpecies
{
    shift(@_); #irst parameter is the module name itself
    my $id = shift(@_); # could be name string, or Id
    my $f = shift(@_);
    open(my $fh, "<", $f) || die "Couldn't open '".$f."' for reading because: ".$!;

    while(my $line = <$fh>){
        my @split = split(/\t/,$line);
        
        if($split[1] eq $id)
        {
            return 1;
        }
    }
    return 0;
    
}


return 1;