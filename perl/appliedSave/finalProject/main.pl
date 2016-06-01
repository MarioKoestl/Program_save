 #!/usr/bin/perl
 
# input 2 species ( check for valid with file species list) Name or ID can be inserted
 #1.
 # check members.tv, each line and list the TaxonId.ProteinID  (Function read tsv by line create hash with GroupName and list of TaxonID.protien)
 # if s1 is inside this list and s2 is also, than increase count
 
 
use strict;
use warnings;
use Getopt::Long;

my $usage= << "JUS";
  Title:   main.pl
  usage:   perl main.pl -s1 [speciesId1] -s2 [speciesId2]
  
  options: -s1|species1  [REQUIRED]    ID found in eggnog for first species 
           -s2|species2   [REQUIRED]   ID found in eggnog for second species
           -p|path                     data PATH, default value = ./data
           -help|h               print this message
           -verbose|v            print additional informations        
        
  results: returns the amount of homolog genes of species1 in species 2
JUS



my $opt_help;
my $opt_v;
my $s1=1;
my $s2=2;
my $path = "./data";
#!!!CHANGE ALL FILE TO ARGUMENTS

GetOptions(
  "h|help|" => \$opt_help,
  "s1|species1=s" => \$s1,
  "s2|species2=s" => \$s2,
  "p|path=s" => \$path,
  "verbose|v" => \$opt_v);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (!$s1 or !$s2) {
    print $usage;
    exit;
}


#number 1#######################
#if(containSpecies($s1,$path."/species_list.txt") and containSpecies($s2,$path."/species_list.txt"))
#{
#    my %h_homo = %{createTsvHash($path."/meNOG.members.tsv")};
#    
#    print "Coutner =", countHomo($s1,$s2,\%h_homo),"\n";   
#}else
#{
#    print("inserted Species are not present in the eggNOG database!!\n");
#}
############################

##########################
#number 2
#######################
my $humanId = 9606; # do not hardcode!!!
my $mouseId = 10090;
my $panId = 9598;

if(containSpecies($humanId,$path."/species_list.txt") and containSpecies($mouseId,$path."/species_list.txt") and containSpecies($panId,$path."/species_list.txt"))
{
    my %h_homo = %{createTsvHash($path."/meNOG.members.tsv")};
    
    my @protArray = @{countHomoWithConstraints($humanId,$panId,$mouseId,\%h_homo)};
    print " I found ", scalar @protArray," homologs with the given criteria\n";
    foreach (@protArray)
    {
        print "$_\n";
    }
}else
{
    print("inserted Species are not present in the eggNOG database!!\n");
}




#count the amount of homologs for species1 with constraitns, homologs in s2 but not in s3
sub countHomoWithConstraints
{
    my $s1 = shift(@_);
    my $s2 = shift(@_);
    my $s3 = shift(@_);
    my %h_homo = %{shift(@_)};
    my @protArray;
    
    foreach my $groupId (keys %h_homo)
    {
        my @taxProtArray = @{$h_homo{$groupId}};
        if($opt_v)
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
            
            if($opt_v)
            {
                print "TaxId = $taxId\tProtId = $protId\n";
                print "s1 = $s1\ts2=$s2\n";
            }
            
            if ($s1 eq $taxId) {
                $isS1present=1;
                if($opt_v)
                {
                    print "$s1 is present in this group\n";   
                }
                $prot1 = $protId; # store this for later usage, S1 should be only one times in the list i assume
                print "$protId\n";
                my $sdf=<STDIN>;
            }
            if ($s2 eq $taxId) {
                $isS2present=1;
                if ($opt_v)
                {
                    print "$s2 is present in this group\n";
                }
            }
            if ($s3 eq $taxId) {
                $isS3present=1;
                if ($opt_v)
                {
                    print "$s3 is present in this group\n";
                }
            }
            
        }
        if ($isS1present and $isS2present and !$isS3present) # s1 and s2  have proteins in this group, bitut s3 should not have a homolog
        {
            #$counter+=1;
            push(@protArray,$prot1); #!!! woher kommen die leerzeichen her!!!
            if ($opt_v)
            {
                print " homologs found, counter = ",scalar @protArray,"\n";
            }  
        }else
        {
            if ($opt_v)
            {
                print "no homolog found for this group or $s3 has also homologs\n counter = ",scalar @protArray,"\n";
            }
        }
   
    }
    return \@protArray;
}




#exercise 1, count the amount of homolog proteins between species s1 and s2
sub countHomo
{
    my $s1 = shift(@_);
    my $s2 = shift(@_);
    my %h_homo = %{shift(@_)};
    
    my $counter=0;
    foreach my $groupId (keys %h_homo)
    {
        my @taxProtArray = @{$h_homo{$groupId}};
        if($opt_v)
        {
            print "TaxProtArray = @taxProtArray\n";
        }
        
        my $isS1present= 0 ; 
        my $isS2present= 0 ; 
        foreach my $taxProt(@taxProtArray) # loop all taxProt strings for this groupId
        {
            #print "TaxProtString = $taxProt\n";
            my $taxId = (split(/\./,$taxProt))[0];
            my $protId = (split(/\./,$taxProt))[1];
            
            if($opt_v)
            {
                print "TaxId = $taxId\tProtId = $protId\n";
                print "s1 = $s1\ts2=$s2\n";
            }
            
            if ($s1 eq $taxId) {
                $isS1present=1;
                if($opt_v)
                {
                    print "$s1 is present in this group\n";
                }
            }
            if ($s2 eq $taxId) {
                $isS2present=1;
                if ($opt_v)
                {
                    print "$s2 is present in this group\n";
                }
                
               
            }
            
        }
        if ($isS1present and $isS2present) { # both species have proteins in this group, therefore they have this protein homolog and we count it
            $counter+=1;
            if ($opt_v)
            {
                print " homologs found, counter = $counter\n";
            }  
        }else
        {
            if ($opt_v)
            {
                print "no homolog found for this group counter = $counter\n";
            }
        }
   
    }
    return $counter;
}

#(Function read tsv by line create hash with GroupName and list of TaxonID.protien)
# Hash id = GroupId, hash value = list of "TaxonId.ProteinId"
# so this hash represents all homologes for the given GroupId jey
sub createTsvHash
{
    my $f = shift(@_);
    my %hash;
    open(my $fh, "<", $f) || die "Couldn't open '".$f."' for reading because: ".$!;

    while(my $line = <$fh>){
        my @split = split(/\t/,$line);
        my @list = split(/,/,$split[5]);
        $hash{$split[1]}=\@list;
    }
    return \%hash;
    
}




# check for valid with file species list) ID can be inserted
sub containSpecies
{
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


