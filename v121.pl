use Mojolicious::Lite;

app->secrets(['hauntedbyaghost']);

##Helpers##

##initialization helpers
#Primary declaration of session variables used later in the game
helper initialize => sub {
	my $c = shift;
	my $jewelroom;
	$c->session(
		mansion   => { 
			"2"   => ["guestroom", "musicroom", "cow", "balcony", "hallway", "closet"],
			"1"   => ["entryway", "kitchen", "den", "library", "diningroom", "hallway"],
			"0"   => ["study", "hallway", "cellar", "altar", "closet", "library"],
			"20"  => "closet",
			"10"  => "library",
			"210" => "hallway"
		},
		salvation => "1",
		action    => "0",
		location  => "entryway",
		ghost     => "altar",
		jewel	  => "1",
		hid		  => '0',
		ahead	  => '0',
		peeked	  => '0'
	);
	$jewelroom = $c->session('mansion')->{"2"}->[int(rand(4))];
	$c->session('jewel'=> $jewelroom);
};

##General Game helpers
#Checks the floor of the ghost and player and returns them as an array (player, ghost)
#This returns the FLOOR, not the room!
helper getfloor => sub {
	my $c = shift;
	my $pfloor = 'entrway';
	my $gfloor = 'altar';
	$gfloor = $c->session('ghost');
	if ($gfloor eq 'closet') {$gfloor = '20';}
	elsif ($gfloor eq 'library') {$gfloor = '10';}
	elsif ($gfloor eq 'hallway') {$gfloor = '210';}
	else {
		GHOST: for (my $n = 0; $n < 3; $n++) {
			for (my $i = 0; $i < 7; $i++) {
				if ($gfloor eq $c->session('mansion')->{$n}->[$i]) {
					#warn 'ghost-',$gloor,$n,$i;
					$gfloor = $n;
					last GHOST;
				}
			}
		}
	}

	$pfloor = $c->session('location');
	if ($pfloor eq 'closet') {$pfloor = '20';}
	elsif ($pfloor eq 'library') {$pfloor = '10';}
	elsif ($pfloor eq 'hallway') {$pfloor = '210';}
	else {
		#warn 'player-',$ploor;
		PLAYER: for (my $n = 0; $n < 3; $n++) {
			for (my $i = 0; $i < 6; $i++) {
				if ($pfloor eq $c->session('mansion')->{$n}->[$i]) {
					$pfloor = $n;
					last PLAYER;
				}
			}
		}
	}
	#warn 'player2-',$ploor;
	return ($gfloor, $pfloor);
};


#Moves the ghost to its next room
helper moveghost => sub {
	my $c = shift;
	my $room;
	my ($floor, $unused) = $c->getfloor;
	if ($floor eq '20') {
		my $num = int(rand(2));
		if ($num eq '0') {
			$floor = '0';
		}
		elsif ($num eq '1') {
			$floor = '2';
		}
	}
	elsif ($floor eq "10") {
		$floor = int(rand(2));
	}
	elsif ($floor eq "210") {
		$floor = int(rand(3));
	}
	$room = $c->session('mansion')->{$floor}->[int(rand(6))];
	$c->session('ghost' => $room);
};

#Sets the room ahead of the player and sets peeked to 1
helper getahead => sub {
	my $c = shift;
	my $room;
	my $peeked = $c->session('peeked');
	my ($unused, $floor) = $c->getfloor;
	if ( $peeked eq '0') {
		if ($floor eq '20') {
			my $num = int(rand(2));
			if ($num == '0') {
				$floor = '0';
			}
			elsif ($num eq '1') {
				$floor = '2';
			}
		}
		elsif ($floor eq "10") {
			$floor = int(rand(2));
		}
		elsif ($floor eq "210") {
			$floor = int(rand(3));
		}
		$room = $c->session('mansion')->{$floor}->[int(rand(6))];
		$c->session(ahead  => $room);
	}
	$c->session(peeked => '1');
};
#Moves the player, while resetting peeked
helper moveplayer => sub {
	my $c = shift;
	my $room;
	my ($unused, $floor) = $c->getfloor;
	if ( $c->session('peeked') eq '1' ) {
		$room = $c->session('ahead');
	}
	else {
		if ($floor eq '20') {
			my $num = int(rand(2));
			if ($num == '0') {
				$floor = '0';
			}
			elsif ($num eq '1') {
				$floor = '2';
			}
		}
		elsif ($floor eq "10") {
			$floor = int(rand(2));
		}
		elsif ($floor eq "210") {
			$floor = int(rand(3));
		}
		$room = $c->session('mansion')->{$floor}->[int(rand(6))];
	}
	$c->session('peeked' => '0');
	$c->session('location' => $room);
};

