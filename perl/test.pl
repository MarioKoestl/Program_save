#!/usr/bin/perl

use strict;
use warnings;

my @capitals = ("dfg","sds","sdfsg","sepp");

my @numbers = (234,65,234,11,344,111,234,55,3,2,1,);


my $s1 = "dfkdf depp hugo depp";

$s1 =~ s/[aeiou]/'-'/g;  #  substitute every character of aeiou with -

print $s1;


