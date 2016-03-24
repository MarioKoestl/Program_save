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



return 1;
