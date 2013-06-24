use strict;
use warnings;
use diagnostics;
use Data::Dumper;

#Names
my @names = qw(array_a array_b array_c array_d);

#Open file with LaTeX data
my $filename = 'tab.tex';
open my $tables, '<', $filename
    or die "Cannot open '$filename' for writing: $!";

#Open file that will use Octave
my $octave_file = 'oct.m';
open my $octave, '>>', $octave_file
    or die "Cannot open '$octave_file' for writing: $!";

#Este código se elimina ya que no es general

my $data = [
    my $data_a = [],
    my $data_b = [],
    my $data_c = [],
    my $data_d = [],
];

#Código para obtener la primer linea
#Error, por que elimina la primer linea
my $linea;
while ( $linea = <$tables> ) {
    if ( $linea =~ /(\\hline.*)/ ) {
        $linea = $1;
        last;
    }
}

# Se utiliza para conocer el número de columnas
my $contador = 0;
$contador++ while $linea =~ /[[:digit:].-]+/g;

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
close $tables or die "Could not close '$filename': $!";
