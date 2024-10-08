# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ruby-single.eclass
# @MAINTAINER:
# Ruby team <ruby@gentoo.org>
# @AUTHOR:
# Author: Hans de Graaff <graaff@gentoo.org>
# Based on python-single-r1 by: Michał Górny <mgorny@gentoo.org>
# @SUPPORTED_EAPIS: 4 5 6 7
# @BLURB: An eclass for Ruby packages not installed for multiple implementations.
# @DESCRIPTION:
# An eclass for packages which don't support being installed for
# multiple Ruby implementations. This mostly includes ruby-based
# scripts. Set USE_RUBY to include all the ruby targets that have been
# verified to work and include the eclass. RUBY_DEPS is now available to
# pull in the dependency on the requested ruby targets.
#
# @CODE
# USE_RUBY="ruby20 ruby21"
# inherit ruby-single
# RDEPEND="${RUBY_DEPS}"
# @CODE

case "${EAPI:-0}" in
	0|1|2|3)
		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}"
		;;
	4|5|6|7)
		;;
	*)
		die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}"
		;;
esac

if [[ ! ${_RUBY_SINGLE} ]]; then

inherit ruby-utils

# @ECLASS-VARIABLE: USE_RUBY
# @DEFAULT_UNSET
# @REQUIRED
# @DESCRIPTION:
# This variable contains a space separated list of targets (see above) a package
# is compatible to. It must be set before the `inherit' call. There is no
# default. All ebuilds are expected to set this variable.


# @ECLASS-VARIABLE: RUBY_DEPS
# @DEFAULT_UNSET
# @DESCRIPTION:
#
# This is an eclass-generated Ruby dependency string for all
# implementations listed in USE_RUBY. Any one of the supported ruby
# targets will satisfy this dependency. A dependency on
# virtual/rubygems is also added to ensure that this is installed
# in time for the package to use it.
#
# Example use:
# @CODE
# RDEPEND="${RUBY_DEPS}
#   dev-foo/mydep"
# BDEPEND="${RDEPEND}"
# @CODE
#
# Example value:
# @CODE
# || ( dev-lang/ruby:2.0 dev-lang/ruby:1.9 ) virtual/rubygems
# @CODE
#
# The order of dependencies will change over time to best match the
# current state of ruby targets, e.g. stable version first.

_ruby_single_implementations_depend() {
	local depend
	local found_one=0
	# If ebuild doesn't enable one of our rubies explicitly in USE_RUBY, we will fall back to BACKUP_RUBY:
	local BACKUP_RUBY=ruby26
	for _ruby_implementation in ruby32 ruby31 ruby30 ruby27 ruby26; do
		# ^^ outer loop because it defines the ordering with 'preferred' version coming first.
		for ruse in ${USE_RUBY}; do
			if [[ "${ruse}" == "${_ruby_implementation}" ]]; then
				found_one=1
				depend="${depend} $(_ruby_implementation_depend $_ruby_implementation)"
			fi
		done
	done
	if [ "$found_one" == "0" ]; then
		depend="${depend} $(_ruby_implementation_depend $BACKUP_RUBY)"
	fi
	echo "|| ( ${depend} ) virtual/rubygems"
}

_ruby_single_set_globals() {
	RUBY_DEPS=$(_ruby_single_implementations_depend)
}
_ruby_single_set_globals


_RUBY_SINGLE=1
fi
