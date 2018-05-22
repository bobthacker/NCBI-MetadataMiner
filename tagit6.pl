#!/usr/bin/perl

use strict;
use warnings;

# ------------------------------------------------- #
# - Author:         Jun Yu Jacinta Cai & Dr. Puri Bangalore & Dr. Robert Thacker
# - Last modified:  22 May 2018
# - Version:        5.0.lb
# - CS Research with Dr. Thacker & Dr. Bangalore
# - Description: Tags line with corresponding list
#                provided by the user 
# - Usage: perl tagit5.pl inputFileName tagListFileName outputFileName
#
#  Note: _lb linebreaks fixed? for legacy mac users          
# ------------------------------------------------- #

my %tagList;
my $inputfile;

# get the input metadata file
my $inputFileName = $ARGV[0];
if (! open INPUT, "<$inputFileName") {
	warn "Could not open input file";
	exit;
}

#get the tag list file
my $tagListFileName = $ARGV[1];
if (! open TAGLIST, "<$tagListFileName") {
	warn "Could not open tag list file not found";
	exit;
}

#get the output file name
my $outputFileName = $ARGV[2];
if (! open OUTPUT, ">$outputFileName") {
	warn "Could not open output file";
	exit;
}

#read the tag list file
#must have format like
#parent
#	parent
#	child1

my $tagline; #will contain initial read, could be multiple lines if legacy Mac
my @taglines; #will hold all of lines in the file
{local $/=undef; #temporarily set line break as undefined for a local block
while($tagline = <TAGLIST>) {
	my @lines = split /\r\n?|\n/, $tagline;
	push @taglines, @lines;
	}
} #end the local block
#note: this approach reads the entire file into memory; might fail for big files

#populate %tagList hash
my $parent = ""; #initialize parent tag
foreach my $tag (@taglines) {
    chomp($tag);
    $tag =~ s/\r//; #just in case, also remove CRs
    $tag = lc($tag); # make tags lowercase
    if ($tag =~ /\t(\w+)/) {
        # If the line has a tab, then push the value
        # into the reference array within the correct hash key
        # these are the "children" terms that invoke the "parent" tag
        push @{$tagList{$parent}}, $1;
    } else {
        # If the line doesn't have a tab, then make a new
        # key with an empty reference array
        $tagList{$tag} = [];
        $parent = $tag;
    }
}

#read the metadata file
#first line should contain headers
#note: this approach reads the entire file into memory; might fail for big files

my $metaline; #will contain initial read, could be multiple lines if legacy Mac
my @metalines; #will hold all of the lines in the file
{local $/=undef; #temporarily set line break as undefined for a local block
while($metaline = <INPUT>) {
	my @lines = split /\r\n?|\n/, $metaline;
	push @metalines, @lines;
	}
} #end the local block

my %tagHash; #set up tagHash to count tags
my $noTagCount = 0; #count number without tags for later use
my @untaggedRecords; #set up @untaggedRecords as an array of hash references
my @taggedRecords; #set up @taggedRecords as an array of hash references

my $counter = 0;
foreach my $line (@metalines) {
#step through line by line of input file; the lines are in the array @metalines
    chomp($line);
    $line =~ s/\r//; #just in case, also remove CRs
    if ($counter == 0) {
    	print OUTPUT "$line"."\t"."tag"."\n"; #adds header to output file
    	$counter = 1;
    } else {    
    	my $tagB = 0; #track if tag added or not
   		while(my($k, $v) = each %tagList) {
        # Steps through the key / values of the hash
        	if ($tagB == 1) {}
        	else {
       	 		foreach (@$v) {
            	# looks at each value of the hash
            		if ($tagB == 1) {} #move along if there is already a match - only the first match in tag list counts
         			else {
           				if(lc($line) =~ /\b$_\b/) { #added word boundaries - yes, this helps
              				# searches the input file line and see if it
               				# contains the value of the hash
              				# If it does have it, then print out the corresponding
               				# key with the line (to tag the line)
               				print OUTPUT "$line"."\t"."$k"."\n";
               				$tagHash{$k} += 1;
               				$tagB = 1;
               				# make a hash for output of taggedRecords only
               				my @elements = split ('\t', $line);
        					my $hashref = { accession => $elements[0],
    							definitionLine => $elements[1],
								organism => $elements[2],
								product => $elements[3],
								isolation_source => $elements[4],
								db_xref => $elements[5],
								host => $elements[6],
								clone => $elements[7],
								isolate => $elements[8],
								strain => $elements[9],
								tissue_type => $elements[10],
								lat_lon => $elements[11],
								country => $elements[12],
								note => $elements[13],
								lab_host => $elements[14],
								tag => $k,
							};
							push @taggedRecords, $hashref;        
               			} 
            		}
         		}
        	}
    	}
    	if ($tagB == 0) { #if nothing has matched, need to output "no tag"
        	print OUTPUT "$line"."\t"."no tag"."\n";
        	$noTagCount += 1;
        	my @elements = split ('\t', $line);
        	my $hashref = { accession => $elements[0],
    				definitionLine => $elements[1],
					organism => $elements[2],
					product => $elements[3],
					isolation_source => $elements[4],
					db_xref => $elements[5],
					host => $elements[6],
					clone => $elements[7],
					isolate => $elements[8],
					strain => $elements[9],
					tissue_type => $elements[10],
					lat_lon => $elements[11],
					country => $elements[12],
					note => $elements[13],
					lab_host => $elements[14],
					};
			push @untaggedRecords, $hashref;        	      	
    	}
    }
}
close INPUT;

