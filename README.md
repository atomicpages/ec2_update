EC2 Setup
=========

Welcome to the EC2 Setup script! Installing software on a new Linux EC2 instance can be cumbersome and obnoxious. If you're used to package managers such as aptitude and all of a sudden you have to deal with yum, you might be scratching your head. EC2 Setup script takes the hassle out of installing common software such as:

* Apache
* PHP
* Nginx
* NodeJS
* Rails
* LAMP Stacks (Linux Apache MySQL PHP)
* LLMP Stacks (Linux Lighttpd MySQL PHP)
* LNMP/LEMP Stacks (Linux "Engine-X" Nginx MySQL PHP)
* and much more!

## TL;DR

The EC2 Setup script is written entirely in Perl. Why Perl? Perl comes with every Linux box that I've ever seen be it Arch Linux, Amazon Linux AMI, or Salix OS. If you are using one of the Linux distributions from AWS, then you'll have Perl installed! The EC2 Setup script is entirely command-line driven which minimizes the amount of software you need to install on your EC2 instance. In fact, it's so minimal all you need to do is download the script and run it!

### EC2 Setup Features
* Automatic distro detection
* Automatic package manager detection
* Easy software installation
* Easy LAMP, LNMP/LEMP, LLMP stack installation
* Verbose log found in `~/ec2_setup.log`
* Easy to use command line interface

### Available Software
EC2 Setup comes with four main categories of software:

1. Stacks
	* LAMP
	* LLMP
	* LNMP/LEMP
	* Ruby + RubyGems + Rails
	* Node.js + NPM
2. Web Servers
	* Apache 2.2.x
	* Apache 2.4.x
	* Lighttpd 1.4.28
	* Lighttpd 1.4.32
	* Nginx 1.1.x
	* Nginx 1.4.x
3. Databases
	* [MySQL](http://www.mysql.com/)
	* [PostgreSQL](http://www.postgresql.org/)
	* [MongoDB](http://www.mongodb.org/)
	* [Redis](http://redis.io)
	* [CouchDB](http://couchdb.apache.org/)
5. Miscellaneous Software 
	* [Varnish Cache](https://www.varnish-cache.org/)
	* [Memcached](http://memcached.org/)
	* [APC](http://www.php.net/manual/en/intro.apc.php)
	* [Composer](http://getcomposer.org/)
	* [phpMyAdmin](http://www.phpmyadmin.net/home_page/index.php)
	* [pgAdmin](http://www.pgadmin.org/)

### Installing EC2 Setup
Installing EC2 Setup is a matter of running a few terminal commands. If you are unfamiliar with basic BASH commands, fret not. Take the time to become acquainted with BASH. There are many free resources such as:

* [tldp.org](http://tldp.org/LDP/abs/html/basic.html)
* [lifehacker.com](http://lifehacker.com/5633909/who-needs-a-mouse-learn-to-use-the-command-line-for-almost-anything)
* [Ubuntu Community](https://help.ubuntu.com/community/Beginners/BashScripting)

#### Using `git`
```
git clone https://github.com/atomicpages/ec2_setup.git
```

**Note:** if `git` is not installed then you'll need to install it!

##### Ubuntu
```
sudo apt-get install git
```

##### Amazon Linux AMI
```
sudo yum install git
```

##### RedHat
```
sudo yum install git
```
 
#### Using `wget`

```
wget https://raw.github.com/atomicpages/ec2_update/master/ec2_setup.pl
```

### Running EC2 Setup

## Find an Issue?
If you found an issue feel free to:

* [Submit a pull request](https://github.com/atomicpages/ec2_update)
* [Create an issue](https://github.com/atomicpages/ec2_update/issues)

## Authors
* [Dennis Thompson](http://dennis-thompson.com)
* [AtomicPages LLC](http://www.atomicpages.net)

## Contributors