#!/usr/bin/perl -w
use strict;

# countHostsAndSources.pl
# how many genbank types of Hosts and Isolation Sources are in my Bacteroidetes inputs?

#usage: perl countHostsAndSources.pl inputFile

#for each line of text in $_: 1)preprocess, 2)count, 3)store counts

my $inputFile = $ARGV[0];
chomp $inputFile;
open (INPUT, "< $inputFile") || die "\n can't open file: $! \n";

my %hostHash;
my %isolationSourceHash;
				
while (<INPUT>) {	
	if ($_ =~ /host="([A-Za-z0-9_.\s]+)"/) {
			$hostHash{$1} += 1;
	}
	if ($_ =~ /isolation_source="([A-Za-z0-9_.\s]+)"/) {
			$isolationSourceHash{$1} += 1;
	}
}													#close while

#want to print from most frequent to least frequent; thus need to sort keys to both hashes
print "GenBank Host Frequency\n";
sortedPrint (%hostHash);
print "\nGenBank Isolation Source Frequency\n";
sortedPrint (%isolationSourceHash);

print "\nDo you want to print results to file? y or n ";
chomp ( my $response = <STDIN> );
if ($response eq 'y') {
	print "\nEnter output file name: ";
	chomp (my $outputFile = <STDIN> );
	open (OUTPUT, "> $outputFile") || die "\n can't open file: $! \n";
	#my $hashRefs = [\%hostHash, \%isolationSourceHash];
	select (OUTPUT);
	print "GenBank Host Frequency\n";
	sortedPrint (%hostHash);
	print "\nGenBank Isolation Source Frequency\n";
	sortedPrint (%isolationSourceHash);
	#foreach my $hash(@$hashRefs) {
	#	my %derefHash = %$hash;
	#	sortedPrint (%derefHash);
	#}
#	foreach my $hash (@$hashRefs) {
#		my %derefHash = %$hash;
#		my @sortedKeys = sort keys %derefHash;
#		foreach my $key (@sortedKeys) { 
		#foreach my $key (keys %hash) { # to do without sorting
#			print OUTPUT "$key: $derefHash{$key}\n";
#		}
#	}
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