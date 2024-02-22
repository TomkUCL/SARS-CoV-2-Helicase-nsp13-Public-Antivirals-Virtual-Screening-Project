#!/usr/bin/perl

use strict;
use warnings;
use File::Copy;
use File::Path qw(make_path);
use POSIX ":sys_wait_h"; # Import the necessary module for signal handling

# Signal handler function
sub sigint_handler {
    print "\nReceived interrupt signal. Stopping the script...\n";
    exit(0);
}

# Register the signal handler for SIGINT
$SIG{INT} = \&sigint_handler;

print "Enter filename of ligands list: ";
my $ligfile = <STDIN>;
chomp $ligfile;

open(my $FH, '<', $ligfile) || die "Cannot open file\n";
my @arr_file = <$FH>;
close $FH;

open(my $RESULTS, '>', "vinaresults_log.txt") || die "Cannot create vinaresults_log.txt\n";

# Directory for log files
my $log_directory = "docked_lig_log_files";

# Create directory if it doesn't exist
unless (-d $log_directory) {
    make_path($log_directory) or die "Error creating directory $log_directory: $!";
}

# Number of CPUs to use
my $num_cpus = 8;

foreach my $lig (@arr_file) {
    chomp $lig;
    my ($name) = $lig =~ /^(.*)\./;
    my $logfile = "$log_directory/${name}_log.log"; # Modify log file path

    # Run Vina sequentially for each ligand using specified number of CPUs
    system("vina --config 5rmm_rigid_conf.txt --ligand $lig --cpu $num_cpus > $logfile 2>&1");

    # Print real-time updates of the log file
    print "Running Vina for $name...\n";

    open(my $LOG, '<', $logfile) || die "Cannot open $logfile\n";
    my @lines = <$LOG>;
    close $LOG;

    my $min_score = undef;
    foreach my $line (@lines) {
        if ($line =~ /^\s*\d+\s+(-?\d+\.\d+)\s+/) {
            my $score = $1;
            $min_score = $score if (!defined $min_score || $score < $min_score);
        }
    }

    if (defined $min_score) {
        my $formatted_score = sprintf("%.3f", $min_score);
        print $RESULTS "ligand $name\t$formatted_score kcal/mol\n";

        # Check if the output .pdbqt file exists before moving
        my $pdbqt_file = "output.pdbqt";
        if (-e $pdbqt_file) {
            # Move the output .pdbqt file to include the minimum score in the filename
            move($pdbqt_file, "${name}_minvina_${formatted_score}kcal_mol.pdbqt") or die "Move failed: $!";
        } else {
            die "Error: Output file $pdbqt_file not found\n";
        }
    }
}

close $RESULTS;

