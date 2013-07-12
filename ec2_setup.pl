#! /usr/bin/env perl
# version 0.6.7.2

use warnings;
use strict;
use feature qw(say);
use Switch;
use Term::ANSIColor;
use Data::Dumper;

print colored("Welcome to the Linux AMI startup script.", "bold") . " Follow the directions and 
the script will guide you to installing stacks and servers on your new EC2 
instance.\n\n";

print colored("Disclaimer: ", "bold yellow") . "This script does the best to prevent unwarranted software 
installation. We do our best to keep this script updated. We are in no way responsible
for the misuse of or the altercation of this script. Only download from the official 
repository in order to have the best experience using this script.\n\n";

# print "Please type the number of the category of software you wish to install and press [ENTER]: \n";

my $setup = EC2_Setup->new;
my $categories = ["Web Servers + Scripting Languages", "Web Server"];
my $servers_and_langs = ["PHP + Apache + MySQL", "PHP + Lighttpd + MySQL", "PHP + Nginx + MySQL", "RubyGems + Rails", "Node JS + NPM"];
my $servers = ["Apache", "Lighttpd", "Nginx", "Tornado", "Yaws", "Jetty", "Tomcat"];
my $misc = ["phpMyAdmin", "Memcached", "APC", "Varnish Cache", "Redis", "Composer"];
my $databases = ["MongoDB", "MySQL", "PostgreSQL", "SQLite", "CouchDB"];
# Need to compile from source on Amazon Linux
# MongoDB
# CouchDB

my $update = get_user_yesno("Run software update", 1);
if($setup->pkg_mgr() eq "apt-get") {
	if($update =~ /y|yes/i) {
		$setup->log_event("Updating aptitude repository...");
		system("sudo apt-get update && sudo apt-get -y upgrade");
		$setup->log_event("Aptitude repository update complete!");
	}
}
if($setup->pkg_mgr() eq "yum") {
	if($update =~ /y|yes/i) {
		$setup->log_event("Updating yum repository...");
		system("sudo yum -y update");
		$setup->log_event("Yum update complete!");
	}
}

my $category_choice = &get_user_option(
	"Please type the number of the category of software you wish to install and press [ENTER]:", 
	$categories
);

