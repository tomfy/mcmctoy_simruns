#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my $terminal = 'default';
my $outfile = 'out.out';
my $which_plot = 'mse';
GetOptions('terminal=s' => \$terminal,
           'outfile=s' => \$outfile,
           'which_plot=s' => \$which_plot,
          );
$outfile = $which_plot . '.' . $terminal if($outfile eq 'out.out'  and  $terminal ne 'default');
print "terminal: $terminal, output file: $outfile \n";
my $mse_plot_string = '';
if ($terminal ne 'default') {
   $mse_plot_string .= "set terminal $terminal; ";
   $mse_plot_string .= "set out '$outfile'; ";
}

my $file = `ls ./*f/x`;
my @files = split(/\s+/, $file);
my $afile = $files[0]; 
open my $fh, "<", $afile;
my ($n_dim, $n_peaks, $sigma, $alpha, $steps, $variance) = (0,0,0,0,0,0);
my ($n_dim_done, $n_peaks_done, $sigma_done, $alpha_done, $steps_done, $variance_done) = (0,0,0,0,0,0);
while (<$fh>) {
   if (/n_dimensions:\s+(\d+)/) {
      $n_dim = $1;
      $n_dim_done = 1;
   }
   if (/n_peaks:\s+(\d+)/) {
      $n_peaks = $1;
      $n_peaks_done = 1;
   }
   if (/peak 1;\s+\S+\s+\S+\s+(\S+)\s+(\S+)/) {
      $sigma = $1;
      $sigma_done = 1;
      $alpha = $2;
      $alpha_done = 1;
   }
   if (/burn-in,\s+mcmc steps:\s+\S+\s+(\d+)/) {
      $steps = $1;
      $steps_done = 1;
   }
   if (/mean,\s+variance:\s+\S+\s+(\S+)/) {
      $variance = $1;
      $variance_done = 1;
   }
   last if($n_dim_done and $n_peaks_done and $sigma_done and $alpha_done and $steps_done and $variance_done);
}
my $fsigma = sprintf("%5.3f", $sigma);
my $falpha = sprintf("%4.2f", $alpha);
print "$n_dim  $n_peaks  $sigma  $alpha  $steps \n";
my $title_string = "$n_dim" . 'dim, ' . "$n_peaks" . 'peaks, ' . 'sig=' . $fsigma . ' a=' . $falpha . ' ' . $steps . 'steps';

if ($which_plot eq 'mse') {
   $mse_plot_string .= "set bmargin 3.8;";
   $mse_plot_string .= "set label 'T_hot' at graph 0.5,-0.12;";
   $mse_plot_string .= "set lmargin 10;";
   $mse_plot_string .= "set label 'MSE' at graph -0.1,0.5 rotate by 90;";
   $mse_plot_string .= "set title '$title_string';";

   $mse_plot_string .= "set log; ";
   $mse_plot_string .= "set style data errorbars;";
   $mse_plot_string .= "y = 24; ";
   $mse_plot_string .= "z = 26; ";
   $mse_plot_string .= "plot [][*:*] ";

   for (@files) {
      $mse_plot_string .= "'$_' using 1:y:z t'$_', ";
   }
   $mse_plot_string =~ s/,\s*$/; /;
   # my $separator = "' using 1:y:z, '";
   # $mse_plot_string .= join($separator, @files);
   # $mse_plot_string .= "' using 1:y:z  ;";
   $mse_plot_string .= "pause -1 ; exit;" if($terminal eq 'default');

} else {
   $mse_plot_string .= "set key left; ";
   $mse_plot_string .= "set bmargin 3.8; ";
   $mse_plot_string .= "set label 'T_hot' at graph 0.5,-0.12; ";
   $mse_plot_string .= "set lmargin 10; ";
   $mse_plot_string .= "set label 'effective sample size' at graph -0.1,0.3 rotate by 90; ";
   $mse_plot_string .= "set title '$title_string'; ";

   $mse_plot_string .= "set log x; ";
   $mse_plot_string .= "set style data errorbars; ";

   $mse_plot_string .= 'f(x,var,d,nT) = var*d/x - nT; '; # effective sample size, with nT initial draws subtracted off 
   # d*var is MSE for 1 draw.
   $mse_plot_string .= 'g(x,var,d) = var*d/x**2; '; # |derivative of f wrt x| 
   $mse_plot_string .= 'h(Th,f) = log(Th)/log(f) + 1; '; # number of temperatures; get it from Thot, f
   $mse_plot_string .= "var = $variance; ";
   $mse_plot_string .= "d = $n_dim; ";
   $mse_plot_string .= "plot [][-5:*] ";
  
   for (@files) {
      /(\d+)f/;
      my $f = 1*$1;
      my $x = " '$_'  using 1:(f(" . '\$' . "24,var,d,h(" . '\$' . "1,$f))):(g(" . '\$' . "24,var,d)*" . '\$' . '26) ';
      $mse_plot_string .= $x . 't' . "'$_', ";
   }
 $mse_plot_string =~ s/,\s*$/; /;
   # print $mse_plot_string, "\n";
   # print "$mse_plot_string", "\n";
   # my $separator = "' using 1:y:z, '";
   # $mse_plot_string .= join($separator, @files);
   # $mse_plot_string .= "' using 1:y:z  ;";
   $mse_plot_string .= "pause -1 ; exit;" if($terminal eq 'default');

}


#exit;
$mse_plot_string = "gnuplot -e " . '"' . $mse_plot_string . '"';
#print $mse_plot_string, "\n";
system ($mse_plot_string);


#print `gnuplot mse.gnuplot`;

