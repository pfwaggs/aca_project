package Menu;

use Data::Printer;
use strict;
use warnings;
use v5.18;
use experimental qw(smartmatch autoderef);

#AAA _pick_Input_parse
sub _pick_Input_parse {
    my @in = split /\s/, shift =~ s/^$/quit/r;
    my @keys = @{shift @_};
    my %parse = %{shift @_};
    my ($parsed) = grep {$_ ~~ %parse} @in;

    my @rtn = ();
    if ($parsed) {
	push @rtn, ref $parse{$parsed} eq 'ARRAY' ? @{$parse{$parsed}} : $parse{$parsed};
    } else {
	push @rtn, grep {$_ ~~ $parse{all}} @in;
    }
    push @rtn, -2 unless @rtn;

    return wantarray ? @rtn : \@rtn;
}
#ZZZ

#AAA _pick_Data
sub _pick_Data {
    my @data = ref $_[0] eq 'ARRAY' ?  @{shift @_} : (@_);
    my $ndx = 1;
    my %rtn = map {$ndx++ => $_} @data;
    $rtn{keys} = [sort keys %rtn];
    return %rtn;
}
#ZZZ

#AAA _pick_Options
sub _pick_Options {
    # {config params}, {%data, keys=>[], (help=>[])}

    my %rtn = (
	header  => undef,
	prompt  => 'pick lines: ',
	clear   => 1,
	max     => 1,
	presets => [],
	cmnds   => {quit => 0, help => -1},
    );
    %rtn = (%rtn, %{shift @_}) if ref $_[0] eq 'HASH';
    return %rtn;
}
#ZZZ

#AAA pick
sub pick {
    # hash_ref, data
    my $type = ref $_[-1]; # this can be a HASH, ARRAY, or ''
    my %data = $type ? _pick_Data(pop @_) : ();
    my %opts = _pick_Options(ref $_[0] eq 'HASH' ? shift : {});
    %data = _pick_Data(@_) unless keys %data;
    my $hash = $type eq 'HASH';

    $opts{cmnds}{all} = $data{keys};

    my $keys = $data{keys};
    my $max = $opts{max}//@{$data{keys}};

    my $picked = '*';
    my $toggle = $picked^' ';
    my $seq = 1;

    my %_menu = map {$_ => {str=>$data{$_}, s=>' '}} @$keys;
    for (@{$opts{presets}}) {
	$_menu{$_}{s} ^= $toggle;
	$_menu{$_}{order} = $seq++;
    }

    my $input;
    while (1) {
	system('clear') if $opts{clear};
	say $opts{header} if defined $opts{header};

	say join(' : ', sprintf("%2s", $_), @{$_menu{$_}}{qw{s str}}) for @$keys;

	print $opts{prompt};
	chomp ($input = <STDIN>);

	my ($first, @choices) = _pick_Input_parse($input, $keys, $opts{cmnds});

	if ($first ~~ $keys) {
	    if ($opts{presets}) {
		for (@{$opts{presets}}) {
		    $_menu{$_}{s} ^= $toggle;
		    $_menu{$_}{order} = $seq++;
		}
		$opts{presets} = ();
	    }
	    for ($first, @choices) {
		$_menu{$_}{s} ^= $toggle;
		$_menu{$_}{order} = $seq++;
	    }
	} else {
	    say 'invalid input' if -2 == $first;
	    last unless $first;
	    say for @{$opts{help}};
	    print '<paused>...';
	    my $dummy = <STDIN>;
	}
    } continue {
	last if (($max == grep {$_menu{$_}{s} eq $picked} keys %_menu) and ($input !~ /^all/i));
    }
    my @found = sort {$_menu{$b}{order} <=> $_menu{$a}{order}} grep {$_menu{$_}{s} eq $picked} keys %_menu;
    map {$_--} @found unless $hash;
    my @rtn = @found <= $max ? @found : @found[0..$max-1];
    return wantarray ? @rtn : \@rtn;
}
#ZZZ

1;