#Checks to see if the ghost and player on the same floor, returns 1 (true) if they are
helper ghostonfloor => sub {
	my $c = shift;
	my ($gfloor, $pfloor) = $c->getfloor;
	if ( $gfloor eq '210' || $pfloor eq '210' ) {
		return 1;
	}
	elsif ( $pfloor eq '10' && $gfloor eq '20') {
		return 1;
	}
	elsif ( $pfloor eq '20' && $gfloor eq '10') {
		return 1;
	}
	elsif ( index ($gfloor, $pfloor) != -1 || index($pfloor,$gfloor) != -1 ) {
		return 1;
	}
	else {
		return 0;
	}
};

#Player hides and moves the ghost if it was on the floor to a place guarunteed to not be where the player is
helper hide => sub {
	my $c = shift;
	my $newghost;
	my $floor = $c->ghostonfloor;
	if ($floor eq '1') { 
		$c->session('hid' => '1');
		do {
			$newghost = $c->session('mansion')->{int(rand(3))}->[int(rand(6))];
		} while ( $c->session('location') eq $c->session('ghost') );
		$c->session(ghost => $newghost);
	}
	else {$c->session('hid' => '0');}
	$c->session('peeked' => '0');
};

##Player action Helpers
#For when the player chooses option one - Moves the player, Resets peeked
helper option1 => sub {
	my $c = shift;
	$c->moveplayer;
};

#For when the player chooses option two - Hides, Resets peeked
helper option2 => sub {
	my $c = shift;
	$c->hide;
};

#For when the player chooses option three - Redirects to Wimp ending
helper option3 => sub {
	my $c = shift;
	$c->redirect_to('wimp');
};


#For when the player chooses option four - Resets peeked
helper option4 => sub {
	my $c = shift;
	$c->session(peeked => '0');
};

#For when the player chooses option five - Sets what is ahead
helper option5 => sub {
	my $c = shift;
	$c->getahead;
};

#For when the player chooses option six - If everything checks out, redirects to game win
helper option6 => sub {
	my $c = shift;	
	if ( $c->session('jewel') eq '0' && $c->session('location') eq 'entryway' ) {
		$c->redirect_to('win');
	}
};

#For after the decisions are made - Moves ghost, Checks for overlapping rooms, Checks for loss and will redirect to game over page
helper finalchecks => sub {
	my $c = shift;
	if ( $c->param('choice') ne '2' ) {
		$c->moveghost;
	}
	my $location = $c->session('location');
	my $ghost	 = $c->session('ghost');
	my $jewel	 = $c->session('jewel');
	my $life	 = $c->session('salvation');

	if ($location eq $ghost) {
		$c->session(salvation => '0');
	}
	if ($location eq $jewel) {
		$c->session(jewel => '0');
	}
	if ($life eq '0') {
		$c->redirect_to('over');
	}
	
};


##Routes##
#Home Route which resets the cookie data and displays the title screen
get '/' => sub {
	my $c = shift;
	$c->initialize;
	$c->render(template => 'home');
};

#The Main loop route which takes in the players choices as a parameter and processes them 
get '/game(:choice)' => {choice => '0'} => sub {
	my $c = shift;
	my $jewel		= $c->session('jewel');
	my $choice		= $c->param('choice');
	my $hid;
	my $location;
	my $ghoston;
	my $nextroom;
	
	if ( $choice eq '1' ) {
		$c->option1;
	}
	elsif ( $choice eq '2' ) {
		$c->option2;
		$hid = $c->session('hid');
	}
	elsif ( $choice eq '3' ) {
		$c->redirect_to('wimp');
	}
	elsif ( $choice eq '4' ) {
		$c->option4;
	}
	elsif ( $choice eq '5' ) {
		$c->option5;
	}
	elsif ( $choice eq '6' ) {
		$c->option6;
	}
	if ( $choice ne '0') {
		$c->finalchecks;
	}
	
	$location = $c->session('location');
	$nextroom = $c->session('ahead');
	$ghoston		= $c->ghostonfloor;
	if ($ghoston == '1') { $ghoston = "howling"; }
	else { $ghoston = "moaning"; }
	
	$c->stash(location => $location, ghost => $ghoston, hiding => $hid, move => $choice, jewel => $jewel, ahead => $nextroom);
	$c->render(template => 'game');
};

