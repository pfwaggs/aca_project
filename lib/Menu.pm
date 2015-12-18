package Menu;

use Data::Printer;
use strict;
use warnings;
use v5.18;

sub Pick {
    # input options :
    #	clear screen: (1)/0
    #	max: -1/(1)/n/n+
    #	header: undef
    #	prompt: pick lines:
    #	preset: undef
    #
    # input menu :
    # input array < \@ or @

    my %opts = (clear=>1, max=>1, header=>undef, prompt=>'pick lines: ',presets=>[],);
    %opts = (%opts, %{shift @_}) if ref $_[0] eq 'HASH';
    my @data = ref $_[0] eq 'ARRAY' ? @{shift @_} : @_;
    my $max = $opts{max} == -1 ? @data : $opts{max};

    my $picked = '*';
    my $select = $picked^' ';
    my @choices = (' ') x @data;
    my $seq = 1;

    my @_menu = map {{str=>$data[$_], s=>' ', x=>1+$_}} keys @data;
    for (@{$opts{presets}}) {
	$_menu[$_]{s} ^= $select;
	$_menu[$_]{order} = $seq++;
    }

    my $picks;
    while (1) {
	system('clear') if $opts{clear};
	say $opts{header} if defined $opts{header};
	say join(' : ', @{$_}{qw{s x str}}) for @_menu;
	print $opts{prompt};
	chomp ($picks = <STDIN>);
	last if $picks =~ /^(?i)q/;
	for (map {$_-1} $picks =~ /^(?i)a/ ? (1..$max) : split /\D/,$picks) {
	    $_menu[$_]{s} ^= $select;
	    $_menu[$_]{order} = $seq++;
	}
    } continue {
	last if ($max == grep {$_->{s} eq $picked} @_menu) and ($picks !~ /^(?i)a/);
    }
    my @found = sort {$_menu[$a]{order} <=> $_menu[$b]{order}} grep {$_menu[$_]{s} eq $picked} keys @_menu;
    my @rtn = @found <= $max ? @found : @found[0..$max-1];
    return wantarray ? @rtn : \@rtn;
}

1;
