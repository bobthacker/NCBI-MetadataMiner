#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

my %metaHash; # Hash table for the meta data
my $file_in_meta;
my $file_out_meta;
my $file_in_tree;
my $file_out_tree;
my $lineCount = 1;

# Read in tags for hash table
open ($file_in_meta, "<", "sponge_meta.txt") or die "Could not open sponge_meta.txt";
while(<$file_in_meta>) {
    # Stores the accesion number / tags in a hash table for quick lookup
    chomp;
    if ($_ =~ /(\w+)\t(\w+)/) {
        # $1 = ACC Num
        # $2 = Tag value
        # $3 = Common Name, once have
        $metaHash{$1} = $2;
    } 
}

# Test to see if the keys are there
# my @names = keys %metaHash;
# print join(", ", @names);

# Read in the tree file
open ($file_in_tree, "<", "sponge_tree.txt") or die "Could not open sponge_tree.txt";
open ($file_out_tree, ">", "sponge_tree.js");
open ($file_out_meta, ">", "sponge_meta.js");
while (<$file_in_tree>) {
    chomp;
        while ($_ =~ /(.+?)([ABCDEFGHIJKLMNOPQRSTUVWXYZ]+\d+):/g) {
            # $1 = left overs
            # $2 = ACC Numbers
            print $file_out_tree "$1" . "$2" . "[$lineCount]:";
            $lineCount++;
            # Insert into meta data file look for that match
            if (exists $metaHash{$2}) {
            	 my $temp = $2;
                if ($metaHash{$2} =~ /sponge/) {
                    # If the accession number tag is a sponge, then use "EX" for the color
                    print $file_out_meta "[\"" . "$temp" . "\",\"EX\"," . "\"$metaHash{$temp}" . "\"],\n"; 
                } else {
                	# Else, use "NE" for not sponge 
                    print $file_out_meta "[\"" . "$temp" . "\",\"NE\"," . "\"$metaHash{$temp}" . "\"],\n"; 
                }
            }
        }
}

close $file_in_tree;
close $file_out_tree;
close $file_in_meta;
close $file_out_meta;
