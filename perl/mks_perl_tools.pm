#!/usr/bin/perl

use warnings;
use strict;
use File::Basename;
#useful modules for working with perl

#############################
###fileToArray###
#Reads a file and stores every line in an array
#input 1 filepath: path to file
#input 2 regex: [optional] only lines with matches with the found regex are taken 
#return 1: line filled array
#############################
sub fileToArray
{
    my $filePath = shift(@_);
    my $regex = shift(@_);
    
    
    my @retArray=();
    open(my $fh, "<", $filePath) || die "Couldn't open '".$filePath."' for reading because: ".$!;
    while(my $line = <$fh>){
        chomp($line);
    	
        if ($regex) {
            my @matches = $line =~ /$regex/g;
            if (@matches) {
                push(@retArray,$line); # only add line if the regex was found in this line
            }
            
        }else{
            push(@retArray,$line); # just add every line to the array
        }
        
    }
    close($fh);
    return @retArray;
}

#############################
###getRegexFromFile###
#Reads a file and stores every found regex match in an array
#input 1 filepath: path to file
#input 2 regex: regex to search for
#return 1: array filled with regex matches
#############################
sub getRegexFromFile{
    
    my $filePath = shift(@_);
    my $regex = shift(@_);
    
    my @matches=();
    open(my $fh, "<", $filePath) || die "Couldn't open '".$filePath."' for reading because: ".$!;
    while(my $line = <$fh>){
        chomp($line);
    	
        push(@matches,$line =~ /$regex/g);    
        
    }
    close($fh);
    return @matches;
}

#############################
###getFilesFromDir###
#Reads a Directory and returns every found filename in an array, can be optimazed with search pattern
#input 1 dirPath: path to Directory
#input 2 retfullPath?  : returns the full path of the files=1 , default 0
#input 3 regex [optional]: regex for search
#return 1: array filled with fileNames
#############################

sub getFilesFromDir
{
     my $dirPath = shift(@_);
     my $isFullPath=shift(@_);
     my $regex = shift(@_);
     
     my @files = getAllFilesFromDir($dirPath);
          
     @files = grep {(-f $_)} @files; # only take real files not dirs
     if ($regex) {
        @files = grep {(/$regex/)} @files; 
     }
     if ($isFullPath==0) {
        @files = map {(basename($_))} @files;
     }
     
     return @files;
     
}

sub getAllFilesFromDir
{
    my @retArray=();
    my $dirPath = shift(@_);
    my $dh;
    opendir($dh, $dirPath) or die "Couldn't open '".$dirPath."' because: ".$!;
    my @files = grep {!/(^\.{1,2}$)/} readdir($dh); # dont take the . and .. dir
    close($dh);
 
    @files = map { $dirPath . '/' . $_ } @files; # insert the full path to each file and dir

    for ( @files)
    {
        if (-d $_) { # filename is a directory
            push(@retArray,getAllFilesFromDir($_));
        }elsif(-f $_)
        {
            push(@retArray,$_);
        }
        
    }
    return @retArray;
    
}

#############################
###readMatrixToArray###
#Reads a file and creates a matrix from them, each line will be seperated and stored in a multimensional array
#input 1 FilePath: path to file
#input 2 seperator  : how is each Column separeted from the other, default = \t
#return 1: Reference to multidimensionalArray with the rows and columns stored, and WITHOUT the header
#return 2: same as return 1 , but WITH the header row
#############################

sub readMatrixToArray
{
    my $file = shift(@_);
    my $sep = shift(@_);
    
    if(!$sep)
    {
        $sep="\t";  # setting the default seperator
    }
    
    my @matrix=();
    my @lines = fileToArray($file);
    
    foreach my $line (@lines) # iterate each row
    {
        my @row = split(/$sep/,$line);
        push(@matrix,\@row);
    }
    my @matrixWithHeader = @matrix;
    shift(@matrix);
    return \@matrix,\@matrixWithHeader;
    
}


