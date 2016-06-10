#!/usr/bin/perl

#use perl 5.10;
use feature say;
use strict;
use warnings;

# ------------------------------------------------- #
# - Author:         Jun Yu Jacinta Cai
# - Last modified:  11 March 2014
# - Version:        1.1
# - CS Research with Dr. Thacker & Dr. Bangalore
# - Description: Tags line with corresponding list
#                provided by the user 
# - Usage: ./tagit.pl < inputFilename > outputFilename
#           
# ------------------------------------------------- #

my %tagList;
my $file;

# Tag List that you would be using to tag a file
open ($file, "<", "taglist.txt") or die "Could not open taglist.txt";
my $recent = "";
while(<$file>) {
    chomp;
    $_ = lc($_); # make tags lowercased
    if ($_ =~ /\t(\w+)/) {
        # If the line has a tab, then push the value
        # into the reference array within the correct hash key
        push @{$tagList{$recent}}, $1;
    } else {
        # If the line doesn't have a tab, then make a new
        # key with an empty reference array
        $tagList{$_} = [];
        $recent = $_;
    }
}

# Set up output file
#say "Accession Number\tDate\t

#some tags are in a field called /note in GenBank

# File you want to tag
my $line;
while(<>) {
    chomp;
    $line = $_;
    my $tagB = 0;
    while(my($k, $v) = each %tagList) {
        # Steps through the key / values of the hash
        if ($tagB == 1) {}
        else {
        foreach (@$v) {
            # looks at each value of the hash
            if ($tagB == 1) {}
            else {
            if(lc($line) =~ /$_/) {
                # searches the input file line and see if it
                # contains the value of the hash
                # If it does have it, then print out the corresponding
                # key with the line (to tag the line)
                say "$line\t$k";
                $tagB = 1;
            } 
            }
        }
        }
    }
    if ($tagB != 1) {
        say "$line\tno tag";
    }
}
