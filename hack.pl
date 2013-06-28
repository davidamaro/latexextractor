#!/usr/bin/perl 

use strict;
use warnings;
use diagnostics;
use Regexp::Common;
use Data::Dumper;

# Tamaño de los carácteres de la
# declaración en LaTeX de las tablas
use constant LONGTABLE => 14;
use constant TABLE => 12;

# Nombre de cada columna que devolvera el programa
my @names = qw(array_a
               array_b
               array_c
               array_d
               array_e
               array_f
               array_g
               array_h
               array_i
               array_j
               array_k
               array_l
               array_m
               array_n
               array_o
               array_p
               array_q
               array_r
               array_s
);

# Variables que funcionan para conocer el valor de inicio
# y final de la lista @lista
my $inicio = 0;
my $adicion = 0;
my @lista = (
);

sub get_filenames {
    my %arguments;
    die "Número de parámetros inválido" if (@ARGV != 2);
    for (@ARGV) {
        my $adver = 0;
        $adver++ if ( $_ =~ /\./g );
        my $filename = $_;
        die "Nombre de archivo inválido" if ( $adver > 1);
        if ( $_ =~ /(?=\.m)/ ) {
            $arguments{octavefn} = "$filename";
        }
        elsif ( $_ =~ /(?=\.tex)/ ) {
            $arguments{latex} = "$filename";
        }
    }
    return %arguments;
}

#Open file with LaTeX data
my %arguments = get_filenames();

my $latexfile = $arguments{latex}
    or die "No input file.\n";
open my $tables, '<', $latexfile
    or die "Cannot open '$latexfile' for writing: $!";

#Open file that will use Octave
my $octave_file = $arguments{octavefn};
open my $octave, '>>', $octave_file
    or die "Cannot open '$octave_file' for writing: $!";

sub numero_columnas {
    my $linea = shift;
    my $columnas = 0;
    if ( $linea =~ /(\\begin\{tabular\}.*)/ ) {
        $columnas++ while $linea =~ /[[:alpha:]]/g;
        $columnas -= TABLE;
    }
    elsif ( $linea =~ /(\\begin\{longtable\}.*)/) {
        $columnas++ while $linea =~ /[[:alpha:]]/g;
        $columnas -= LONGTABLE;
    }
    return $columnas;
}

# Agregar el número de arrays para las columnas
sub add_space {
    my $columnas = shift;
    $columnas -= 1;
    foreach ( 0 .. $columnas ) {
        push @lista, [];
    }
}

# Ignora las lineas que no tengan hline
# y asigna asigna los valores a cada
# referencia.

sub get_type {
    my $linea = shift;
    my $columnas = numero_columnas($linea);
    chomp $linea;
    if ( $linea =~ /end(\{tabular\}|\{longtable\})/ ) {
        $inicio += $adicion;
        return;
    }
    elsif ( $linea =~ /(?=tabular|longtable)/ ) {
        add_space($columnas);
        $adicion = $columnas;
        return;
    }
    elsif ( $linea =~ /\\hline.+?\z/ ) {
        return $linea;
    }
    elsif ( $linea =~ /$RE{num}{real}/ ) {
        return $linea;
    }
    else {
        return;
    }
}

while ( my $line = <$tables> ) {
    my $valor = get_type($line);
    next if !$valor;
    my @datos = ( $line =~ /$RE{num}{real}/g);
    my $final = $inicio + $adicion - 1;
    foreach my $index ( $inicio .. $final ) {
        push $lista[$index], $datos[$index - $inicio];
    }
}

print Dumper(@lista);

my $tamano = 0;
while ( exists $lista[$tamano]->[0] ) {
    my $parcial = 0;
    print $octave "$names[$tamano] = [";
    if ( ! defined $lista[$tamano]->[$parcial] ) {
        warn "Posible tabla mal formada o espacio en blanco!";
        $lista[$tamano]->[$parcial] = "NaN";
    }
    while ( exists $lista[$tamano]->[$parcial] ) {
        print $octave " $lista[$tamano]->[$parcial] ";
        $parcial++;
    }
    print $octave "];\n";
    $tamano++;
}

close $octave or die "Could not close '$octave_file': $!";
close $tables or die "Could not close '$latexfile': $!";
