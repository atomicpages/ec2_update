#! /usr/bin/env perl
# version 0.1.2.6

use warnings;
use strict;
use feature qw(say);
use Switch;
use Term::ANSIColor;

print colored("Welcome to the Linux AMI startup script.", "bold") . " Follow the directions and 
the script will guide you to installing stacks and servers on your new EC2 
instance.\n\n";

print colored("Disclaimer: ", "bold yellow") . "This script does the best to prevent unwarranted software 
installation. We do our best to keep this script updated. We are in no way responsible
for the misuse of or the altercation of this script. Only download from the official 
repository in order to have the best experience using this script.\n\n";

my $simulate = 1;

my $setup = EC2_Setup->new;
my $categories = ["Web Servers + Scripting Languages", "Web Server"];
my $servers_and_langs = [
	"PHP + Apache + MySQL", 
	"PHP + Lighttpd + MySQL", 
	"PHP + Nginx + MySQL", 
	"RubyGems + Rails", 
	"Node JS + NPM"
];

if($simulate == 0) {
	my $update = get_user_yesno("Run software update", 1);
	if($setup->pkg_mgr() eq "apt-get") {
		if($update =~ /y|yes/i) {
			$setup->log_event("Updating aptitude repository...");
			system("apt-get update && apt-get -y upgrade");
			$setup->log_event("Aptitude repository update complete!");
		}
	}
}

my $category_choice = get_user_option(
	"Please type the number of the category of software you wish to install and press [ENTER]:", 
	$categories
);

