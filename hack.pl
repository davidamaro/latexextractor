#!/usr/bin/perl 

use strict;
use warnings;
use diagnostics;
use Data::Dumper;
use Regexp::Common;

# Tamaño de los carácteres de la
# declaración en LaTeX de las tablas
use constant LONGTABLE => 14;
use constant TABLE => 12;

#Names
my
@names
=
qw(array_a
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
my $inicio = 0;
my $adicion = 0;
my $asesino = 0;
my @valores = ();

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
);

# Utiliza la declaración de la tabla
# para conocer el número de columnas
# y ver si se tiene que eliminar el primero 
# y último para el longtable

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

sub alfa_omega {
    my @array = @lista;
    my $contador = 0;
    $contador++ while ( exists $lista[$contador]->[0] );
    return $contador;
}

sub get_type {
    my $linea = shift;
    my $columnas = numero_columnas($linea);
    #print "Adición: $adicion\n";
    chomp $linea;
    if ( $linea =~ /end(\{tabular\}|\{longtable\})/ ) {
        #print "Salí\n";
        $inicio += $adicion;
        push @valores, $adicion;
        $asesino++;
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
    else {
        return;
    }
}

while ( my $line = <$tables> ) {
    my $valor = get_type($line);
    next if !$valor;
    my @datos = ( $line =~ /$RE{num}{real}/g);
    my $final = $inicio + $adicion - 1;
    #print "$inicio - $adicion - $final\n";
    foreach my $index ( $inicio .. $final ) {
        push $lista[$index], $datos[$index - $inicio];
    }
}

#print $asesino;
#print "@valores\n";
#print Dumper(@lista);

#Write the useful information for Octave
#my $conter = $lista[0];
# Número de columnas
#foreach my $i ( 0 .. ($contador - 1) ) {
#    print $octave "$names[$i] = [";
#    # Número de elementos
#    foreach my $j ( 0 .. ( $#$conter ) ) {
#        print $octave " $lista[$i][$j] ";
#    }
#    print $octave "];\n";
#}
my $tamano = 0;
$tamano++ while ( exists $lista[$tamano]->[0] );
$tamano--;

for my $i ( 0 .. $tamano ) {
    my $j = 0;
    print $octave "$names[$i] = [";
    while ( exists $lista[$i]->[$j] ) {
        print $octave " $lista[$i]->[$j] ";
        $j++;
    }
    print $octave "];\n";
}
close $octave or die "Could not close '$octave_file': $!";
close $tables or die "Could not close '$latexfile': $!";
