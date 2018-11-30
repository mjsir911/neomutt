#!/usr/bin/perl -w

use YAML;
use strict;
use warnings;

my @MAP;

my $xml = shift @ARGV;

while (<>) {
	if (/Commands\[\]/) {
		read_n_parse_commands()
	}
}

sub read_n_parse_commands {
	while (my $out = <>) {
		my ($cmd, $docopt) = $out =~ /^\s*{\s*"(\S+?)",\s*(?:\S+?),\s.*\s*},(?:.+?)?(?:\/\*\s+(.+?)\s+\*\/)?/;
		if (not $cmd) {
			next;
		}

		my $index = defined $MAP[0] ? @MAP : 0;
		%{ $MAP[$index] } =  (command => $cmd, arguments => $docopt);

		if ($out =~ /;$/) {
			last;
		}
	}
}

print Dump(\@MAP);
