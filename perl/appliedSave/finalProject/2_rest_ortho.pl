 #!/usr/bin/perl
 
 #!!! ATTENTATOInich nehm ya nur das erste protein wenng efunde, z.B. vom menschen, sollt ich das zweite auch nehemen
use strict;
use warnings;
use Getopt::Long;
use lib::Eggnog;

my $usage= << "JUS";
  Title:   2_rest_ortho.pl
  usage:   perl 2_rest_ortho.pl -s1 [speciesId1] -s2 [speciesId2]
  
  options: -s1|species1  [REQUIRED]    ID found in eggnog for first species 
           -s2|species2  [REQUIRED]    ID found in eggnog for second species
           -s3|species3  [REQUIRED]    ID found in eggnog for third species, -1 for all other species
           -slp|slpath                 speciesList file PATH, default value = ./data/species_list.txt
           -me|members                 meNOG_Members file  PATH, default value = ./data/meNOG.members.tsv
           -ap|annopath                annotation file PATH, default = ./data/meNOG.annotations.tsv
           -rp|rpath                   results PATH, default = ./results/
           -help|h               print this message
           -verbose|v            print additional informations        
           -debug|d            print debugging informations
  results: Calculates all genes present in species1 with homologs in species2 but without homologs in species3( or all other species if -1 was choosen)
           -prints the amount of found genes
           -stores all the corresponding proteinIds in a separeted file in rpath, filename = "protIds_s1_s2_s3.txt"
           -finds the functional description of the groupId for the found proteins /genes, stored in file in rpath, filename will be protFunc_s1_s2_s3.txt
JUS

my $opt_help;
my $opt_d;
my $opt_v;
my $s1;
my $s2;
my $s3;
my $specListPath;
my $membersPath;
my $annoPath;
my $respath;

GetOptions(
  "h|help|" => \$opt_help,
  "s1|species1=s" => \$s1,
  "s2|species2=s" => \$s2,
  "s3|species3=s" => \$s3,
  "slp|slpath=s" => \$specListPath,
  "me|members=s" => \$membersPath,
  "ap|annopath=s" => \$annoPath,
  "rp|rpath=s" => \$respath,
  "verbose|v" => \$opt_v,
  "debug|d" => \$opt_d);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (!$s1 or !$s2 or !$s3) {
    print $usage;
    exit;
}
if (!$specListPath or (! -f $specListPath)) {
    print "no valid species list path inserted, slpath is set to ./data/species_list.txt \n";
    $specListPath = "./data/species_list.txt";
}
if (!$membersPath or (! -f $membersPath)) {
    print "no valid members path inserted, members path is set to ./data/meNOG.members.tsv \n";
    $membersPath = "./data/meNOG.members.tsv";
}
if (!$annoPath or (! -f $annoPath)) {
    print "no valid annotation file path inserted, annopath is set to ./data/meNOG.annotations.tsv \n";
    $annoPath = "./data/meNOG.annotations.tsv";
}

if (!$respath or (! -d $respath)) {
    print "no valid rpath inserted, dpath is set to ./results/ \n";
    $respath = "./results/";
}


#my $humanId = 9606; # do not hardcode!!!
#my $panId = 9598;
#my $mouseId = 10090;
my $resProtPath = $respath."protIds_".$s1."_".$s2."_".$s3.".txt";
my $resFuncProtPath = $respath."protFunc_".$s1."_".$s2."_".$s3.".txt";
if(lib::Eggnog->containSpecies($s1,$specListPath) and lib::Eggnog->containSpecies($s2,$specListPath) and ($s3 eq "-1" or lib::Eggnog->containSpecies($s3,$specListPath) )) # -1 is shurely not a specis, but is also allowed for species 3
{
    my %h_homo = %{lib::Eggnog->createTsvHash($membersPath)};
    
    my @group_protArray = @{countHomoWithConstraints($s1,$s2,$s3,\%h_homo)};
    
    print scalar @group_protArray," homologs with the given criteria were found\n";  
    if($opt_d)
    {  
        foreach (@group_protArray)
        {
            print "".(split(/\-/,$_))[1]."\n";
        }
    }
    if(writeProtArrayToFile(\@group_protArray,$resProtPath)){
        print("File $resProtPath was created\n");
    }
    else{
        print("protIds were NOT writen to File $resProtPath\n");
    }
    
    #from here exercise 2c
    if(writeDescr($resFuncProtPath,lib::Eggnog->getTSVHash_anno($annoPath),\@group_protArray)){
        print("File $resFuncProtPath was created\n");
    }
    else{
        print("protFunctDes were NOT writen to File $resFuncProtPath\n");
    }
}else
{
    print("inserted Species are not present in the eggNOG database!!\n");
}



