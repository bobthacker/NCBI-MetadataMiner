#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Splits a fasta file into multiple parts

my $FILE_NAME = $ARGV[0];
my $num = $ARGV[1];
my $count = 0;
my $filecount = 0;

open(my $file, "<", "$FILE_NAME.fas") or die "No file name called $FILE_NAME";

my $outfas = undef;

while (<$file>) {
    chomp;
    if ($_ =~ />/) {
        $count++;
    }
    if ($count == 1) {
        if ($filecount > 0) {
            close($outfas);
        }
        open($outfas, ">>", "$FILE_NAME$filecount.fas");
    } elsif ($count == $num) {
        $filecount++;
        $count = 0;
    }
    say $outfas $_;
}

close($outfas);
close($file);

say "Files split";
