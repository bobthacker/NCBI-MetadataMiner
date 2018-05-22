#!/usr/bin/perl -w
use strict;

# countTags_GB.pl
# how many tags like "/host" are in a GenBank format file?

#usage: perl countTags_GB.pl inputFile

my $inputFile = $ARGV[0];
chomp $inputFile;
open (INPUT, "< $inputFile") || die "\n can't open file: $! \n";

my %tagHash;
				
while (<INPUT>) {
	if ($_ =~ /(\/[A-Za-z0-9_.\s]+)="/ ) {
			$tagHash{$1} += 1 ;
	}
}													#close while

#want to print from most frequent to least frequent; thus need to sort keys to both hashes
print "Tag Frequency\n";
sortedPrint (%tagHash);

print "\nDo you want to print results to file? y or n ";
chomp ( my $response = <STDIN> );
if ($response eq 'y') {
	print "\nEnter output file name: ";
	chomp (my $outputFile = <STDIN> );
	open (OUTPUT, "> $outputFile") || die "\n can't open file: $! \n";
	
	select (OUTPUT);
	print "Tag Frequency\n";
	sortedPrint (%tagHash);
}
close INPUT;
close OUTPUT;

sub sortedPrint {
	my %hash = @_;
	my @sortedKeys = sort {
		$hash{$b} <=> $hash{$a} 		#high to low value sort of keys
		or $a cmp $b						#if tied, alphabetical sort of keys
	} keys %hash;
	foreach my $key (@sortedKeys) {
		print "  $key: $hash{$key}\n";
	}
}