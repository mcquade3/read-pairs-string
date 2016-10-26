#!/usr/local/bin/perl
# Mike McQuade
# Read-pairs-string.pl
# Constructs a string from read-pairs.

# Define the packages to use
use strict;
use warnings;

# Initialize variables
my ($k,$d,@pairs,%firstOverlap,%secondOverlap);

# Open the file to read
open(my $fh,"<ba3j.txt") or die $!;

# Read in the values from the file
my $line = <$fh>;
chomp($line);
my @temp = split(/ /,$line);
$k = $temp[0];
$d = $temp[1];

while (my $line = <$fh>) {
	chomp($line);
	my @temp = split(/\|/,$line);
	push @pairs,\@temp;
}

# Map each k-mer pair with a matching suffix to a k-mer pair with a matching prefix
for (my $i = 0; $i < scalar(@pairs); $i++) {
	for (my $j = 0; $j < scalar(@pairs); $j++) {
		if ((substr($pairs[$i][0],1) eq substr($pairs[$j][0],0,-1))
				and (substr($pairs[$i][1],1) eq substr($pairs[$j][1],0,-1))) {
			$firstOverlap{$pairs[$i][0]} = $pairs[$j][0];
			$secondOverlap{$pairs[$i][1]} = $pairs[$j][1];
		}
	}
}

# Call the function to construct the string on all the possible starting
# points, printing out the longest one, which is the correct answer.
my $max = 0;
my $answerString;
for (my $i = 0; $i < scalar(@pairs); $i++) {
	my $tempStr = constructString($pairs[$i][0],$pairs[$i][1]);
	if (length($tempStr) > $max) {
		$max = length($tempStr);
		$answerString = $tempStr;
	}
}

# Print out the concatenation of all the k-mer pairs
print $answerString."\n";

# Close the file
close($fh) || die "Couldn't close file properly";



# Define the function to construct the string
sub constructString {
    # Initialize parameters
	my ($startingPoint1,$startingPoint2) = @_;
	
	# Initialize the constructed string with the first starting point
	my $completeString = $startingPoint1;

	# Iterate through the beginning of the first of the string
	my $iteration = $startingPoint1;
	for (my $i = 0; $i < $d; $i++) {
		if ($firstOverlap{$iteration}) {$completeString .= substr($firstOverlap{$iteration},-1)}
		else {last}
		$iteration = $firstOverlap{$iteration};
	}

	# Concatenate the second starting point to the constructed string
	$completeString .= $startingPoint2;

	# Iterate through the second part of the string
	$iteration = $startingPoint2;
	while ($secondOverlap{$iteration}) {
		$completeString .= substr($secondOverlap{$iteration},-1);
		$iteration = $secondOverlap{$iteration};
	}

	# Return the newly constructed string
	return $completeString;
}