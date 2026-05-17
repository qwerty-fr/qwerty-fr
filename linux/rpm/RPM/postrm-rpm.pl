#!/usr/bin/perl

use strict;
use warnings;

my ($rpm_mode) = @ARGV;
my $mode = (defined $rpm_mode && $rpm_mode == 1) ? "upgrade" : "remove";

@ARGV = ($mode);

require "/usr/libexec/xkb-qwerty-fr/postrm";
