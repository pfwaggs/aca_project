package Ciphers;

use strict;
use warnings;
use v5.18;

use Data::Printer;
use Path::Tiny;
use JSON::PP;

use Stats;

# parse_action #AAA
sub parse_action {
    my ($action, $show_stats, $stat_key, $href) = @_;
    my $my_action   = 1 - ($action =~ s/quit//);
    if ($action =~ s/(number|alpha)//) {
	$stat_key = $1;
    }
    if ($action =~ s/stats//) {
	$show_stats = 1 - $show_stats;
    }
    $action =~ s/^\s+|\s+$//g; # remove leading/trailing spaces
    if ($action) {
	for (split /:/, $action) {
	    next unless length $_ le 2;
	    my ($f, $s) = split //, uc $_;
	    $href->{$f} = $s =~ /\w/ ? $s : ' ';
	}
    }
    return ($my_action, $show_stats, $stat_key, $href);
}
#ZZZ

# aristocrat #AAA
sub aristocrat {
    my %data = %{shift @_};
    $data{state} = {} unless defined $data{state};
    p %data;

    my %stats = Stats::mono_counts($data{msg});

    my $stat_key = 'alpha';
    my $show_stats = 1;
    my $action = 1;
    while ($action) {
	system('clear');
        my $first = join('', keys $data{state});
        my $second = lc join('', values $data{state});
        my $SECOND = uc $second;
	$show_stats ? Stats::show_stats(\%stats, $stat_key) : say join(' ',map {sprintf "%2s", $_} @{$stats{$stat_key}});
	my $ALPHA = join(' ',map {sprintf "%2s", $_} @{$stats{$stat_key}});
	eval "\$ALPHA =~ tr/$first/$second/" if $first;
	$ALPHA =~ s/[[:upper:]]/ /g;
	eval "\$ALPHA =~ tr/$second/$SECOND/" if $SECOND;
	say $ALPHA;
	say '';
        for (@{$data{msg}}) {
            say my $line = $_;
            eval "\$line =~ tr/$first/$second/" if $first;
            $line =~ s/[[:upper:]]/ /g;
            eval "\$line =~ tr/$second/$SECOND/" if $SECOND;
            say "$line\n";
        }
        print "cipher/plain pair? ";
        chomp($action=<STDIN>);
	($action, $show_stats, $stat_key, $data{state}) = parse_action($action, $show_stats, $stat_key, $data{state}); # we overwrite action, stat_key and data{state} based on action
    }
    return wantarray ? %data : \%data;
}
#ZZZ

1;
