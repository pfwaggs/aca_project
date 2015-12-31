package Menu;

use Data::Printer;
use strict;
use warnings;
use v5.18;

sub _parse_choice {
    my ($max, $in) = @_;
    my %rtn = (msg => undef, selections => undef);
    if ($in =~ /^quit/i) {
	$rtn{msg} = 0;
    } elsif ($in =~ /^help/i) {
	$rtn{msg} = 1;
    } elsif ($in =~ /^all/i) {
	$rtn{selections} = [(1..$max)];
    } elsif ($in =~ /\d/) {
	push @{$rtn{selections}}, $1 while ($in =~ /\b(\d+)\b/g);
    } else {
	$rtn{msg} = -1;
    }
    $rtn{selections} = [map {$_-1} grep {0<$_ and $_ <= $max} @{$rtn{selections}}];
    return wantarray ? %rtn : \%rtn;
}

sub Pick {
    # input options :
    #	clear screen: (1)/0
    #	max: -1/(1)/n/n+
    #	header: undef
    #	prompt: pick lines:
    #	preset: undef
    #	help: list of help lines
    #
    # input menu :
    # input array < \@ or @

    my %opts = (clear => 1, max => 1, header => undef, prompt => 'pick lines: ', presets => [], help => [],);
    %opts = (%opts, %{shift @_}) if ref $_[0] eq 'HASH';
    my @data = ref $_[0] eq 'ARRAY' ? @{shift @_} : @_;
    my $max = $opts{max} == -1 ? @data : $opts{max};

    my $picked = '*';
    my $toggle = $picked^' ';
    my @choices = (' ') x @data;
    my $seq = 1;

    my @_menu = map {{str=>$data[$_], s=>' ', x=>1+$_}} keys @data;
    for (@{$opts{presets}}) {
	$_menu[$_]{s} ^= $toggle;
	$_menu[$_]{order} = $seq++;
    }

    my $input;
    while (1) {
	system('clear') if $opts{clear};
	say $opts{header} if defined $opts{header};
	say join(' : ', @{$_}{qw{s x str}}) for @_menu;
	print $opts{prompt};
	chomp ($input = <STDIN>);
	my %action = _parse_choice($max, $input);
	if (defined $action{msg}) {
	    say 'invalid input' if -1 == $action{msg};
	    last if 0 == $action{msg};
	    say for @{$opts{help}};
	    my $dummy = <STDIN>;
	}
	for (@{$action{selections}}) {
	    $_menu[$_]{s} ^= $toggle;
	    $_menu[$_]{order} = $seq++;
	}
    } continue {
	last if (($max == grep {$_->{s} eq $picked} @_menu) and ($input !~ /^all/i));
    }
    my @found = sort {$_menu[$a]{order} <=> $_menu[$b]{order}} grep {$_menu[$_]{s} eq $picked} keys @_menu;
    my @rtn = @found <= $max ? @found : @found[0..$max-1];
    return wantarray ? @rtn : \@rtn;
}

1;
