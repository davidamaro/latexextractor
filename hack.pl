use strict;
use warnings;
use diagnostics;

#Open file with LaTeX data
my $filename = 'tab.tex';
open my $tables, '<', $filename
    or die "Cannot open '$filename' for writing: $!";

#Open file that will use Octave
my $octave_file = 'oct.m';
open my $octave, '>>', $octave_file
    or die "Cannot open '$octave_file' for writing: $!";

#Este código se elimina ya que no es general
my @x_axis = ();
my @y_axis = ();
my @z_axis = ();

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

#Generar la regex
my $reg_exp = "\\\\hline\\s";
for ( 1 .. $contador ) {
    $reg_exp .= "([[:digit:].-]+)";
    if ( $_ == $contador ) {
        last;
    }
    $reg_exp .= "\\s\\&\\s";
}

#Código temporal para asignar a un array
while ( my $line = <$tables> ) {
    if ( $line =~ /$reg_exp/ ) {
        push @x_axis, $1;
        push @y_axis, $2;
        push @z_axis, $3;
    }
}
#Write the useful information for Octave
print $octave "x = [@x_axis];\n";
print $octave "y = [@y_axis];\n";
print $octave "z = [@z_axis];\n";
#print $octave "plot(x,y,'.','markersize',15)\n;";
#print $octave "grid on\n;";
#print $octave "xlabel('t(s)')\n";
#print $octave "ylabel('y\(m\)')\n";

#Run Octave's script
system ("octave", "--silent", "--persist", "$octave_file");

close $octave or die "Could not close '$octave_file': $!";
close $tables or die "Could not close '$filename': $!";
