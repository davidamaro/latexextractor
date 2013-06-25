#!/usr/bin/perl 

use strict;
use warnings;
use diagnostics;
use Data::Dumper;
use Regexp::Common;

use constant LONGTABLE => 14;
use constant TABLE => 12;

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
my @lista = (
    [],
);
# Utiliza la declaración de la tabla
# para conocer el número de columnas
# y ver si se tiene que eliminar el primero 
# y último para el longtable
my $decision;
my $linea;
my $contador = 0;

while ( $linea = <$tables> ) {
    if ( $linea =~ /(\\begin\{tabular\}.*)/ ) {
        $linea = $1;
        $contador++ while $linea =~ /[[:alpha:]]/g;
        $contador -= TABLE;
        $decision = 0;
        last;
    }
    elsif ( $linea =~ /(\\begin\{longtable\}.*)/) {
        $linea = $1;
        $contador++ while $linea =~ /[[:alpha:]]/g;
        $contador -= LONGTABLE;
        $decision = 1;
        last;
    }
}

# Agregar el número de arrays para las columnas
for ( 1 .. ($contador - 1) ) {
    push @lista, [];
}

# Ignora las lineas que no tengan hline
# y asigna asigna los valores a cada
# referencia.
# Bug: Se van algunos undef.
while ( my $line = <$tables> ) {
    if ( $line =~ /(?=hline)/ ) { 
        #my @m = ( $line =~ /([[:digit:].-]+)/g);
        my @m = ( $line =~ /$RE{num}{real}/g);
        for my $i ( 0 .. ($contador - 1) ) {
            push $lista[$i], $m[$i];
        }
    }
}
if ($decision) {
    my $conter = $lista[0];
    foreach my $i ( 0 .. ( $contador - 1) ) {
        pop $lista[$i];
        shift $lista[$i];
    }
}
#Write the useful information for Octave
my $conter = $lista[0];
foreach my $i ( 0 .. ($contador - 1) ) {
    print $octave "$names[$i] = [";
    foreach my $j ( 0 .. ( $#$conter ) ) {
        print $octave " $lista[$i][$j] ";
    }
    print $octave "];\n";
}
close $octave or die "Could not close '$octave_file': $!";
close $tables or die "Could not close '$latexfile': $!";
