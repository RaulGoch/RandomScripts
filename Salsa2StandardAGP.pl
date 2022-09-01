#! /usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq);

########################################################
## USAGE
##

my $USAGE =<<USAGE;

        Usage: Salsa2StandardAGP.pl salsa.agp standard.agp 

                salsa.agp:	Assembly output file from Salsa (making sure old scaffolds are sorted)
                standard.agp:	Desired name for standard AGP file
USAGE

##
######################################################

#print "@ARGV";
if($#ARGV!=1){
        print "$USAGE\n";
    exit;
}

my $salsa = $ARGV[0]; # Salsa AGP file
open(SALSA, $salsa) or die "Couldn't open $salsa.\n";

my $out = $ARGV[1]; # Output file
open(OUT, '>', $out) or die "Couldn't open $out.\n";

my $prev_comp_id = "";
my $prev_comp_end = 0;

while (my $line = <SALSA>){
        chomp $line;
	my @cols = split /\t/, $line;
	# Assign all values in columns to variables
	my $obj = $cols[0];
	my $obj_beg = $cols[1];
	my $obj_end = $cols[2];
	my $part_num = $cols[3];
	my $comp_type = $cols[4];
	my $comp_id = $cols[5];
	my $comp_beg = $cols[6];
	my $comp_end = $cols[7];
	my $orientation = $cols[8];	
	if($comp_id =~ m/_1$/){
		# Modify
		my ($newComp_id) = ($comp_id =~ m/(.+)_\d+/);
		# Print
		print OUT "$obj\t$obj_beg\t$obj_end\t$part_num\t$comp_type\t$newComp_id\t$comp_beg\t$comp_end\t$orientation\n";
		# Prepare for next fragment
		$prev_comp_id = $newComp_id;
		$prev_comp_end = $comp_end;
	}elsif($comp_id =~ m/_\d+$/){
		# Modify
		my ($newComp_id) = ($comp_id =~ m/(.+)_\d+/);
		my $newComp_beg = $prev_comp_end + 1;
		my $newComp_end = $prev_comp_end + $comp_end;
		print OUT "$obj\t$obj_beg\t$obj_end\t$part_num\t$comp_type\t$newComp_id\t$newComp_beg\t$newComp_end\t$orientation\n";	
	}else{
		print OUT "$line\n";
	}
}
close OUT;
close SALSA;