sub writeDescr
{
  my $f= shift(@_);
  my %groupId_h = %{shift(@_)}; #contains all lines from annotations file
  my @group_protArray = @{shift(@_)}; # @group_protArray array to look for
  if(open(my $fh, ">", $f)){
    print $fh "groupId\tprotId\tprotCount\tfunctId\tdesc\n";
    foreach (@group_protArray)
    {
        my $groupId = (split(/\-/,$_))[0];
        my $protId = (split(/\-/,$_))[1];
        my $protCount = $groupId_h{$groupId}[0];
        my $functId = $groupId_h{$groupId}[1];
        my $desc = $groupId_h{$groupId}[2];
        
        if($opt_v){
            print("\n------------------\n");
            print("groupId= $groupId\n");
            print("protId= $protId\n");
            print("protCount= $protCount\n");
            print("functId= $functId\n");
            print("desc= $desc\n");
        }
        print $fh $groupId."\t".$protId."\t".$protCount."\t".$functId."\t".$desc."\n";
        
    }
    close($fh);
    return 1;
  }else{
      print "Couldn't open '".$f."' for writing because: ".$!."\n";
  }
  return 0;
  
}

sub writeProtArrayToFile
{
  my @array = @{shift(@_)};
  my $f = shift(@_);
  if(open(my $fh, ">", $f)){
      foreach(@array)
      {
          my $prot = (split(/\-/,$_))[1]."\n";
          print $fh $prot;
      }
      close($fh);
      return 1;
  }else{
      print "Couldn't open '".$f."' for writing because: ".$!."\n";
  }
  return 0;
  
}

#count the amount of homologs for species1 with constraints, homologs in s2 but not in s3
#if s3 = *, than in only homologs in s1 and s2 exclusevily are taken, are not present in any other species
sub countHomoWithConstraints
{
    my $s1 = shift(@_);
    my $s2 = shift(@_);
    my $s3 = shift(@_);
    my %h_homo = %{shift(@_)};
    my @group_protArray; # stores the found homolog proteinIds and the corresponsing group ID, format: "groupId-proteinId"
    foreach my $groupId (keys %h_homo)
    {
       
        my @taxProtArray = @{$h_homo{$groupId}};
        if($opt_d)
        {
            print "TaxProtArray = @taxProtArray\n";
        }
        
        my $isS1present= 0 ; 
        my $isS2present= 0 ;
        my $isS3present= 0;
        my $prot1; # stores the found protID for the species1, will be used outside of the loop to store the homolog protein
        
        foreach my $taxProt(@taxProtArray) # loop all taxProt strings for this groupId
        {
            my $taxId = (split(/\./,$taxProt))[0];
            my $protId = (split(/\./,$taxProt))[1];
            
            if($opt_d)
            {
                print "TaxId = $taxId\tProtId = $protId\n";
                print "s1 = $s1\ts2=$s2\n";
            }
            
            if ($s1 eq $taxId) {
                $isS1present=1;
                if($opt_d)
                {
                    print "$s1 is present in this group\n";   
                }
                $prot1 = $protId; # store this for later usage, S1 should be only one times in the list i assume
                if ($opt_d) { 
                    print "found protId for $s1 = $protId\n";
                }
            }
            if ($s2 eq $taxId) {
                $isS2present=1;
                if ($opt_d)
                {
                    print "$s2 is present in this group\n";
                }
            }
            if ($s3 eq $taxId or ($s3 eq "-1" and scalar @taxProtArray>2)) { # if the aount of taxProt > 2, than there is at least one other homolog here, which means if s3 = * this should not be pushed
                $isS3present=1;
                if ($opt_d)
                {
                    print "$s3 is present in this group\n";
                }
            }
            
        }
        if ($isS1present and $isS2present and !$isS3present) # s1 and s2  have proteins in this group, but s3 should not have a homolog
        {
  
            push(@group_protArray,$groupId."-".$prot1); 
            if ($opt_d)
            {
                print " homologs found, counter = ",scalar @group_protArray,"\n";
            }  
  
        }else
        {
            if ($opt_d)
            {
                print "no homolog found for this group or $s3 has also homologs\n counter = ",scalar @group_protArray,"\n";
            }
        }
   
    }
    return \@group_protArray;
}
