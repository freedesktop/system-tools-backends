#-*- Mode: perl; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

# DBus object for the Groups list
#
# Copyright (C) 2005 Carlos Garnacho
#
# Authors: Carlos Garnacho Parro  <carlosg@gnome.org>
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

package GroupsConfig;

use base qw(Net::DBus::Object);
use Net::DBus::Exporter ($Utils::Backend::DBUS_PREFIX);
use Utils::Backend;
use Users::Groups;
use Users::Users;

my $OBJECT_NAME = "GroupsConfig";
my $OBJECT_PATH = "$Utils::Backend::DBUS_PATH/$OBJECT_NAME";

sub new
{
  my $class   = shift;
  my $service = shift;
  my $self    = $class->SUPER::new ($service, $OBJECT_PATH);

  bless $self, $class;

  Utils::Monitor::monitor_files (&Users::Groups::get_files (),
                                 $self, $OBJECT_NAME, "changed");
  return $self;
}

dbus_method ("get", [], [[ "array", [ "struct", "string", "string", "int32", [ "array", "string" ]]], "int32", "int32" ]);
dbus_method ("set", [[ "array", [ "struct", "string", "string", "int32", [ "array", "string" ]]], "int32", "int32" ], []);
dbus_signal ("changed", []);

sub get
{
  my ($self) = @_;
  my $groups, $logindefs;

  $groups = Users::Groups::get ();
  $logindefs = &Users::Users::get_logindefs ();

  return ($groups, $$logindefs{"gmin"}, $$logindefs{"gmax"});
}

sub set
{
  my ($self, $config) = @_;

  Users::Groups::set ($config);
}

1;