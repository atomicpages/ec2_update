EC2 Setup
=========

Welcome to the EC2 Setup script! Installing software on a new linux EC2 instance can be cumbersome and obnoxious. If you're used to package managers such as aptitude and all of a sudden you have to deal with yum, you might be scratching your head. EC2 Setup script takes the hassle out of installing common software such as:

* Apache
* PHP
* Nginx
* NodeJS
* Rails
* and much more...

## TL;DR

The EC2 Setup script is written entirely in Perl. This reason why is because every free-tier linux AMI has Perl version 5 .something installed on it right out of the box. Other scripting languages like Python may change drastically from version to version and I don't possess the elegance to do this in BASH (or any variant of it).

### EC2 Setup Features
* Automatic distro detection
* Automatic package manager detection
* Easy software installation
* Easy LAMP, LNMP, LLMP stack installation
* Verbose log found in `~/ec2_setup.log`

### Available Software
##### Stacks
* LAMP Stacks (Linux Apache MySQL PHP)
	* Apache 2.2.x + PHP 5.3.x
	* Apache 2.4.x + PHP 5.4.x
	* MySQL 5.5
* LNMP Stacks (Linux Nginx MySQL PHP)
	* Nginx ? + PHP ?
	* MySQL 5.5
* LLMP Stacks (Linux Lighttpd MySQL PHP)
	* Lighttpd ? + PHP ?
	* MySQL 5.5
* NodeJS + NPM
	* NodeJS ?
	* NPM ?
* Ruby + Ruby Gems + Rails
	* Ruby ?
	* Ruby Gems ?
	* Rails ?

##### Web Servers
* Apache
	* Apache 2.2.x
	* Apache 2.4.x
* Nginx
* Lighthttpd
* Tornado
* Yaws
* Jetty
	* Jetty 7
	* Jetty 8
	* Jetty 9
* Tomcat
	* Tomcat 6
	* Tomcat 7

##### Miscellaneous
* Memcached ?
* Redis ?
* Varnish Cache ?
* phpMyAdmin ?

##### SQL Clients + Servers
* MySQL 5.5
* Postgres SQL ?
* SQLite 3

### Installing EC2 Setup
Installing EC2 Setup is a matter of running a few terminal commands. If you are unfamiliar with basic BASH commands, fret not. Take the time to become acquainted with BASH. There are many free resources such as:

* [tldp.org](http://tldp.org/LDP/abs/html/basic.html)
* [lifehacker.com](http://lifehacker.com/5633909/who-needs-a-mouse-learn-to-use-the-command-line-for-almost-anything)
* [Ubuntu Community](https://help.ubuntu.com/community/Beginners/BashScripting)

#### Using `git`
 
#### Using `wget`

## Authors
* [Dennis Thompson](http://dennis-thompson.com)
* [AtomicPages LLC](http://www.atomicpages.net)