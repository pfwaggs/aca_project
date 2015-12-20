#!/usr/bin/env perl

# vim: ai si sw=4 sts=4 et fdc=4 fmr=AAA,ZZZ fdm=marker

use warnings;
use strict;
use v5.18;

use Path::Tiny;
use JSON::PP;

my $jpp_in = JSON::PP->new->utf8;
my %msgs = %{$jpp_in->decode(join(' ',path(shift)->lines({chomp=>1})))};
say lc substr($msgs{A}{1}{msg}[0]=~s/\W//gr,0,7).'1';