#show the user the counts of how many of each tag exist
print "\n\nNumber of each tag:\n";
sortedPrint (%tagHash);
print "\nNumber of records without tags: ".$noTagCount."\n";
#add this information to the output file
select (OUTPUT);
print "\n\nNumber of each tag:\n";
sortedPrint (%tagHash);
print "\nNumber of records without tags: ".$noTagCount."\n";
select (STDOUT);

#show the user the next 5 records without tags
my $index = 4;
if ($noTagCount > 0) {
	if ($noTagCount < 5) { $index = $noTagCount; }
	print "\nNext records that need tags:\n";
	print OUTPUT "\nNext records that need tags:\n";
	foreach my $i (0..$index) {
		my $hashref = $untaggedRecords[$i];
		my %record = %$hashref;
		print $record{accession}."\t".$record{definitionLine}."\t".$record{organism};
		print "\t".$record{product}."\t".$record{isolation_source}."\t".$record{db_xref};
		print "\t".$record{host}."\t".$record{clone}."\t".$record{isolate}."\t".$record{strain};
		print "\t".$record{tissue_type}."\t".$record{lat_lon}."\t".$record{country};
		print "\t".$record{note}."\t".$record{lab_host}."\n";
		select (OUTPUT);
		print $record{accession}."\t".$record{definitionLine}."\t".$record{organism};
		print "\t".$record{product}."\t".$record{isolation_source}."\t".$record{db_xref};
		print "\t".$record{host}."\t".$record{clone}."\t".$record{isolate}."\t".$record{strain};
		print "\t".$record{tissue_type}."\t".$record{lat_lon}."\t".$record{country};
		print "\t".$record{note}."\t".$record{lab_host}."\n";
		select (STDOUT);
	}
}
close OUTPUT;
		
#ask if user wants to export CSV of tagged records for Arbor or R
print "\n\nExport .csv file of tagged records for Arbor or R? (y or n): ";
chomp(my $response = <STDIN>);
if ($response eq "y") {
	print "\nEnter filename: ";
	chomp(my $exportFileName = <STDIN>);
	if (! open EXPORT, ">$exportFileName") {
	warn "Could not open export file";
	exit;
	}
	select (EXPORT);
	# first print headers # CSV # only really need name on phylogeny and tag
	print "name".","."accession".","."definitionLine".","."organism".","."product";
	print ","."isolation_source".","."db_xref".","."host";
	print ","."clone".","."isolate".","."strain".","."tissue_type".","."lat_lon";
	print ","."country".","."note".","."lab_host".","."tag"."\n";
	foreach my $hashref (@taggedRecords) {
		my %record = %$hashref;
		my $name = $record{accession}."_".$record{organism};
		$name =~ s/ /_/g; #replace spaces with underscores in the name
		$name =~ s/['".-]//g; #remove quotes and periods and hyphens, because the phylogeny workflow removes these
		print $name.",".$record{accession}.",".$record{definitionLine}.",".$record{organism};
		print ",".$record{product}.",".$record{isolation_source}.",".$record{db_xref};
		print ",".$record{host}.",".$record{clone}.",".$record{isolate}.",".$record{strain};
		print ",".$record{tissue_type}.",".$record{lat_lon}.",".$record{country};
		print ",".$record{note}.",".$record{lab_host}.",".$record{tag}."\n";
	} 
	select STDOUT;
}
close EXPORT;	

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
