#!/usr/bin/perl 

use strict;
use warnings;
use diagnostics;

#Names
my @names = qw(array_a array_b array_c array_d);

#Open file with LaTeX data
my $latexfile = shift @ARGV
    or die "No input file.\n";
open my $tables, '<', $latexfile
    or die "Cannot open '$latexfile' for writing: $!";

#Open file that will use Octave
my $octave_file = 'oct.m';
open my $octave, '>>', $octave_file
    or die "Cannot open '$octave_file' for writing: $!";

# Referencias usadas para almacenar la información
my $data = [
    my $data_a = [],
    my $data_b = [],
    my $data_c = [],
    my $data_d = [],
];

# Utiliza la declaración de la tabla
# para conocer el número de columnas
my $linea;
while ( $linea = <$tables> ) {
    if ( $linea =~ /(\\begin\{tabular\}.*)/ ) {
        $linea = $1;
        last;
    }
}


# Se utiliza para conocer el número de columnas
my $contador = 0;
$contador++ while $linea =~ /\|/g;
$contador--;

while ( my $line = <$tables> ) {
    my @m = ( $line =~ /([[:digit:].-]+)/g);
    if (!@m) {
        last;
    }
    for my $i ( 0 .. ($contador - 1) ) {
        push $data->[$i], $m[$i];
    }
}

#Write the useful information for Octave
for my $i ( 0 .. $#$data ) {
    print $octave "$names[$i] = [";
    for my $j ( 0 .. $#$data_a ) {
        print $octave " $data->[$i][$j] ";
    }
    print $octave "]\n";
}


close $octave or die "Could not close '$octave_file': $!";
close $tables or die "Could not close '$latexfile': $!";