if($category_choice eq "1") {
	my $server_lang = &get_user_option(
		"Please select your preferred scripting language + web server from the list below and press [ENTER]:", 
		$servers_and_langs
	);
	my $option = lc( @$servers_and_langs[$server_lang - 1] );
	$setup->log_event($option . " chosen");

	if($setup->distro() eq "amazon" || $setup->distro() eq "ubuntu") {
		switch($server_lang) {
			case 1 	{
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
					]
				);
				my $lamp = "";
				if($setup->pkg_mgr() eq "yum") {
					$apache = ($apache eq "1") ? "httpd" : "httpd24";
					$php = ($php eq "1") ? "php" : "php54";

					$lamp = "aspell aspell-en aspell-fr aspell-es cvs " . $apache . " mysql mysql-server " . $php . " " . $php . "-cli " . $php . "-gd php-intl " . $php . "-mbstring " . $php . "-mysql " . $php . "-pdo " . $php . "-soap " . $php . "-xml " . $php . "-xmlrpc " . $php . "-pspell";
					$setup->log_event("Starting LAMP installation...");
					system($lamp);
					$setup->log_event("LAMP install complete!");
					$setup->log_event("Adding Apache and MySQL to startup...");
					system("sudo /sbin/chkconfig httpd on");
					system("sudo /sbin/chkconfig mysqld on");
					$setup->log_event("Starting Apache and MySQL");
					system("sudo service httpd start");
					system("sudo service mysqld start");
					print "Setting up MySQL root user. Please enter a new MySQL admin password and press [ENTER]:\n";
					my $mysql_pass = <>;
					chomp($mysql_pass);
					system("sudo mysqladmin -u root -p '" . $mysql_pass . "'");
				} else { # assume aptitude for the time being
					my $apt_apache_install = &get_user_option(
						"Select how you'd like you install Apache and press [ENTER]:",
						[
							"Tasksel",
							"Aptitude Repository"
						]
					);
					if($apt_apache_install eq "1") {
						# using tasksel by default gives:
						# installs Apache 2.2.22
						# installs PHP 5.3.10
						# as of 7/11/2013
						$setup->log_event("user selected to use Tasksel to install LAMP stack");
						system("sudo tasksel install lamp-server");
						$setup->log_event("Install complete!");
					} else {
						if($apache eq "2") {
							my $decision = &get_user_yesno(
								colored("Warning: ", "bold yellow") . "You chose to install Apache 2.4. Unfortunately aptitude does not have an official PPA for Apache 2.4. Do you wish to add http://ppa.launchpad.net/rhardy/apache24x/ " . $setup->codename() . " main to your list of repositories"
							);
							if($decision =~ /y|yes/i) {
								add_repo("ppa:rhardy/apache24x");
							}
						}
						$setup->log_event("User selected to use Aptitude to install LAMP stack");
						my $lamp = "apache2 apache2-mpm-prefork apache2-utils libapr1 libaprutil1 libdbd-mysql-perl libdbi-perl libnet-daemon-perl libplrpc-perl libpq5 mysql-client-5.5 mysql-common mysql-server mysql-server-5.5 php5 php5-cgi php5-common php5-mysql php5-cli";
						system("sudo apt-get -y install " . $lamp);
						system("sudo service start apache2");
					}
				}
			}
			case 2 	{
				my $php = get_user_option(
					"Please select your preferred PHP version and press [ENTER]:",
					[
						"PHP 5.3.x",
						"PHP 5.4.x",
					]
				);
				my $llmp = "";
				if($setup->distro() eq "ubuntu") {
					if($php eq "2") {
						my $decision = &get_user_yesno(
							colored("Warning: ", "bold yellow") . "You chose to install PHP 5.4.x. Unfortunately aptitude does not have an official PPA for PHP 5.4.x. Do you wish to add https://launchpad.net/~ondrej/+archive/php5 " . $setup->codename() . " main to your list of repositories"
						);
						if($decision =~ /y|yes/i) {
							add_repo("ppa:ondrej/php5");
						}
					}
					$llmp = "lighttpd php5 php5-mysql php5-cli php5-gd php5-cgi php5-mcrypt";
				} else {
					$llmp = "lighttpd lighttpd-fastcgi mysql55 mysql55-server";
				}
				$setup->log_event("Starting LLMP Install...");
				system("sudo apt-get install " . $llmp);
				$setup->log_event("Enabling fastcgi module...");
				system("sudo lighty-enable-mod fastcgi");
				$setup->log_event("Enabling fastcgi-php module...");
				system("sudo lighty-enable-mod fastcgi-php");
				$setup->log_event("Restarting Lighttpd");
				system("sudo service lighttpd force-reload");
				$setup->log_event("LLMP install complete!");
			}
			case 3 	{ }
			case 4 	{ }
			case 5 	{ }
			# else 	{ }
		}
	}
	# print "You chose " . $server_lang . "\n";
} elsif($category_choice eq "2") {
	my $server = &get_user_option(
		"Please type the number of the web server you wish to install from the list below and press [ENTER]:",
		$servers
	);
	my $option = lc( @$servers[$server - 1] );
	$setup->log_event($option . " chosen!");
	# shared installs
	if($setup->distro() eq "amazon" || $setup->distro() eq "ubuntu") {
		switch($server) {
			case 1 {
				$setup->log_event("Starting Apache installation...");
				my $apache = &get_user_option(
					"Please select your preferred Apache version and press [ENTER]:",
					[
						"Apache 2.2", 
						"Apache 2.4"
					]
				);
				if($apache eq "1") {
					$apache = ( ($setup->pkg_mgr() eq "apt-get") ? "apache2" : "httpd" );
					$setup->log_event("Starting Apache 2.2.x installation...");
					system("sudo " . $setup->pkg_mgr() . " -y install " . $apache);
					$setup->log_event("Attempting to start Apache 2.2.x...");
					system("sudo service " . $apache . " start");
					$setup->log_event("Apache 2.2.x install complete!");
				} elsif($apache eq "2") {
					if($setup->pkg_mgr() eq "apt-get") {
						my $decision = &get_user_yesno(
							colored("Warning: ", "bold yellow") . "You chose to install Apache 2.4. Unfortunately aptitude does not have an official PPA for Apache 2.4. Do you wish to add http://ppa.launchpad.net/rhardy/apache24x/ " . $setup->codename() . " main to your list of repositories"
						);
						if($decision =~ /y|yes/i) {
							add_repo("ppa:rhardy/apache24x");
							$setup->log_event("Installing Apache 2.4.x...");
							system("sudo apt-get -y install apache2");
							$setup->log_event("Attempting to start Apache 2.4.x....");
							system("sudo service apache2 start");
							$setup->log_event("Apache 2.4.x install complete!");
						}
					} else { # assume yum for now
						$setup->log_event("Starting Apache 2.4.x installation...");
						system("sudo yum -y install httpd24");
						$setup->log_event("Adding Apache 2.4 to startup...");
						system("sudo /sbin/chkconfig httpd on");
						$setup->log_event("Attempting to start Apache 2.4.x...");
						system("sudo /sbin/service httpd start");
						$setup->log_event("Apache 2.4.x install complete!");
					}
				}
			}
			case 2 {
				$setup->log_event("Starting Lighttpd installation...");
				system("sudo " . $setup->pkg_mgr() . " -y lighttpd " . ($setup->distro() eq "amazon" ? "lighttpd-fastcgi" : ""));
				$setup->log_event("Attempting to start Lighttpd...");
				system("sudo service lighttpd start");
				$setup->log_event("Lighttpd install complete!");
			}
			case 3 {
				# based on https://www.digitalocean.com/community/articles/how-to-install-nginx-on-ubuntu-12-04-lts-precise-pangolin
				$setup->log_event("Starting Nginx installation...");
				system("sudo " . $setup->pkg_mgr() . " -y install nginx");
				$setup->log_event("Attempting to start Nginx...");
				system("sudo service nginx start");
				$setup->log_event("Nginx install complete!");
			}
			case 4 	{
				$setup->log_event("Starting Installation of Tornado web server...");
				# compatible version are 2.6, 2.7, 3.2, and 3.3
				# TODO test to make sure the proper version of python exists via python -V
				$setup->log_event("A little housekeeping first, let's install pip (python package index)");
				system("sudo " . $setup->pkg_mgr() . " -y install python-pip");
				$setup->log_event("Using pip to install Tornado!");
				system("sudo pip install tornado");
				$setup->log_event("Tornado install complete!");
			}
			case 7 	{
				$setup->log_event("Starting Tomcat install...");
				my $tomcat = &get_user_option(
					"Choose Tomcat 6 or Tomcat 7 and press [ENTER]:",
					[
						"Tomcat 6",
						"Tomcat 7"
					]
				);
				$setup->log_event("Installing java if it's not installed already since Tomcat depends on Java.");
				system("sudo " . $setup->pkg_mgr() . " -y install " . ($setup->distro() eq "ubuntu" ? "openjdk-6-jdk" : "java-1.6.0-openjdk"));
				if($setup->distro() eq "ubuntu") {
					system("JAVA_HOME=/usr/lib/jvm/java*"); # not necessary on amazon linux
				}
				if($tomcat eq "1") {
					$setup->log_event("Starting Tomcat 6 installation...");
					system("sudo " . $setup->pkg_mgr() . " -y install tomcat6 tomcat6-docs");
					$setup->log_event("Tomcat 6 install complete!");
				} elsif($tomcat eq "2") {
					$setup->log_event("Starting Tomcat 7 installation...");
					system("sudo " . $setup->pkg_mgr() . " -y install tomcat7 tomcat7-docs");
					$setup->log_event("Tomcat 7 install complete!");
				}
			}
			else { }
		}
	}
	if($setup->distro() eq "amazon") {
		switch($server) {
			case 5 	{
				print colored("Warning: ", "bold yellow") . "We're sorry, support for installing Yaws server on Amazon Linux is currently not supported :(\n";
				$setup->log_event("Yaws has no auto-installer for Amazon Linux yet :(");
				# $setup->log_event("Starting Yaws installation...");
				# $setup->log_event("Installing Yaws dependencies...");
				# system("sudo yum install erlang git");
				# $setup->log_event("Grabbing Yaws from github...");
				# system("git clone git://github.com/klacke/yaws.git");
				# system("cd yaws");
			}
			case 6 	{ }
			case 7 	{ }
			else	{ }
		}
	}
	if($setup->distro() eq "ubuntu") {
		switch($server) {
			case 5 	{
				my $proceed = &get_user_yesno(
					colored("Warning: ", "bold yellow") . "this has NOT been tested. Use at your own risk! Proceed"
				);
				if($proceed =~ /y|yes/i) {
					$setup->log_event("Starting Yaws Install...");
					$setup->log_event("Installing Yaws dependencies...");
					system("sudo apt-get -y install erlang erlang-nox erlang-src erlang-manpages erlang-mode erlang-dev");
					$setup->log_event("Installing Yaws...");
					system("sudo apt-get -y install yaws");
					$setup->log_event("Yaws install complete!");
					print colored("Yaws install complete!", "green");
				}
			}
			case 6 	{
				$setup->log_event("Starting Jetty install...");
				my $jetty = &get_user_option(
					"Choose the version of jetty and press [ENTER]:",
					[
						"Jetty 7",
						"Jetty 8",
						"Jetty 9"
					]
				);
				# TOTO: test to see if java is already installed
				# $setup->log_event("Installing java if it's not installed already since Jetty depends on Java.");
				# system("sudo apt-get -y install openjdk-7-jdk");
				if($jetty eq "1") {
					$jetty = "7";
					$setup->log_event("Installing Jetty 7!");
					system("sudo apt-get -y install jetty");
					$setup->log_event("Jetty 7 install complete!");
					print colored("Jetty 7 install complete!", "green");
					# TODO test to see if the below is created automatically using apt-get
				} elsif ($jetty eq "2") {
					$jetty = "8";
					$setup->log_event("Installing Jetty 8!");
					system("sudo apt-get -y install jetty8");
					$setup->log_event("Jetty 8 install complete!");
					print colored("Jetty 8 install complete!", "green");
					# TODO test to see if the below is created automatically using apt-get
				} elsif($jetty eq "3") {
					$jetty = "9";
					$setup->log_event("Jetty 9 is not officially in the Ubuntu repository. We must download and install manually.");
					my $confirm = &get_user_yesno(
						"Jetty 9 is not in the official Ubuntu repository. Continue? "
					);
					if($confirm =~ /y|yes/i) {
						system("cd /usr/local/src");					
						system("sudo wget http://www.gtlib.gatech.edu/pub/eclipse/jetty/stable-9/dist/jetty-distribution-9.0.4.v20130625.tar.gz");
						system("sudo tar xvfz jetty-distribution-9.0.4.v20130625.tar.gz");
						system("sudo mv jetty-distribution-9.0.4.v20130625 /opt/jetty");
						system("sudo cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty");
						$setup->log_event("Create Jetty user");
						system("sudo useradd jetty -U -s /bin/false");
						system("sudo chown -R jetty:jetty /opt/jetty");
						$setup->log_event("Create Jetty config file at /etc/default/jetty");
						system("sudo touch /etc/default/jetty");
						system('sudo echo "JETTY_USER=jetty" >> /etc/default/jetty && sudo echo "JETTY_PORT=8080" >> /etc/default/jetty');
						$setup->log_event("Attempting to start Jetty server...");
						system("sudo /etc/init.d/jetty start");
						print colored("Jetty 9 install complete!", "green");
						# TODO test to see if server start was successful
					}
				}
				$setup->log_event("Jetty " . $jetty . " install complete!");
			}
			else { }
		}
	}
	# print "You chose: " . $server . "\n";
} else {
	print colored("Invalid option supplied. Aborting.", "red"), "\n";
	exit 0;
}

$setup->finish_log();

# print Dumper($setup);

# GENERAL HELPER FUNCTIONS
# ----------------------------------------------------------------- #
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
		$setup->log_event("Backing up /etc/apt/sources.list file just in case.");
		system("sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak");
		$setup->log_event("Installing python-software-properties");
		system("sudo apt-get -y install python-software-properties");
		$repo = ($repo !~ /^ppa:/i) ? ("ppa:" . $repo) : $repo;
		$setup->log_event("Adding " . $repo . " to sources.list");
		system("sudo add-apt-repository " . $repo);
		$setup->log_event("Updating sources list...");
		system("sudo apt-get update");
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