#The main game over screen's route
get '/over' => sub {
	my $c = shift;
	$c->render(template => 'over');
};

#The route for winning the game
get '/win' => sub {
	my $c = shift;	
	$c->render(template => 'win');
};

#The route for those who take the wimp ending
get '/wimp' => sub {
	my $c = shift;
	$c->render(template => 'wimp');
};

app->start;

##Templates and Layouts##
__DATA__

@@ home.html.ep
<h1>Welcome to the Haunted House!</h1>
The Haunted House Game was designed and coded by Matt Edgar
<hr>
<b>The Story:</b>
On a hill there lies a certain mansion. It is said to be home to the incredibly valuable BLOOD RUBY, but it has become haunted by the spirits of the ruby's past owners. The house itself is decrepit, but it is impossible to leave once it has been entered. Many go insane because of the twisting corridors and doors that do not lead where they should. Some doors will lead back through themselves, trapping a person inside and causing them to panic. Will you be able to overcome this challenge?
<hr>
If you are brave enough you can enter the <%=link_to Mansion => 'game' %>.




@@ game.html.ep
% layout 'default';
% if ($move eq '1') {
	You go through the oak door in front of you and walk into a new room.<hr>	
% }
% if ($move eq '2') {
	You panic and curl up into a ball under a pile of trash in the corner of the room.
%	if ($hidin eq '1') {
		To your horror, you see the ghost tear through the room searching for you, but it quickly goes to another room in the mansion when it can't find you.
		<hr>
%	}
%	else {
		After a few minutes the panic attack subsides and you stand back up again.
		<hr>
%	}
% }
% if ($move eq '4'){
	You panic and freeze, listening to the ghost searching the mansion for you. After a few minutes you calm down enough to move again.
	<hr>
% }
% if ($move eq '5'){
	You peek through the door and see the <%= $ahead %>. <hr>	
% }
% if ($jewel eq $location) {
	You pick up a shining red jewel off of the floor. You feel relief knowing that you can now leave through the entryway. <hr>
% }
You are standing in the <%= $location %>.
It is old and abandoned. 
% if ($jewel eq '0') {
	The blood ruby sits in your hand, glittering within the dim light of the room. 	
% }
Through the ancient walls of the mansion you can hear <%= $ghost %>.
There is only one old, oaken door in the room. 
What would you like to do?<hr>
<%= button_to '1) Move Forward                        ' => 'game1' %><br>
<%= button_to '2) Hide                                       ' => 'game2' %><br>
<%= button_to '3) Run Away                              ' => 'game3' %><br>
<%= button_to '4) Wait for a while                      ' => 'game4' %><br>
<%= button_to '5) Peek through the door ahead' => 'game5' %> <br>
% if ($jewel eq '0' && $location eq 'entryway') {
	<%= button_to '6) Escape the Mansion              ' => 'game6' %>
% }




@@ over.html.ep
As you walk through the room you suddenly feel icy hands along your neck and everything goes black.
<br>
~~~~~~~~~~~~~<br>
~GAME OVER~<br>
~~~~~~~~~~~~~
<br><%=button_to 'Play Again?' => '/' %>




@@ win.html.ep
You step through the front door of the mansion to see the first rays of dawn. Congratulations.
<br>
~~~~~~~~~~~~~<br>
~GAME OVER~<br>
~~~~~~~~~~~~~
<br><%=button_to 'Play Again?' => '/' %>




@@ wimp.html.ep
You give in to your panic and sprint through the mansion desperately trying to find a way out. You can hear the ghost tearing the mansion apart behind you as it catches up. You suddenly come to a stop in the entryway where the front door has dissappeared. The ghost suddenly comes into the rooms and attacks you.
<br>
~~~~~~~~~~~~~<br>
~GAME OVER~<br>
~~~~~~~~~~~~~
<br><%=button_to 'Play Again?' => '/' %>
<br>
Wimp.




@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
	<head><title>Haunted House</title></head>
	<body><%= content %></body>
</html>
