#-*- Mode: perl; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

# Hosts Configuration handling
#
# Copyright (C) 2000-2001 Ximian, Inc.
#
# Authors: Hans Petter Jansson <hpj@ximian.com>
#          Carlos Garnacho     <carlosg@gnome.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.

package Network::Hosts;

sub get_fqdn_parse_table
{
  my %dist_map =
	 (
    "redhat-5.2"   => "redhat-6.2",
	  "redhat-6.0"   => "redhat-6.2",
	  "redhat-6.1"   => "redhat-6.2",
	  "redhat-6.2"   => "redhat-6.2",
	  "redhat-7.0"   => "redhat-6.2",
	  "redhat-7.1"   => "redhat-6.2",
	  "redhat-7.2"   => "redhat-7.2",
    "redhat-8.0"   => "redhat-7.2",
    "redhat-9"     => "redhat-7.2",
	  "openna-1.0"   => "redhat-6.2",
	  "mandrake-7.1" => "redhat-6.2",
	  "mandrake-7.2" => "redhat-6.2",
    "mandrake-9.0" => "redhat-6.2",
    "mandrake-9.1" => "redhat-6.2",
    "mandrake-9.2" => "redhat-6.2",
    "mandrake-10.0" => "redhat-6.2",
    "mandrake-10.1" => "redhat-6.2",
    "blackpanther-4.0" => "redhat-6.2",
    "conectiva-9"  => "redhat-6.2", 
    "conectiva-10" => "redhat-6.2", 
    "debian-2.2"   => "debian-2.2",
    "debian-3.0"   => "debian-2.2",
    "debian-sarge" => "debian-2.2",
    "suse-9.0"     => "suse-9.0",
    "suse-9.1"     => "suse-9.0",
	  "turbolinux-7.0"  => "redhat-7.0",
    "pld-1.0"      => "redhat-6.2",
    "pld-1.1"      => "redhat-6.2",
    "pld-1.99"     => "redhat-6.2",
    "fedora-1"     => "redhat-7.2",
    "fedora-2"     => "redhat-7.2",
    "fedora-3"     => "redhat-7.2",
    "specifix"     => "redhat-7.2",
    "vine-3.0"     => "redhat-6.2",
    "vine-3.1"     => "redhat-6.2",
    "slackware-9.1.0" => "suse-9.0",
    "slackware-10.0.0" => "suse-9.0",
    "slackware-10.1.0" => "suse-9.0",
    "gentoo"       => "gentoo",
    "freebsd-5"    => "freebsd-5",
    "freebsd-6"    => "freebsd-5",
	  );

  my %dist_tables =
    (
     "redhat-6.2" =>
     {
       fn =>
       {
         SYSCONFIG_NW => "/etc/sysconfig/network",
         RESOLV_CONF  => "/etc/resolv.conf"
       },
       table =>
       [
        [ "hostname", \&Utils::Parse::get_sh, SYSCONFIG_NW, HOSTNAME ],
        [ "domain",   \&Utils::Parse::split_first_str, RESOLV_CONF, "domain", "[ \t]+" ]
       ]
     },

     "redhat-7.2" =>
     {
       fn =>
       {
         SYSCONFIG_NW => ["/etc/sysconfig/networking/profiles/default/network",
                          "/etc/sysconfig/networking/network",
                          "/etc/sysconfig/network"],
         RESOLV_CONF  => ["/etc/sysconfig/networking/profiles/default/resolv.conf",
                          "/etc/resolv.conf"],
       },
       table =>
       [
		    [ "hostname", \&Utils::Parse::get_sh, SYSCONFIG_NW, HOSTNAME ],
		    [ "domain",   \&Utils::Parse::split_first_str, RESOLV_CONF, "domain", "[ \t]+" ],
		   ]
     },

     "debian-2.2" =>
     {
       fn =>
       {
         RESOLV_CONF => "/etc/resolv.conf",
         HOSTNAME    => "/etc/hostname",
       },
       table =>
       [
        [ "hostname", \&Utils::Parse::get_first_line, HOSTNAME ],
        [ "domain",	\&Utils::Parse::split_first_str, RESOLV_CONF, "domain", "[ \t]+" ]
       ]
     },

     "suse-9.0" =>
     {
       fn =>
       {
         RESOLV_CONF  => "/etc/resolv.conf",
         HOSTNAME     => "/etc/HOSTNAME",
       },
       table =>
       [
        [ "hostname", \&Utils::Parse::get_fq_hostname, HOSTNAME ],
        [ "domain", \&Utils::Parse::get_fq_domain, HOSTNAME ],
        [ "domain", \&Utils::Parse::split_first_str, RESOLV_CONF, "domain", "[ \t]+" ],
       ]
     },
    
     "gentoo" =>
     {
       fn =>
       {
         HOSTNAME    => "/etc/hostname",
         DOMAINNAME  => "/etc/dnsdomainname",
         RESOLV_CONF => "/etc/resolv.conf",
       },
       table =>
       [
        [ "hostname", \&Utils::Parse::get_first_line, HOSTNAME ],
        [ "domain", \&Utils::Parse::get_first_line, DOMAINNAME ],
        [ "domain", \&Utils::Parse::split_first_str, RESOLV_CONF, "domain", "[ \t]+" ],
       ]
     },

     "freebsd-5" =>
     {
       fn =>
       {
         RC_CONF     => "/etc/rc.conf",
         RESOLV_CONF => "/etc/resolv.conf",
       },
       table =>
       [
        [ "hostname", \&Utils::Parse::get_sh_re, RC_CONF, hostname, "^([^\.]*)\." ],
        [ "domain", \&Utils::Parse::split_first_str, RESOLV_CONF, "domain", "[ \t]+" ],
       ]
     },
   );

  my $dist = $dist_map{$Utils::Backend::tool{"platform"}};
  return %{$dist_tables{$dist}} if $dist;

  &Utils::Report::do_report ("platform_no_table", $Utils::Backend::tool{"platform"});
  return undef;
}