if($category_choice eq "1") {
	my $server_lang = get_user_option(
		"Please select your preferred scripting language + web server from the list below and press [ENTER]:", 
		$servers_and_langs
	);
	my $option = lc( @$servers_and_langs[$server_lang - 1] );
	$setup->log_event($option . " chosen");

	if($setup->distro() eq "amazon" || $setup->distro() eq "ubuntu") {
		switch($server_lang) {
			case 1 {
				my $apache = get_user_option(
					"Please select your preferred Apache version and press [ENTER]:",
					[
						"Apache 2.2",
						"Apache 2.4"
					]
				);
				my $php = get_user_option(
					"Please select your preferred PHP version and press [ENTER]:",
					[
						"PHP 5.3.x",
						"PHP 5.4.x",
						$setup->pkg_mgr() eq "apt-get" ? "PHP 5.5.x" : ""	# ppa:ondrej/php5-experimental
					]
				);
				my $lamp = "";
				if($setup->pkg_mgr() eq "apt-get") {
					if($apache eq "1") {
						$lamp = "lamp-server^";
					} else {
						my $decision = get_user_yesno(
							colored("Warning: ", "bold yellow") . "You chose to install Apache 2.4. Unfortunately aptitude does not have an official PPA for Apache 2.4. Do you wish to add http://ppa.launchpad.net/ondrej/php5-experimental/ubuntu " . $setup->codename() . " main to your list of repositories",
							1
						);
						if($decision =~ /y|yes/i) {
							add_repo("ppa:ondrej/php5-experimental");
							$lamp = "apache2 php5 php5-cgi php5-mysql php5-mcrypt php5-cli php5-curl php5-gd libapache2-mod-php5 mysql-client-5.5 mysql-server-5.5 mysql-server";
						} else {
							$setup->log_event("User did not want to install Apache 2.4.x...");
							my $decision = get_user_yesno("Install Apache 2.2 instead");
							if($decision =~ /y|yes/i) {
								$setup->log_event("Installing Apache 2.2.x instead...");
								$lamp = "lamp-server^";
							}
						}
					}
					if($simulate == 0) {
						$setup->log_event("Starting LAMP install...");
						system("apt-get -y install " . $lamp);
						$setup->log_event("LAMP install complete!");
					} else {
						print "apt-get -y install " . $lamp . "\n";
					}

					my $secure_mysql = get_user_yesno("Would you like to secure MySQL server", 1);
					if($secure_mysql =~ /y|yes/i) {
						if($simulate == 0) {
							$setup->log_event("Securing MySQL");
							system("mysql_secure_installation");
							$setup->log_event("MySQL has been secured based on user options!");
						} else {
							print "mysql_secure_installation\n";
						}
						print colored("Success: ", "bold green") . "LAMP stack has been installed!\n";
						exit 1;
					} else {
						if($simulate == 0) {
							$setup->log_event("Skipping MySQL hardening...");
						}
						print "Skipping MySQL hardening on user Command\n";
						print colored("Success: ", "bold green") . "LAMP stack has been installed!\n";
						exit 1;
					}
				} # end pkg_mgr apt-get test
			} # end case 1
			case 2 {
				my $php = get_user_option(
					"Please select your preferred PHP version and press [ENTER]:",
					[
						"PHP 5.3.x",										# default
						"PHP 5.4.x", 										# ppa:ondrej/php5
						$setup->pkg_mgr() eq "apt-get" ? "PHP 5.5.x" : ""	# ppa:ondrej/php5-experimental
					]
				);
				my $llmp = "";
				if($setup->pkg_mgr() eq "apt-get") {
					if($php ne "1") {
						my $decision = get_user_yesno("Ubuntu does not officially have a repository for PHP 5.4.x or 5.5.x. Would you like to add one now", 1);
						if($decision =~ /y|yes/i) {
							if($php eq "2") {
								if($simulate == 0) {
									add_repo("ppa:ondrej/php5");
								} else {
									print "Adding ppa:ondrej/php5\n";
								}
							} elsif($php eq "3") {
								if($simulate == 0) {
									add_repo("ppa:ondrej/php5-experimental");
								} else {
									print "Adding ppa:ondrej/php5-experimental\n";
								}
							}
						} else {
							if($simulate == 0) {
								$setup->log_event("Cancelling PHP 5.4.x or 5.5.x install...");
							}
							my $decision = get_user_yesno("Install PHP 5.3.x instead");
							if($simulate == 0) {
								$setup->log_event("Installing PHP 5.3.x instead!");
							}
						}
					}
					$llmp = "lighttpd php5 php5-cgi php5-mysql php5-mcrypt php5-cli php5-curl php5-gd mysql-client-5.5 mysql-server-5.5 mysql-server";
					if($simulate == 0) {
						my $lighttpd_conf = "/etc/lighttpd/lighttpd.conf";
						$setup->log_event("Starting LLMP install...");
						system("apt-get -y install " . $llmp);
						$setup->log_event("LLMP install complete!");
						$setup->log_event("Enabling fastcgi and SSL modules");
						system("lighty-enable-mod fastcgi");
						$setup->log_event("Fastcgi modules enabled!");
						$setup->log_event("Backing up lighttpd.conf file...");
						system("cp " . $lighttpd_conf . " /etc/lighttpd/lighttpd.conf.bak");
						$setup->log_event("Backup found at " . colored("/etc/lighttpd/lighttpd.conf.bak", "bold yellow"));

$setup->log_event("Updating lighttpd.conf file to allow php scripts to run");
open my $handle, ">>", $lighttpd_conf or die $!;
# spacing counts, hence the indentation
print $handle 'fastcgi.server = (
	".php" => ((
		"bin-path" => "/usr/bin/php-cgi",
		"socket" => "/tmp/php.socket"
	))
)'."\n";
close $handle;
$setup->log_event("Log has been updated!");

						$setup->log_event("Restarting Lighttpd");
						system("service lighttpd restart");
					} else {
						print "apt-get -y install " . $llmp . "\n";
						print "lighty-enable-mod fastcgi\n";
					}

					my $secure_mysql = get_user_yesno("Would you like to secure MySQL server", 1);
					if($secure_mysql =~ /y|yes/i) {
						if($simulate == 0) {
							$setup->log_event("Securing MySQL");
							system("mysql_secure_installation");
							$setup->log_event("MySQL has been secured based on user options!");
						} else {
							print "mysql_secure_installation\n";
						}
						print colored("Success: ", "bold green") . "LLMP stack has been installed!\n";
						exit 1;
					} else {
						if($simulate == 0) {
							$setup->log_event("Skipping MySQL hardening...");
						}
						print "Skipping MySQL hardedning on user Command\n";
						print colored("Success: ", "bold green") . "LLMP stack has been installed!\n";
						exit 1;
					}
				} # end pkg_mgr apt-get test
			} # end case 2
			case 3 {

			} # end case 3
			case 4 {

			} # end case 4
			case 5 {

			} # end case 5
		}
	}
}

# GENERAL HELPER FUNCTIONS
# ----------------------------------------------------------------- #
sub harden_mysql {
	my $stack 			= shift;
	my $secure_mysql 	= get_user_yesno("Would you like to secure MySQL server", 1);

	if($secure_mysql =~ /y|yes/i) {
		if($simulate == 0) {
			$setup->log_event("Securing MySQL");
			system("mysql_secure_installation");
			$setup->log_event("MySQL has been secured based on user options!");
		} else {
			print "mysql_secure_installation\n";
		}
		print colored("Success: ", "bold green") . $stack . " stack has been installed!\n";
		exit 1;
	} else {
		if($simulate == 0) {
			$setup->log_event("Skipping MySQL hardening...");
		}
		print "Skipping MySQL hardedning on user Command\n";
		print colored("Success: ", "bold green") . $stack . " stack has been installed!\n";
		exit 1;
	}
}

