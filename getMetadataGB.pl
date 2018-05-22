#!/bin/perl -w

use Bio::Seq;
use Bio::SeqIO;

# getMetadataGB.pl
# get metadata information from GenBank format files

# usage: perl getMetadataGB.pl <input filename>
# note that the input file must be a .gb format file
# note that the BioPerl modules need to be installed
# see installation information here:

# need to add info above

my $inputFile = $ARGV[0];
chomp $inputFile;
open (INPUT, "< $inputFile") || die "\n can't open file: $! \n";
close INPUT; #debug open and close file

#debug log
open (LOG, ">log.metadata.txt") || die "\n can't open file: $! \n";

# set up the sequence stream
my $file = "<$inputFile";
my $format = "GenBank";
my $inseq = Bio::SeqIO->new(-file   => "$file",
                            -format => $format, );

# Use the 'next_seq' method of SeqIO to access individual $seq in the sequence stream

# get the accession number (AccNo) of each sequence and put them in an array @AccNos
my @AccNos;

# get the metadata for each sequence and store in an array of anonymous hashes
my @metaDataRecords;

while (my $seq = $inseq->next_seq) {
	# initialize all of the variables to capture
	my $accession = 'none';
	my $definitionLine = 'none';
	my $product = 'none'; # keep later only if /product="16S ribosomal RNA"
	my $organism = 'none';
	my $isolation_source = 'none'; # need to define in case not found
	my $db_xref = 'none';
	my $host = 'none';
	my $clone = 'none';
	my $isolate = 'none';
	my $strain = 'none';
	my $tissue_type = 'none';
	my $lat_lon = 'none';
	my $country = 'none';
	my $note = 'none'; # the notes are not always good
	my $lab_host = 'none';
	
    print $seq->accession_number."\n"; #debug show current accession number on screen
    $accession = $seq->accession_number;
    $definitionLine = $seq->desc;
    push @AccNos, $accession;
    
   	for my $feature_object ($seq->get_SeqFeatures) {    	
    	for my $tag ($feature_object->get_all_tags) {
    		for my $value ($feature_object->get_tag_values($tag)) {
    			if ($tag eq "organism") { $organism = $value; }
    			if ($tag eq "product") { $product = $value; }
    			if ($tag eq "isolation_source") { $isolation_source = $value; }
    			if ($tag eq "db_xref") { $db_xref = $value; }
    			if ($tag eq "host") { $host = $value; }
    			if ($tag eq "clone") { $clone = $value; }
    			if ($tag eq "isolate") { $isolate = $value; }
    			if ($tag eq "strain") { $strain = $value; }
    			if ($tag eq "tissue_type") { $tissue_type = $value; }
    			if ($tag eq "lat_lon") { $lat_lon = $value; }
    			if ($tag eq "country") { $country = $value; }
    			if ($tag eq "note") { $note = $value; }
    			if ($tag eq "lab_host") { $lab_host = $value; }
    		}
    	}
    }
    my $hashref = { accession => $accession,
    				definitionLine => $definitionLine,
					organism => $organism,
					product => $product,
					isolation_source => $isolation_source,
					db_xref => $db_xref,
					host => $host,
					clone => $clone,
					isolate => $isolate,
					strain => $strain,
					tissue_type => $tissue_type,
					lat_lon => $lat_lon,
					country => $country,
					note => $note,
					lab_host => $lab_host,
					};
	push @metaDataRecords, $hashref;
	print LOG "$accession"."\n"; #debug
    my $recordCount = scalar @metaDataRecords; # show some sort of progress
    if (($recordCount % 50) == 0) { 
		print $recordCount."\n";
	}
}

#now need to output the @metaDataRecords	
my $metaDataFile = $inputFile.".metadata.txt";
open (OUTPUT, "> $metaDataFile") || die "\n can't open file: $! \n";
select (OUTPUT); # to save typing OUTPUT later
	# first print headers
	print "accession"."\t"."definitionLine"."\t"."organism"."\t"."product"."\t"."isolation_source"."\t"."db_xref"."\t"."host";
	print "\t"."clone"."\t"."isolate"."\t"."strain"."\t"."tissue_type"."\t"."lat_lon";
	print "\t"."country"."\t"."note"."\t"."lab_host"."\n"; 
	foreach my $hashref (@metaDataRecords) {
		my %record = %$hashref;
		print $record{accession}."\t".$record{definitionLine}."\t".$record{organism};
		print "\t".$record{product}."\t".$record{isolation_source}."\t".$record{db_xref};
		print "\t".$record{host}."\t".$record{clone}."\t".$record{isolate}."\t".$record{strain};
		print "\t".$record{tissue_type}."\t".$record{lat_lon}."\t".$record{country};
		print "\t".$record{note}."\t".$record{lab_host}."\n";
	}
select STDOUT; #switch back to screen output
close OUTPUT;

print "\nNumber Found: ".scalar @AccNos."\n";
print LOG "\nNumber Found: ".scalar @AccNos."\n";
close LOG;
print "DONE\n";