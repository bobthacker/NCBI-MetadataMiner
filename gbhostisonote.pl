#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use Bio::DB::Query::GenBank;
use Bio::DB::GenBank;
use Bio::SeqIO;
use Bio::Seq;
use Bio::Tools::Run::StandAloneBlast;
use Bio::SearchIO;
use Bio::Annotation::Collection;

# Search accession number and return isolation source and/or host

my $gb = new Bio::DB::GenBank;

my $acc_num = "";

# Read in file with accession number on seperate lines
print "ACC NUM\tDates\tHost\tIsolation Source\tNote\tDescription\n";
while(<>) {
    chomp;
    my $acc_num = $_;

    my $seqio = $gb->get_Stream_by_acc(["$acc_num"]);
    while (my $seq = $seqio->next_seq) {
        print $seq->display_id, "\t";
        print $seq->get_dates, "\t";
        for my $feat_obj($seq->get_SeqFeatures) {
            print $feat_obj->get_tag_values("host") if ($feat_obj->has_tag("host"));
        } 
        print "\t";
        for my $feat_obj($seq->get_SeqFeatures) {
            print $feat_obj->get_tag_values("isolation_source") if ($feat_obj->has_tag("isolation_source"));
        } print "\t";
        for my $feat_obj($seq->get_SeqFeatures) {
            print $feat_obj->get_tag_values("note") if ($feat_obj->has_tag("note"));
        } print "\t";
        print $seq->desc, "\n";
    }
    # Attempt to get Title
    #my $seq_obj = $seqio->next_seq;
    #my $anno_collection = $seqio->annotation;
    #for my $key( $anno_collection->get_all_annotation_keys) {
    #    my @annotations = $anno_collection->get_Annotations($key);
    #    for my $value (@annotations) {
    #        if ($value->tagname eq "reference") {
    #            print $value->title(), "\n";
    #        }
    #    }
    #}
}