#############################
###readMatrixToHash###
#Reads a file and creates a Hash from them, each line will be seperated and a specific column is used as keys and another as values
#input 1 FilePath: path to file
#input 2 seperator[optional]  : how is each Column separeted from the other, default = \t
#input 3 HasHeader[optional] : is a header row in the File ==1(will be removed), default =0
#input 4 and 5 keyColoum, ValueColumn [optional]: defines the coloum which will be the hash ey and value, default: key =0, value =1
#return 1: Hash without the header, if HasHeader is correctly set
#############################

sub readMatrixToHash
{
    my $file = shift(@_);
    my $sep = shift(@_);
    my $hasHeader = shift(@_);
    my $keyColumn = shift(@_);
    my $valueColumn = shift(@_);
        
    if(!$sep)
    {
        $sep="\t";  # setting the default seperator
    }
    if (!$keyColumn) {
        $keyColumn=0;
    }
    if (!$valueColumn) {
        $valueColumn=1;
    }
    
    
    my %hash;
    my @lines = fileToArray($file);
    if ($hasHeader==1) {
        shift(@lines);  # remove the header row
    }
    
    foreach my $line (@lines) # iterate each row
    {
        my @row = split(/$sep/,$line);
        $hash{$row[$keyColumn]} = $row[$valueColumn];
        
    }
    return %hash;
}
#############################
###seq_complement###
#Sequence String will be reverse complemented
#input 1 $sequence : string of dna or rna sequence
#input 2 $type  : string "dna" or "rna", defaultvalue = "dna"
#input 3 $reverse? [optional] : 0 = do not reverse, 1= to reverse complement the sequence, defaultValue =0
# return 1 : [reverse] complemented string of the given sequence
#############################
sub seq_complement
{
    my $sequence = shift(@_);
    my $type = shift(@_);
    my $isReverse = shift(@_);
    if (!$type) {
        $type="dna";
    }
    if (!$isReverse) {
        $isReverse=0;
    }
    
    if (uc($type) eq "DNA") {
        $sequence =~ tr/CGATcgat/GCTAgcta/;
    }elsif(uc($type) eq "RNA"){
        $sequence =~ tr/CGAUcgau/GCUAgcua/;
    }
    if ($isReverse==1) {
        return join'', reverse split(//,$sequence); # make an array from the string, reverse it and back to string 
    }else{
        return $sequence;
    
    }
    
}

#############################
###seq_convert###
#Sequence String will be converted either from rna to dna or vica verse, or the complement strand
#input 1 $sequence : string of dna or rna sequence
#input 2 $type  : "dna-rna" or "rna-dna" , defaultValue ="dna-rna" 
# return 1 : converted string of the given sequence
#############################
sub seq_convert
{
    my $sequence = shift(@_);
    my $type = shift(@_);
    if (!$type) {
       $type="dna-rna";
    }
    if (lc($type) eq "dna-rna") {
        $sequence =~ tr/CGATcgat/CGAUcgau/;
    }elsif(lc($type) eq "rna-dna"){
        $sequence =~ tr/CGAUcgau/CGATcgat/;
    }
    return $sequence;  
}
#############################
###seq_cut###
#Sequence atring will be cut with a given cut Sequence, could be more than once, cut happens before the first position of the cut Sequence,
# 
#input 1 $sequence : string
#input 2 $cutSeq  : Restriction like cut Sequence, cut happens before the found cutSequence
# return 1 : ref array of cutted Sequence 
#############################
sub seq_cut
{
    my $sequence = shift(@_);
    my $cutSeq = shift(@_);
    my @cutSequences;
    
    my $start=0;
    while ($sequence =~ /$cutSeq/g) { #$start always has the -1 position of the last found regex
        push(@cutSequences,substr($sequence,$start,$-[0]-$start)); # we take the last found position and (nextFoundPosition - lastFoundPosition) characters to be inserted into the resulting substrings
        $start = $-[0];
    }
    push(@cutSequences,substr($sequence,$start,length($sequence))); # also take the last part of the sequence
    
    return \@cutSequences;    
}


return 1;
