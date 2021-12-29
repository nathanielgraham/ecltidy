#!/usr/bin/env perl 

use strict; 
use warnings;

my $indent_length = 3;
my $begin_block = qr/:=\s*(function|record|type|transform|module|service|interface|functionmacro|macro)\b/i;
my $end_block = qr/(end|endmacro)\s*[;$|\/{2}|:]/i;

my @preprocess;

while (my $line = <STDIN>) {
  chomp $line;
  next if $line =~ /^\s*$/;
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;
  $line =~ s/\s+/ /;
  $line =~ s/\t+/ /;
  push(@preprocess, $line);
}

my @begin_array;
my $total_paren_balance = 0; 

for my $i (0 .. $#preprocess) {
  my $line = $preprocess[$i];
  my $paren_balance = 0;
  my $open_parens = () = $line =~ /\(/g;
  my $closed_parens = () = $line =~ /\)/g;
  $paren_balance += $open_parens;
  $paren_balance -= $closed_parens;
  # indent_level, array_index
  push(@begin_array, [ $total_paren_balance, $i ]);
  $total_paren_balance += $paren_balance unless $line =~ /^\/\//; 
}

my $indent_level = 0;
for my $i (0 .. $#preprocess) {
  my $line = $preprocess[$i];
  if ($line =~ /^\/\//) {
    $begin_array[$i]->[0] += $indent_level;
  }
  elsif ($line =~ $begin_block) {
    $begin_array[$i]->[0] += $indent_level;
    $indent_level++;
  }
  elsif ($line =~ $end_block) {
    $indent_level--;
    $begin_array[$i]->[0] += $indent_level;
  }
  else {
    $begin_array[$i]->[0] += $indent_level;
  }
}

my $prev_line_comment = 0;
foreach my $line (@begin_array) {

  # add newline before code block
  if ($preprocess[ $line->[1] ] =~ /:=\s?(function|record|type|transform|module|service|functionmacro|macro|interface)\b/i) {
    print "\n" unless $prev_line_comment;
  }
  # add newline before comment block
  if ($preprocess[ $line->[1] ] =~ /^\s*\/\//) {
    print "\n" unless $prev_line_comment; 
    $prev_line_comment = 1;
  }
  else {
    $prev_line_comment = 0;
  }
  my $indent = ' ' x ($indent_length * $line->[0]);
  print $indent . $preprocess[ $line->[1] ] . "\n";
}

