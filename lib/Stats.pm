package Stats;

use strict;
use warnings;
use v5.18;

use Data::Printer;
use Path::Tiny;
use JSON::PP;

#our %config;
our %config = Setup::init_Config() unless keys %config; #this should be the instantiation

#%config = Setup::init_Config() unless keys %config;

# get_Stat_order #AAA
sub get_Stat_order {
    our %config;
#   warn 'input for get_Stat_order';
#   p @_;
    #die 'get_Stat_order';
    my %stats = %{shift @_};
#   p %stats;
    my %freq = %{$stats{freqs}};
#   p %freq;
    my %ic = %{$stats{ic}};
#   p %ic;
#   die 'Stat_order check';
    my @rtn;
    if ($config{stats_order} eq 'alpha') {
	@rtn = sort keys %freq;
    } else {
	@rtn = map {s/\d+\.//;chr($_)} sort {$b <=> $a} map {"$freq{$_}.".ord($_)} keys %freq;
    }
    return @rtn;
}
#ZZZ

## show_mono_stats_old #AAA
#sub show_mono_stats_old {
#    my %stats = (@_);
##   my %stats = %{shift @_};
#    my $order = shift;
#    my @order;
#    if ($order eq 'alpha') {
#	@order = sort keys %{$stats{freqs}};
#    } else { #for now this is only numerical
#	my %mono = %{$stats{freqs}};
#	@order = map {s/\d+\.//;chr($_)} sort {$b <=> $a} map {"$mono{$_}.".ord($_)} keys %mono;
#    }
#    my @rtn;
#    push @rtn, join(' ',map {sprintf "%2s", $_} @{$stats{freqs}}{@order});
#    push @rtn, join(' ',map {sprintf "%2s", $_} @order);
#    return wantarray ? @rtn : \@rtn;
#}
##ZZZ

# mono_Stats #AAA
sub mono_Stats {
#   my @txt = @{shift @_};
    my %counts;
    #p @_;
    #die 'mono_Stats check';
    for (map {s/\W//gr} @{shift @_}) {
	map {$counts{$_}++} split //, $_;
    }
    my %rtn = (freqs => {%counts}, ic => {_ic(%counts)});
    return wantarray ? %rtn : \%rtn;
}
#ZZZ

# _ic #AAA
sub _ic {
    my %stats = (@_);
    my $prod_sum = 0;
    my $total = 0;
    for (keys %stats) {
	$prod_sum += $stats{$_}*($stats{$_}-1);
	$total += $stats{$_};
    }
    my %rtn = (prod_sum => $prod_sum, total => $total, value => (26 * $prod_sum / ($total*($total-1))));
    return wantarray ? %rtn : \%rtn;
}
#ZZZ

1;