sub get_fqdn
{
  my %dist_attrib;
  my $hash;

  %dist_attrib = &get_fqdn_parse_table ();

  $hash = &Utils::Parse::get_from_table ($dist_attrib{"fn"},
                                 $dist_attrib{"table"});

  return ($$hash {"hostname"}, $$hash{"domain"});
}

sub get
{
  my ($statichosts, @arr);

  $statichosts = &Utils::Parse::split_hash ("/etc/hosts", "[ \t]+", "[ \t]+");

  foreach $i (sort keys %$statichosts)
  {
    push @arr, [$i, $$statichosts{$i}];
  }

  return \@arr;
}

sub get_dns
{
  my (@dns);

  @dns = &Utils::Parse::split_all_unique_hash_comment ("/etc/resolv.conf", "nameserver", "[ \t]+");

  return @dns;
}

sub get_search_domains
{
  my (@search_domains);

  @search_domains = &Utils::Parse::split_first_array_unique ("/etc/resolv.conf", "search", "[ \t]+", "[ \t]+");

  return @search_domains;
}

sub set
{
  my (@config) = @_;
  my ($i, %hash);

  foreach $i (@config)
  {
    $hash{$i[0]} = $i[1];
  }

  &Utils::Replace::join_hash ("/etc/hosts", "[ \t]+", "[ \t]+", %hash);
}

sub set_dns
{
  my (@dns) = @_;

  &Utils::Replace::join_all ("/etc/resolv.conf", "nameserver", "[ \t]+", @dns);
}

sub set_search_domains
{
  my (@search_domains) = @_;

  &Utils::Replace::join_first_array ("/etc/resolv.conf", "search",
                                     "[ \t]+", "[ \t]+", @search_domains);
}

1;