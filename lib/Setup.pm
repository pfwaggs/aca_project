package Setup;

# preamble AAA
use strict;
use warnings;
use v5.18;
use experimental qw(smartmatch);

use Path::Tiny;
use JSON::PP;
our $json_pp = JSON::PP->new->utf8;
use Data::Printer;

our @ETC;
BEGIN {
    our @ETC;
    @ETC = map {"$_"} grep {path($_)->is_dir} map {path("$_/etc")->realpath} ('.', '..');
}

use Menu;
use Utilities;

my $nl = "\n";

# ZZZ

# init_Config AAA
sub init_Config {
    my $file = shift // "~/.aca_config.jsn";
    my %rtn;
    if (path($file)->is_file) {
	%rtn = Utilities::read_Json($file);
    } else {
	my @ETC = map {"$_"} grep {path($_)->is_dir} map {path("$_/etc")->realpath} ('.', '..');
	my ($init_config_file) = grep {path($_)->is_file} map {"$_/aca_config.jsn"} @ETC; # we want to create default config files for projects
	if (defined $init_config_file) {
	    my %init_config = Utilities::read_Json($init_config_file);
	    %rtn = map {$_ => $init_config{$_}[0]} keys %init_config;
	    $rtn{template} = $init_config_file;
	    $rtn{location} = path("~/.aca_config.jsn")->realpath->stringify;
	    Utilities::write_Json(\%rtn, $rtn{location});
	} else {
	    warn 'no default config file found. please configure one.'.$nl;
	}
    }
    return %rtn;
}
# ZZZ

# show_Config AAA
sub show_Config {
    my %config = %{shift @_};
    my @order = @_ ? @{shift @_} : sort keys %config;
    my @showme;
    push @showme, [$_, $config{$_}//'empty'] for @order;
    @showme = Utilities::mo2(\@showme);
    say join(' : ', @$_) for @showme;
}
# ZZZ

# sync_Config AAA
sub sync_Config {
    my %config_current = %{shift @_};
    my %config_template = Utilities::read_Json($config_current{template});
    my @new_keys = grep {! ($_ ~~ %config_current)} keys %config_template;
    my $str = @new_keys ? 'changed' : 'unchanged';
    warn "config keys $str from template".$nl;
    for (@new_keys) {
	$config_current{$_} = $config_template{$_}[0];
    }
    return %config_current;
}
# ZZZ

# modify_Config AAA
sub modify_Config {
    my %config_current = %{shift @_};
    my %config_template = Utilities::read_Json($config_current{template});
    while (1) {
	my @order = sort grep { $_ ne 'template'} keys %config_current;
	my $key = Menu::simple('select key to change(#)? ',@order);
	-1 == $key ? last : ($key = $order[$key]);
	{
	    my @options = @{$config_template{$key}};
	    my $val = Menu::simple('select a value: ', @options);
	    -1 == $val ? redo : ($config_current{$key} = $config_template{$key}[$val]);
	}
    }
    return %config_current;
}
# ZZZ

1;