sub get_user_option {
	my $question 		= shift;
	my $options 		= shift;
	my $custom_error	= shift;
	print $question . "\n";
	for(my $i = 0; $i < @{ $options }; $i++) {
		print (($i + 1) . ". " . @$options[$i] . "\n");
	}
	my $answer = <>;
	chomp($answer);
	while($answer !~ /[0-9]{1,}/ || ($answer < 1 || $answer > @{ $options })) {
		if(!defined $custom_error) {
			print colored("Error: ", "bold red") . "Input must be a number between 1 and " . @{ $options } . ". Please try again.\n";
		} else {
			print $custom_error . "\n";
		}
		$answer = <>;
		chomp($answer);
	}

	return $answer;
}

sub get_user_yesno {
	my $question		= shift;
	my $noexit			= shift;
	print $question . ": [Y/n]\n";
	my $answer = <>;
	chomp($answer);
	while($answer !~ /y|n|yes|no/i) {
		print colored("Warning: ", "bold yellow") . "Input must be either of the following: y, n, yes, or no. Case does not matter.\n";
		$answer = <>;
		chomp($answer);
	}
	if($answer =~ /n|no/i && $noexit == 0) {
		print "Exiting on user Command\n";
		exit 0;
	} elsif($answer =~ /n|no/i && $noexit != 0) {
		print "Skipping on user Command\n";
	}

	return $answer;
}

sub add_repo {
	my $repo 		= shift;
	if($setup->pkg_mgr() ne "apt-get") {
		print "Not necessary for yum manager, skipping...";
	} else {
		if($simulate == 0) {
			$setup->log_event("Backing up /etc/apt/sources.list file just in case.");
			system("cp /etc/apt/sources.list /etc/apt/sources.list.bak");
			system("apt-get -y install python-software-properties");
			$repo = ($repo !~ /^ppa:/i) ? ("ppa:" . $repo) : $repo;
			$setup->log_event("Adding " . $repo . " to sources.list");
			system("add-apt-repository " . $repo);
			$setup->log_event("Updating sources list...");
			system("apt-get update");
			$setup->log_event("Sources list update complete, resuming...");
		} else {
			$repo = ($repo !~ /^ppa:/i) ? ("ppa:" . $repo) : $repo;
			print "Adding " . $repo . "\n";
		}
	}

	return $repo;
}

# EC2_Setup PACKAGE
# ----------------------------------------------------------------- #
package EC2_Setup;

sub new {
	my $class 	= shift;
	my $self 	= {};
	bless $self, $class;

	# make log
	$self->create_log();

	# set distro
	$self->set_os_details();

	return $self;
}

sub create_log {
	system("touch ~/ec2_setup.log"); # create the log
	system("echo \"EC2 Setup Started at: \"" . localtime() . " >> ~/ec2_setup.log");
	return 1;
}

sub log_event {
	my $self 			= shift;
	my $msg				= shift;
	if ( defined $msg ) {
		$self->{msg} = $msg;
	}
	return system("echo \"" . $self->{msg} . " " . localtime() . "\" >> ~/ec2_setup.log");
}

sub finish_log {
	system("echo \"EC2 Setup Completed at: \"" . localtime() . " >> ~/ec2_setup.log");
}

sub distro {
	my $self 			= shift;
	my $distro 			= shift;
	if ( defined $distro ) {
		$self->{distro} = $distro;
	}
	return $self->{distro};
}

sub pkg_mgr {
	my $self 			= shift;
	my $package 		= shift;
	if ( defined $package ) {
		$self->{pkg_mgr} = $package;
	}
	return $self->{pkg_mgr};
}

sub codename {
	my $self 			= shift;
	my $codename 		= shift;
	if ( defined $codename ) {
		$self->{codename} = $codename;
	}
	return $self->{codename};
}

sub option {
	my $self 			= shift;
	my $option 			= shift;
	if ( not exists $self->{option} ) {
		$self->{option} = [];
	}
	if ( defined $option ) {
		push @{ $self->{option} }, $option;
	}
	my @array = @{ $self->{option} };
	return wantarray ? @array : \@array;
}

sub set_category {
	my $self 			= shift;
	my $category 		= shift;
	if( not exists $self->{category} ) {
		$self->{category} = [];
	}
	if( defined $category ) {
		push @{ $self->{category} }, $category;
	}
	return 1;
}

sub get_category {
	my $self 			= shift;
	my $category 		= shift;
	my @array = @{ $self->{category} };
	return wantarray ? @array : \@array;	
}

sub set_os_details {
	my $self 			= shift;
	my $version 		= `cat /etc/*-release`;
	my @v_info 			= split("\n", $version);
	if(scalar(@v_info) > 1) {
		# check matches (e.g. ubuntu)
		if($v_info[4] =~ /ubuntu/i) {
			$self->{distro} = "ubuntu";
			$self->{pkg_mgr} = "apt-get";
			# prep codename
			my @codename = split("=", $v_info[2]);
			$self->{codename} = $codename[1];
		}
	} else {
		# check matches (e.g. amazon ami)
		if($version =~ /amazon/i) {
			$self->{distro} = "amazon";
			$self->{pkg_mgr} = "yum";
		}
	}
	return 1;
}