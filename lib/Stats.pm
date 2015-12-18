package Stats;

use strict;
use warnings;
use v5.18;

use Data::Printer;
use Path::Tiny;
use JSON::PP;

# show_stats #AAA
sub show_stats {
    my %stats = %{shift @_};
    my $key = shift;
    my @order = @{$stats{$key}};
    say join(' ',map {sprintf "%2s", $_} @{$stats{freqs}}{@order});
    say join(' ',map {sprintf "%2s", $_} @order);
}
#ZZZ

# mono_counts #AAA
sub mono_counts {
    my @txt = @{shift @_};
    my %counts;
    for (map {s/\W//gr} @txt) {
	map {$counts{$_}++} split //, $_;
    }
    my @alpha = sort keys %counts;
    my @number = map {s/\d+\.//;chr($_)} sort {$b <=> $a} map {"$counts{$_}.".ord($_)} keys %counts;
    my %rtn = (freqs => {%counts}, alpha => [@alpha], number => [@number]);
    return wantarray ? %rtn : \%rtn;
}
#ZZZ

1;
