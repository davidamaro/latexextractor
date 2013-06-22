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

my @x_axis = ();
my @y_axis = ();

while ( my $line = <$tables> ) {
    if ( $line =~ /\\hline\s(\d+\.\d+)\s\&\s(\d+\.\d+)/ ) {
        push @x_axis, $1;
        push @y_axis, $2;
    }
}

#Write the useful information for Octave
print $octave "x = [@x_axis];\n";
print $octave "y = [@y_axis];\n";
print $octave "plot(x,y,'.','markersize',15)\n;";
print $octave "grid on\n";
print $octave "xlabel('t(s)')\n";
print $octave "ylabel('y\(m\)')\n";

#Run Octave's script
system ("octave", "--persist", "$octave_file");

close $octave or die "Could not close '$octave_file': $!";
close $tables or die "Could not close '$filename': $!";
