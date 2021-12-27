#!/usr/bin/env perl 

use strict; 
use warnings;

my $indent_length = 3;

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
for my $i (0 .. $#preprocess) {
  # indent_level, array_index
  push(@begin_array, [ 0, $i ]);
}

sub calc_indent {
  my ($aref, $begin_regex, $end_regex) = @_;
  my $indent_level = 0;
  my @last_match = ();
  for my $i (0 .. $#preprocess) { 
    my $line = $preprocess[$i];
    my ($match) = $line =~ $begin_regex;
    my ($match_end) = $line =~ $end_regex;
    if ($match && !$match_end) {
       push(@last_match, $match);
       $aref->[$i]->[0] += $indent_level;
       $indent_level++;
    }
    elsif (@last_match && $match_end) {
       my $has_endblock = $end_regex =~ /end/i;
       $indent_level-- if $has_endblock;
       $aref->[$i]->[0] += $indent_level;
       $indent_level-- unless $has_endblock;
       pop(@last_match);
    }
    else {
      $aref->[$i]->[0] += $indent_level;
    }
  }
  return $aref;
}

my $first_pass = &calc_indent( \@begin_array, qr/:=\s?(function|record|type|transform|module|service)\b/i, qr/(end)\s*[;$|\/{2}|:]/i );
my $second_pass = &calc_indent( $first_pass, qr/:=\s?(map|case|dataset|enum|project)\b/i, qr/\)\s*[;$|\/{2}]/i ) ;
my $third_pass = &calc_indent( $second_pass, qr/:=\s?(functionmacro|macro)\b/i, qr/endmacro\s*[;$|:]/i ) ;

my $prev_line_comment = 0;
foreach my $line (@{$third_pass}) {

  # add newline before code block
  if ($preprocess[ $line->[1] ] =~ /:=\s?(function|record|type|transform|module|service|functionmacro|macro)\b/i) {
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

