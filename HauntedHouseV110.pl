use strict;
use warnings;
use 5.010;

##Title Screen##
say "~~~~";
say "Haunted Mansion Game";
say "Designed and Coded by Matt Edgar";
say "~~~~";
say "On a hill there lies a certain mansion. It is said to be home to the incredibly valuable BLOOD RUBY, but it has become haunted by the spirits of the ruby's past owners. The house itself is decrepit, but it is impossible to leave once it has been entered. Many go insane because of the twisting corridors and doors that do not lead where they should. Some doors will lead back through themselves, trapping a person inside and causing them to panic. Will you be able to overcome this challenge?";
say "~~~~";

##Declaring Variables##
my $location = "entryway"; #player
my $ghost = "altar";       #enemy
my $alvation = "1";        #life
my $action = undef;	   #action
my $ahead = undef;         #next room
my $peeked = "0";          #for looking ahead

my @upperfloor =("guestroom", "musicroom", "cow", "balcony", "hallway", "closet",);
my @firstfloor =("entryway", "kitchen", "den", "library", "diningroom", "hallway",);
my @lowerfloor =("study", "hallway", "cellar", "altar", "closet", "library",);

#XXXXXrooms variables unused
my $upperrooms = @upperfloor;
my $firstrooms = @firstfloor;
my $lowerrooms = @lowerfloor;
my $totalrooms = $upperrooms + $firstrooms + $lowerrooms;

my %mansion = ( "2" => \@upperfloor,
		"1" => \@firstfloor,
		"0" => \@lowerfloor,
		"20" => "closet",
		"10" => "library",
		"210" => "hallway",
	      );

my %givingout = ( "2"   => "cielings",
		  "1"   => "floor tiles",
		  "0"   => "walls",
		  "20"  => "old cloths",
		  "10"  => "book cases",
		  "210" => "paintings along the wall",
		);

my $jewel = $mansion{"2"}->[int(rand(4))];


##Usefull Subroutines##
sub location {
	return $location;
	}

sub checkfloor {
	my $spot = $_[0];
	my $floor;
	if ( $spot eq "closet" ) {return "20";}
	elsif ( $spot eq "library" ) {return "10";}
	elsif ( $spot eq "hallway" ) {return "210";}
	else {
		for (my $n = 0; $n < 3; $n++) {
			foreach ( @{ $mansion{$n}} ) {
				if ($spot eq $_ ) {
					$floor = $n;
					last;
				}
			}
		}
		return $floor;
	}
}

sub nextroom {
	my $floor = $_[0];
	if ($floor eq "20") {
		my $num = int(rand(2));
		if ($num == 0) {
			$floor = 0;
		}
		elsif ($num == 1) {
			$floor = 2;
		}
	}
	elsif ($floor eq "10") {
		$floor = int(rand(2));
	}
	elsif ($floor eq "210") {
		$floor = int(rand(3));
	}

	return $mansion{$floor}->[int(rand(6))];
}

sub moveghost {
	$ghost = nextroom(checkfloor($ghost));
}

sub ghostonfloor {
	if ( $ghost eq "hallway" ) {
		return 1;
	}
	elsif ( $location eq "hallway" ) {
		return 1;
	}
	elsif ( $location eq "closet" && $ghost eq "library" ) {
		return 1;
	}
	elsif ( $location eq "library" && $ghost eq "closet" ) {
		return 1;
	}
	elsif ( index (checkfloor($ghost), checkfloor($location)) != -1 ) {
		return 1;
	}
	elsif (index (checkfloor($location), checkfloor($ghost)) != -1 ) {
		return 1;
	}
	else {
		return 0
	}
}

#Main loop subroutines
sub input {
	say "Ahead of you, you can see a closed door.";
	say "What would you like to do?";
	say "\t1)Move Forward";
	say "\t2)Hide";
	say "\t3)Run Away";
	say "\t4)Peek through the door";
	say "\t5)Wait for a while";
	if ($jewel eq "0") {say "\t6)Leave the mansion";}
	print ">>";
	$action = <STDIN>;
	chomp $action;
	say "~~~~~~~~";
	return $action;
}

sub situation {
	say "You are standing in the ", $location;	
	say "It is old and abandoned. The ", $givingout{checkfloor($location)}, " seem to be so old that they are falling apart.";
	say "Through the ancient walls you can hear ", (ghostonfloor == 1 ? "howling" : "moaning");
}

