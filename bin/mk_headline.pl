#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

# normal junk #AAA
use warnings;
use strict;
use v5.18;

use Path::Tiny;
use JSON::PP;

#ZZZ

my %msg;
if (1 == @ARGV) {
    my $key = $ARGV[0] =~ s/.jsn$//r;
    my $file = $key . '.jsn';
    while (1) {
        chomp(my $line = <STDIN>);
        my ($ndx, $txt) = split /[[:punct:]]/, $line, 2;
        $ndx =~ s/^\s*|\s*$//g;
        $txt =~ s/^\s*|\s*$//g;
        $msg{$key}{$ndx} = {state=>undef, msg=>[$txt], solved=>0};
        last if 5 <= keys %{$msg{$key}};
    }
    path($file)->spew(JSON::PP->new->pretty->utf8->encode({HDL=>\%msg}));
} else {
    my $jsn_in = JSON::PP->new->utf8;
    for my $file (grep {path($_)->is_file} @ARGV) {
        my $key = $file =~ s/.jsn$//r;
        my $thash = $jsn_in->decode(join(' ',path($file)->lines({chomp=>1})));
        @msg{keys %{$thash->{HDL}}} = values %{$thash->{HDL}};
    }
    say JSON::PP->new->pretty->utf8->encode({HDL=>\%msg});
}

#my $jpp_out = JSON::PP->new->pretty->utf8;
#path($file)->spew($jpp_out->encode({HDL=>\%msg}));

