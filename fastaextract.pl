#!/usr/bin/perl

use v5.10;
use warnings;
use strict;

my $write = 0; # 0 = no, 1 = yes

while(<>) {
    chomp;
    if ($_ =~ />/) {
        if ($_ =~ /16S/) {
            $write = 1;
        } else {
            $write = 0;
        }
    }
    if ($write == 1) {
        say $_;
    }
}
