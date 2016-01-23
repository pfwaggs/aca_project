package Menu;

use Data::Printer;
use strict;
use warnings;
use v5.18;
use experimental qw(smartmatch autoderef);

# an input line can consist of a command (quit, help, config, ...) or some
# specific things to do withing context of problem such as substitutions
# (cp:cp:cp...)  so the idea is to take the input line, parse it for commands
# first (and act on the commands, fi-itr with fifo coming later) then if no
# commands look for actions.

#AAA _pick_Input_parse
sub _pick_Input_parse {
    # the default value (null input) is to quit(-2) the current menu.  else it must be
    # some key found in the commands hash or a valid element in commands{all} list
    # failing that, we have no idea what was given so we return -1
    my %commands = %{shift @_};
    my @in = split /\s+/, shift//' ';
    push @in, 'quit' unless @in;
    my @_keys = @{$commands{all}};

    my @rtn = ();
    if (my ($command) = grep {$_ ~~ %commands} @in) {
	push @rtn, ref $commands{$command} eq 'ARRAY' ? @{$commands{$command}} : $commands{$command};
    } elsif (@_keys = grep {$_ ~~ @_keys} @in) {
	push @rtn, @_keys;
    } else {
	push @rtn, -1;
    }

    return wantarray ? @rtn : \@rtn;
}
#ZZZ

#AAA _pick_Data
sub _pick_Data {
    my $type = ref $_[0];
    my %rtn;
    if ($type eq 'HASH') {
	%rtn = %{shift @_};
    } else {
	my @data = $type eq 'ARRAY' ? @{shift @_} : (@_);
	my $ndx = 1;
	%rtn = map {$ndx++ => $_} @data;
	$rtn{keys} = [sort keys %rtn];
    }
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
	yes => '*',
	no  => ' ',
	help => ['no help available'],
    );
    %rtn = (%rtn, %{shift @_}) if ref $_[0] eq 'HASH';
    my $width = length($rtn{yes} lt $rtn{no} ? $rtn{no} : $rtn{yes});
    map {$_ = sprintf "%*1s", $width, $_} @rtn{qw/yes no/};
    $rtn{toggle} = $rtn{yes}^$rtn{no};
    return wantarray ? %rtn : \%rtn;
}
#ZZZ

#AAA pick
sub pick {
    # hash_ref, data
    my $type = ref $_[-1]; # this can be a HASH, ARRAY, or ''
    my $hash = $type eq 'HASH';
    my $tmp = pop @_ if $type;
    my %opts = _pick_Options(ref $_[0] eq 'HASH' ? shift : {});
    my %data = _pick_Data($type ? $tmp : (@_));

    my %cmnds = (quit => -2, help => -3);
    my $keys = $data{keys};
    my $max = $opts{max}//@{$data{keys}};

    my %_menu = map {$_ => {str=>$data{$_}, s=>$opts{no}}} @$keys;
    my $seq = 1;
    for (@{$opts{presets}}) {
	$_menu{$_}{s} ^= $opts{toggle};
	$_menu{$_}{order} = $seq++;
    }

    my $input;
    while (1) {
	system('clear') if $opts{clear};
	say $opts{header} if defined $opts{header};
	say join(' : ', sprintf("%2s", $_), @{$_menu{$_}}{qw{s str}}) for @$keys;
	print $opts{prompt};
	chomp ($input = <STDIN>);
	my ($first, @choices) = _pick_Input_parse({%cmnds, all=>$data{keys}}, $input);
	if ($first ~~ $keys) {
	    if ($opts{presets}) {
		for (@{$opts{presets}}) {
		    $_menu{$_}{s} ^= $opts{toggle};
		    $_menu{$_}{order} = $seq++;
		}
		$opts{presets} = ();
	    }
	    for ($first, @choices) {
		$_menu{$_}{s} ^= $opts{toggle};
		$_menu{$_}{order} = $seq++;
	    }
	} else {
	    say 'invalid input' if -1 == $first; # -1 is invalid input
	    last if -2 == $first; # -2 is quit
	    say for @{$opts{help}};
	    print '<paused>...';
	    my $dummy = <STDIN>;
	}
    } continue {
	last if (($max == grep {$_menu{$_}{s} eq $opts{yes}} keys %_menu) and ($input !~ /^all/i));
    }
    my @found = sort {$_menu{$b}{order} <=> $_menu{$a}{order}} grep {$_menu{$_}{s} eq $opts{yes}} keys %_menu;
    map {$_--} @found unless $hash;
    my @rtn = @found <= $max ? @found : @found[0..$max-1];
    return wantarray ? @rtn : \@rtn;
}
#ZZZ

# #AAA simple 
sub simple {
    my $str = shift;
    my $max = 1 + int log(@_)/log(10);
    my $ndx = 1;
    my @input = map {sprintf "%*s : %s", $max, $ndx++, $_} @_;
    my $rtn;
    while (1) {
 	system('clear');
	say for @input;
	print $str;
	chomp($rtn=<STDIN>);
	last if $rtn =~ /^\s*$/;
	next if $rtn =~ /\D/;
	last if (1 <= $rtn and $rtn <= @_);
    }
    return ($rtn ? $rtn-1 : -1);
}
#ZZZ

1;