sub results {
	my $result = $_[0];	
	if ($peeked == 0 ) {$ahead = nextroom(checkfloor($location));}
	moveghost();
	if ( $result == 1 ) {
		$location = $ahead;
		say "You go through the door and find yourself in the ", $location, ".";
		if ( ghostonfloor() == 1 ) { say "You feel the hairs of the back of your neck stand up";}
		$peeked = 0;
	}
	elsif ( $result == 2 ) {
		if ( ghostonfloor() == 1 ) {
			say "You curl up in a corner under some trash and try to look inconspicuous. To your horror, there is suddenly a sharp shriek and the ghost flashes through the room, tearing and destroying it even more than it already was.";
			do {
				$ghost = $mansion{int(rand(3))}->[int(rand(6))];
			} until ( $ghost ne $location)
		}
		else {
			say "You curl up in a corner under some trash and try to look inconspicuous. Nothing happens and in a few moments your panic attack subsides.";
		}
		$peeked = 0;
	}
	elsif ( $result == 3 ) {
		say "You let yourself become consumed by fear and madly run toward where you think the exit is. Along the way you can hear the ghost howling behind you. Instead of at the exit you find yourself trapped in the altar as the ghost catches up.";
		$alvation = 0;
	}
	elsif ( $result == 4 ) {
		say "You peek through the door and see the ", $ahead;
		if ( $ghost eq $ahead ) { say "Inside you see the ghost destroying everything in the room, searching for you.";}
		$peeked = 1;
	}
	elsif ( $result == 5 ) {
		say "You crawl into the corner and hug your knees while you try to calm down.";
		if ( $ghost eq $location ) {say "You see the ghost float through the door ahead of you. You can't escape, the cold has frozen your legs in place.";}
		$peeked = 0;
	}
	elsif ( $result == 6 ) {
		if ( $jewel eq "0" && $location eq "entryway" ) {
			say "You escape the mansion to see the first rays of dawn. Congratulations.";
			$alvation = 0;
		}
		else {
			say "You are too terrified to do that.";
		}
	}
	else {
		say "You are too terrified to do that.";
	}
	if ( $ghost eq $location ) {
		say "Suddenly you feel icy hands along your neck and everything goes black.";
		$alvation = 0;
	}
	elsif ($jewel eq $location ) {
		say "You find a large red jewel glittering on the ground. You pick it up and feel relief knowing that you can finally leave through the entryway.";
		$jewel = 0;
	}
	if ( $location eq "altar" && $ghost eq $location ) {
		say "You startle awake and find yourself back in your room. As you calm down you worry about your nightmare and what it could mean. As you open the blinds to your room, you see that the sky is red. Except that it isn't the sky. It is faceted, like a jewel and through it you can hazily see a giant room. One that suspiciously looks like one of the rooms in the mansion.";
	}
}

##Main Game##
while ($alvation == 1) {
#DEBUGGING	say "DEBUG: The ghost is in the ", $ghost;
	situation();
	results(input());
	say "~~~~";	
}

say "~~~~~~~~~~~~~";
say "~ GAME OVER ~";
say "~~~~~~~~~~~~~";
if ( $action == 3 ) { say "quitter"; }


##debugging info##
#say $upperrooms, @upperfloor;
#say $firstrooms, @firstfloor;
#say $lowerrooms, @lowerfloor;
#say $totalrooms, " rooms in total";

#DEBUGROOMS: for (my $n = 0; $n < 10; $n++) {say $mansion{int(rand(3))}->[int(rand(6))];}
#say "You are in the ", $location;
#say checkfloor("altar");
#say checkfloor("cow");
#say checkfloor($location);
#say checkfloor("closet");

#say "You step through the door in front of you, leaving the ", $location, " and entering the ", nextroom(checkfloor("hallway"));

#say index checkfloor($ghost), checkfloor($location);
#say index checkfloor($location), checkfloor($ghost);
#say ghostonfloor();

#if ( index (checkfloor($location), checkfloor($ghost)) != -1 ) {
#	say "error";
#}
#elsif ( index (checkfloor($ghost), checkfloor($location)) != -1)  {
#	say "error";
#}














