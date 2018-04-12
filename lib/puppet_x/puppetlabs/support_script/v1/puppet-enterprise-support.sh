#!/bin/bash
#==========================================================
# Copyright @ 2014 Puppet Labs, LLC
# Redistribution prohibited.
# Address: 308 SW 2nd Ave., 5th Floor Portland, OR 97204
# Phone: (877) 575-9775
# Email: info@puppetlabs.com
#
# Please refer to the LICENSE.pdf file included
# with the Puppet Enterprise distribution
# for licensing information.
#==========================================================

#===[ Summary ]=========================================================

# This program runs diagnostics for Puppet Enterprise. Run this file to
# run the diagnostics and data aggregation.

if [[ -n "${BEAKER_TESTING}" ]]; then
  # Enable command tracing and strict failures during tests.
  set -xeuo pipefail
fi


#===[ Global variables ]================================================
readonly PUPPET_BIN_DIR='/opt/puppetlabs/puppet/bin'
readonly SERVER_BIN_DIR='/opt/puppetlabs/server/bin'
readonly SERVER_DATA_DIR='/opt/puppetlabs/server/data'
readonly DEFAULT_OUTPUT_DIRECTORY='/var/tmp'
readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_VERSION='2.6.0'
readonly PUPPET_PUBKEY="-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.14 (GNU/Linux)

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
xfhzX6eZ+xft
=j4/z
-----END PGP PUBLIC KEY BLOCK-----"


#===[ Functions ]=======================================================

# Display a multiline string, because we can't rely on `echo` to do the right thing.
#
# Arguments:
# 1. Text to display.
display() {
  printf "%s\n" "${1?}"
}

# Display a newline
display_newline() {
  display ''
}

# Display an error message to STDERR, but do not exit.
#
# Arguments:
# 1. Message to display.
display_error() {
  display "$@" 1>&2
}

# Display an error message to STDERR and exit 1.
#
# Arguments:
# 1. Message to display.
fail() {
  display_error "$@"
  exit 1
}

# Portable test for command existance.
#
# Arguments:
# 1. Command to test.
cmd() {
  hash "$1" &> /dev/null;
}

# Running in noop mode? Return 0 if true.
is_noop() {
  if [ y = "${IS_NOOP:-""}" ]; then
    return 0
  else
    return 1
  fi
}

# Discovers the runtime platform.
#
# Arguments:
# None.
#
# Global Variables:
# * PLATFORM_NAME : Name of the platorm, e.g. "centos".
# * PLATFORM_RELEASE : Release version, e.g. "10.10".
# * PLATFORM_EGREP : Proper invocation of `grep -E` for the platform.
# * PLATFORM_HOSTNAME : Fully-Qualified hostname of this machine, e.g. "myhost.mycompany.com".
# * PLATFORM_HOSTNAME_SHORT : Shortened hostname of this machine, e.g. "myhost".
# * PLATFORM_PACKAGING : Name of local packaging system, e.g. "dpkg".
detect_platform() {
  # Default for most platforms. Exceptions are Solaris and AIX defined blow.
  PLATFORM_EGREP='grep -E'

  # First try identifying using lsb_release.  This takes care of Ubuntu
  # (lsb-release is part of ubuntu-minimal).
  if cmd lsb_release; then
    t_prepare_platform=`lsb_release -icr 2>&1`

    PLATFORM_NAME="$(printf "${t_prepare_platform?}" | grep -E '^Distributor ID:' | cut -s -d: -f2 | sed 's/[[:space:]]//' | tr '[[:upper:]]' '[[:lower:]]')"

    # Sanitize name for unusual platforms
    case "${PLATFORM_NAME?}" in
      redhatenterpriseserver | redhatenterpriseclient | redhatenterpriseas | redhatenterprisees | enterpriseenterpriseserver | redhatenterpriseworkstation | redhatenterprisecomputenode | oracleserver)
        PLATFORM_NAME=rhel
        ;;
      enterprise* )
        PLATFORM_NAME=centos
        ;;
      scientific | scientifics | scientificsl )
        PLATFORM_NAME=rhel
        ;;
      suse* )
        PLATFORM_NAME=sles
        ;;
      amazonami )
        PLATFORM_NAME=amazon
        ;;
    esac

    # Release
    PLATFORM_RELEASE="$(printf "${t_prepare_platform?}" | grep -E '^Release:' | cut -s -d: -f2 | sed 's/[[:space:]]//g')"

    # Sanitize release for unusual platforms
    case "${PLATFORM_NAME?}" in
      centos | rhel )
        # Platform uses only number before period as the release,
        # e.g. "CentOS 5.5" is release "5"
        PLATFORM_RELEASE="$(printf "${PLATFORM_RELEASE?}" | cut -d. -f1)"
        ;;
      debian )
        # Platform uses only number before period as the release,
        # e.g. "Debian 6.0.1" is release "6"
        PLATFORM_RELEASE="$(printf "${PLATFORM_RELEASE?}" | cut -d. -f1)"
        if [ ${PLATFORM_RELEASE} = "testing" ] ; then
          PLATFORM_RELEASE=7
        fi
        ;;
    esac
  elif [ "x$(uname -s)" = "xDarwin" ]; then
    PLATFORM_NAME="osx"
    # sw_vers returns something like 10.9.2, but we only want 10.9 so chop off the end
    t_platform_release="$(/usr/bin/sw_vers -productVersion | cut -d'.' -f1,2)"
    PLATFORM_RELEASE="${t_platform_release?}"
    # Test for Solaris.
  elif [ "x$(uname -s)" = "xSunOS" ]; then
    PLATFORM_NAME="solaris"
    t_platform_release="$(uname -r)"
    # JJM We get back 5.10 but we only care about the right side of the decimal.
    PLATFORM_RELEASE="${t_platform_release##*.}"
    PLATFORM_EGREP='egrep'
  elif [ "x$(uname -s)" = "xAIX" ] ; then
    PLATFORM_NAME="aix"
    t_platform_release="$(oslevel | cut -d'.' -f1,2)"
    PLATFORM_RELEASE="${t_platform_release}"
    PLATFORM_EGREP='egrep'

  # Test for RHEL variant. RHEL, CentOS, OEL
  elif [ -f /etc/redhat-release -a -r /etc/redhat-release -a -s /etc/redhat-release ]; then
    # Oracle Enterprise Linux 5.3 and higher identify the same as RHEL
    if grep -qi 'red hat enterprise' /etc/redhat-release; then
      PLATFORM_NAME=rhel
    elif grep -qi 'centos' /etc/redhat-release; then
      PLATFORM_NAME=centos
    elif grep -qi 'scientific' /etc/redhat-release; then
      PLATFORM_NAME=rhel
    elif grep -qi 'fedora' /etc/redhat-release; then
      PLATFORM_NAME='fedora'
    fi
    # Release - take first digits after ' release ' only.
    PLATFORM_RELEASE="$(sed 's/.*\ release\ \([[:digit:]]\+\).*/\1/g;q' /etc/redhat-release)"
  # Test for Cumulus releases
  elif [ -r "/etc/os-release" ] && grep -E "Cumulus Linux" "/etc/os-release" &> /dev/null ; then
    PLATFORM_NAME=cumulus
    PLATFORM_RELEASE=`grep -E "VERSION_ID" "/etc/os-release" | cut -d'=' -f2 | cut -d'.' -f'1,2'`
  # Test for Debian releases
  elif [ -f /etc/debian_version -a -r /etc/debian_version -a -s /etc/debian_version ]; then
    t_prepare_platform__debian_version_file="/etc/debian_version"
    t_prepare_platform__debian_version=`cat /etc/debian_version`

    if cat "${t_prepare_platform__debian_version_file?}" | grep -E '^[[:digit:]]' > /dev/null; then
      PLATFORM_NAME=debian
      PLATFORM_RELEASE="$(printf "${t_prepare_platform__debian_version?}" | sed 's/\..*//')"
    elif cat "${t_prepare_platform__debian_version_file?}" | grep -E '^wheezy' > /dev/null; then
      PLATFORM_NAME=debian
      PLATFORM_RELEASE="7"
    fi
  elif [ -f /etc/SuSE-release -a -r /etc/SuSE-release ]; then
    t_prepare_platform__suse_version=`cat /etc/SuSE-release`

    if printf "${t_prepare_platform__suse_version?}" | grep -E 'Enterprise Server'; then
      PLATFORM_NAME=sles
      t_version=`/bin/cat /etc/SuSE-release | grep VERSION | sed 's/^VERSION = \(\d*\)/\1/' `
      t_patchlevel=`cat /etc/SuSE-release | grep PATCHLEVEL | sed 's/^PATCHLEVEL = \(\d*\)/\1/' `
      PLATFORM_RELEASE="${t_version}"
    fi
  elif [ -f /etc/system-release ]; then
    if grep -qi 'amazon linux' /etc/system-release; then
      PLATFORM_NAME=amazon
      PLATFORM_RELEASE=6
    else
      fail "$(cat /etc/system-release) is not a supported platform for Puppet Enterprise."
    fi
  elif [ -z "${PLATFORM_NAME:-""}" ]; then
    fail "$(uname -s) is not a supported platform for Puppet Enterprise."
  fi

  if [ -z "${PLATFORM_NAME:-""}" -o -z "${PLATFORM_RELEASE:-""}" ]; then
    fail "Unknown platform."
  fi

  # Hostname
  case "${PLATFORM_NAME?}" in
    solaris)
      # Calling hostname --fqdn on solaris will set the hostname to '--fqdn' so we don't do that.
      # Note there is a single space and literal tab character inside the brackets to match spaces or tabs
      # in resolv.conf
      t_fqdn=`sed -n 's/^[ 	]*domain[ 	]*\(.*\)$/\1/p' /etc/resolv.conf`
      t_host=`uname -n`
      if [ -z $t_fqdn ]; then
        PLATFORM_HOSTNAME=${t_host?}
      else
        PLATFORM_HOSTNAME="${t_host?}.${t_fqdn:-''}"
      fi

      PLATFORM_HOSTNAME_SHORT=${t_host?}
      ;;
    aix)
      # As with solaris, calling `hostname --fqdn` sets the hostname
      # to '--fqdn' if /opt/freeware/bin is in the path and we're
      # calling GNU hostname. AIX also has AIX hostname, in /bin, in
      # which `hostname` prints the fqdn, and `hostname -s` prints
      # hostname with domain info trimmed. We use the AIX hostname
      # because its more sane and reliably there.
      PLATFORM_HOSTNAME=`/bin/hostname`
      PLATFORM_HOSTNAME_SHORT=`/bin/hostname -s`
      ;;
    *)
      if hostname --fqdn &> /dev/null; then
        PLATFORM_HOSTNAME=`hostname --fqdn 2> /dev/null`
      else
        PLATFORM_HOSTNAME=`hostname`
      fi

      if hostname --short &> /dev/null; then
        PLATFORM_HOSTNAME_SHORT=`hostname --short 2> /dev/null`
      else
        PLATFORM_HOSTNAME_SHORT=`echo "${PLATFORM_HOSTNAME}" | cut -d. -f1`
      fi
      ;;
  esac

  # Packaging
  case "${PLATFORM_NAME?}" in
    centos | rhel | sles | amazon | aix | eos | fedora )
      PLATFORM_PACKAGING=rpm
      ;;
    ubuntu | debian | cumulus)
      PLATFORM_PACKAGING=dpkg
      ;;
    solaris )
      case  "${PLATFORM_RELEASE?}" in
        10)
          PLATFORM_PACKAGING=pkgadd
          ;;
        11)
          PLATFORM_PACKAGING=ips
          ;;
      esac
      ;;
    *)
      fail "Unknown packaging system for platform: ${PLATFORM_NAME?}"
      ;;
  esac

  # Ensure PLATFORM_HOSTNAME_SHORT only contains one namespace segment.
  PLATFORM_HOSTNAME_SHORT=$(echo "${PLATFORM_HOSTNAME_SHORT}" | cut -d. -f1)

  # Now that global variables are set, flag them as readonly.
  readonly PLATFORM_NAME
  readonly PLATFORM_RELEASE
  readonly PLATFORM_EGREP
  readonly PLATFORM_HOSTNAME
  readonly PLATFORM_HOSTNAME_SHORT
  readonly PLATFORM_PACKAGING
}

# Is the package installed? Returns 0 for true, 1 for false.
#
# Arguments:
# 1. Name of package.
is_package_installed() {
  case "${PLATFORM_PACKAGING?}" in
    rpm)
      (rpm -qi "${1?}") &> /dev/null
      return $?
      ;;
    dpkg)
      (dpkg-query --show --showformat '${Package}:${Status}\\n' "${1?}" 2>&1 | grep ' installed') &> /dev/null
      return $?
      ;;
    pkgadd)
      (pkginfo -l ${1?} | ${PLATFORM_EGREP?} 'STATUS:[:space:]*.*[:space:]*installed') &> /dev/null
      return $?
      ;;
    ips)
      ("pkg info ${1?}") &> /dev/null
      return $?
      ;;
    *)
      fail "Do not know how to check if package is installed on ${PLATFORM_NAME?}."
      ;;
  esac
}

# Print the value of a given ini field in a file. This doesn't respect sections,
# so fields must be unique. If the field doesn't exist, nothing is printed.
# Ignores whitespace around the field, value and equal sign.
#
# Arguments:
# 1. The file to read
# 2. The field to retrieve
get_ini_field() {
  t_ini_file="${1?}"
  t_ini_field="${2?}"

  t_extract_field="
      field_regex = /^\s*${t_ini_field?}\s*=(.*)$/
      if match = File.read('${t_ini_file?}').match(field_regex)
          print match[1].strip
      end
  "

  "${PUPPET_BIN_DIR?}/ruby" -e "${t_extract_field?}"
}

# Use ruby timeout since bash timeout is not available on all platforms
with_timeout() {
  local timeout=$1
  shift

  # Pass arguments to run as an array so that Process.spawn() will execute the
  # command without creating a subshell. Ruby script passed to stdin.
  "${PUPPET_BIN_DIR?}/ruby" -rtimeout -- - "$@" <<EOscript
pid = Process.spawn(*ARGV, pgroup: true)
begin
  Timeout.timeout(${timeout}) { Process.wait pid }
rescue Timeout::Error
  puts 'Timeout ${timeout} seconds has expired.'
  puts "Sending TERM signal to process group of pid #{pid}..."
  Process.kill('TERM', -Process.getpgid(pid)) rescue Errno::ESRCH
end
EOscript
}

# This command is a modification of the utilities 'run'
# command. It captures the output of a command specified by the first argument
# and writes stdout and stderr to the specified file. If logging is enabled,
# it appends the output to the logfile. If debugging is enabled, it will print
# the command to be executed to the terminal.
#
# In the case where running the support script is necessary, the underlying
# system may be unstable in some manner, so the support script needs extra
# logging and debug information in case that it too starts failing.
#
# Example:
#
#  run_diagnostic "/usr/sbin/sestatus" "system/selinux.txt"
#
# Global Variables Used:
#   DROP
#   PUPPET_BIN_DIR
#
run_diagnostic() {
  local timeout=''
  local user=''
  local prefix_command=''

  # Parse options
  while :
  do
    case "$1" in
      --timeout)
        timeout=$2
        shift 2
        ;;
      --user)
        user=$2
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  local t_run_diagnostic__command="${1?}"
  local t_run_diagnostic__outfile="${DROP?}/${2?}"

  display " ** Collecting output of: ${t_run_diagnostic__command?}"
  display_newline

  if [ -n "$timeout" ] ; then
    if [ -x "${PUPPET_BIN_DIR?}/ruby" ] ; then
      prefix_command="with_timeout $timeout "
    else
      display " ** Warning: --timeout X passed, but PE ruby is not present.  Ignoring timeout flag."
      display_newline
    fi
  fi

  if is_noop; then
    return 0
  elif [[ -n "${user}" ]]; then
    ( eval "${prefix_command:-}su - ${user} -s ${SHELL} -c \"${t_run_diagnostic__command//\"/\\\"}\" 2>&1" ) >> $t_run_diagnostic__outfile
    return $?
  else
    ( eval "${prefix_command:-}${t_run_diagnostic__command?} 2>&1" ) >> $t_run_diagnostic__outfile
    return $?
  fi
}

# Join elements of an array with a delimiter.
#
# Arguments:
# 1: Character Delimiter
# 2: Array of Strings
#
# Returns: String
#
function join() { 
  local IFS="$1"
  shift
  echo "$*"
}

# Pull the given setting from puppet config print
# Caches this as a file in the DROP directory to prevent the need for
# multiple calls for the same setting
#
# Global Variables Used:
#  PUPPET_BIN_DIR
#  DROP
#
# Arguments:
#   $1 = The section of the puppet configuration file ['main','agent','master','user']
#   $2 = The setting in the puppet configuration file
#
function get_puppet_config() {
  local section="${1?}"
  local setting="${2?}"
  local tmpfile="${DROP?}/.config_${section}_${setting}.tmp"

  if [ ! -e "${tmpfile}" ]; then
    "${PUPPET_BIN_DIR?}/puppet" config print --section "${section}" "${setting}" > "${tmpfile}" || display_error "get_puppet_config error looking up ${setting} in ${section}."
  fi

  cat "${tmpfile}"
}

#===[Networking checks]=========================================================

netstat_checks() {
  if [ "x${PLATFORM_NAME?}" = "xsolaris" ]; then
    run_diagnostic "netstat -anf inet" "networking/ports.txt"
  else
    run_diagnostic "netstat -anptu" "networking/ports.txt"
  fi
}

iptables_checks() {
  iptables_file="networking/ip_tables.txt"
  if [ "x${PLATFORM_NAME?}" = "xsolaris" ]; then
    if cmd ipf && cmd ipfstat; then
      run_diagnostic "ipfstat" $iptables_file
      run_diagnostic "ipfstat -i" $iptables_file
      run_diagnostic "ipfstat -o" $iptables_file
      run_diagnostic "ipf -V" $iptables_file
    fi
  else
    if cmd iptables; then
      run_diagnostic "iptables -L" $iptables_file
      run_diagnostic "ip6tables -L" $iptables_file
    else
      run_diagnostic "lsmod | $PLATFORM_EGREP ip" "networking/ip_modules.txt"
    fi
  fi
}

# Record hostname info and test DNS resolution
#
# Global Variables Used:
#   PLATFORM_HOSTNAME
#   PLATFORM_NAME
#   DROP
#
# Arguments:
#   None
#
# Returns:
#   None
hostname_checks() {
  local ipaddress
  local mapped_hostname

  echo "${PLATFORM_HOSTNAME?}" > "${DROP?}/networking/hostname_output.txt"

  # this part doesn't work so well if your hostname is mapped to 127.0.x.1 in /etc/hosts

  # See if hostname resolves
  # This won't work on solaris
  if ! [ "${PLATFORM_NAME?}" = "solaris" ]; then
    ipaddress=$(ping  -t1 -c1 "${PLATFORM_HOSTNAME}" | awk -F\( '{print $2}' | awk -F\) '{print $1}' | head -1)
    echo "${ipaddress}" > "${DROP}/networking/guessed_ip_address.txt"

    mapped_hostname=$(getent hosts "${ipaddress}" | awk '{print $2}')
    echo "${mapped_hostname}" > "${DROP}/networking/mapped_hostname_from_guessed_ip_address.txt"
  fi

  # This symlink allows SOScleaner to redact hostnames in support script output:
  #   https://github.com/RedHatGov/soscleaner
  ln -s "networking/hostname_output.txt" "${DROP}/hostname"
}

can_contact_master() {
  if cmd puppet && [ -f "${PUPPET_BIN_DIR?}/puppet" ]; then
    if [ "x${PLATFORM_NAME?}" = "xsolaris" ]; then
      PING="ping"
    else
      PING="ping -c 1"
    fi

    if $PING $(${PUPPET_BIN_DIR?}/puppet agent --configprint server) &> /dev/null; then
      echo "Master is alive." > "${DROP?}/networking/puppet_ping.txt"
    else
      echo "Master is unreachable." > "${DROP}/networking/puppet_ping.txt"
    fi
  else
    echo "No puppet found, master status is unknown." > "${DROP}/networking/puppet_ping.txt"
  fi
}

ifconfig_output() {
  if cmd ifconfig && ifconfig -a &> /dev/null; then
    run_diagnostic "ifconfig -a" "networking/ifconfig.txt"
  fi
}

#===[Resource checks]===========================================================

get_all_database_names() {
  echo $(su - pe-postgres -s ${SHELL} -c "${SERVER_BIN_DIR?}/psql -t -c 'select datname from pg_catalog.pg_database;'" | awk '{print $1}' | grep -v '^template')
}

df_checks() {
  # Conditionally do some disk use checks
  if $(df -h &> /dev/null); then
    run_diagnostic "df -h" "resources/df_output.txt"
  elif $(df -k &> /dev/null); then
    run_diagnostic "df -k" "resources/df_output.txt"
  fi

  if $(df -i &> /dev/null); then
    run_diagnostic "df -i" "resources/df_inodes_output.txt"
  fi
}

db_relation_size_checks() {
  # Inspired by https://wiki.postgresql.org/wiki/Disk_Usage#Finding_the_size_of_your_biggest_relations
  local database_names=$(get_all_database_names)
  for db in $database_names; do
    local command="${SERVER_BIN_DIR?}/psql $db -c \
\"SELECT '$db' as dbname, nspname || '.' || relname AS relation, \
pg_size_pretty(pg_relation_size(C.oid)) AS size FROM pg_class C \
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) \
WHERE nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast') \
ORDER BY pg_relation_size(C.oid) DESC;\""
    run_diagnostic --user pe-postgres "${command?}" "resources/db_relation_sizes.txt"
  done
}

db_size_from_psql() {
  local db=$1
  local drop_file=resources/db_sizes_from_psql.txt
  local command="${SERVER_BIN_DIR?}/psql -c \"SELECT '$db' AS dbname, pg_size_pretty(pg_database_size('$db'));\""
  run_diagnostic --user pe-postgres "${command?}" "$drop_file"
}

db_size_from_fs() {
  run_diagnostic "ls -d /opt/puppetlabs/server/data/postgresql/*/PG_9* /opt/puppetlabs/server/data/postgresql/*/data | xargs du -sh" "resources/db_sizes_from_du.txt"
}

db_size_checks() {
  # Check size of databases, both from the filesystem's perspective and the
  # database's perspective
  local database_names=$(get_all_database_names)
  for db in $database_names; do
    # Find size via psql
    db_size_from_psql $db
  done
  # Find size via filesystem
  db_size_from_fs
}

free_checks() {
  # Sorry, no free on solaris. Seriously.
  if [ ${PLATFORM_NAME?} = "solaris" ]; then
    run_diagnostic "pagesize -a" "resources/free_mem.txt"
    run_diagnostic "prtconf | $PLATFORM_EGREP 'Mem'" "resources/free_mem.txt"
    run_diagnostic "swap -l" "resources/free_mem.txt"
    run_diagnostic "swap -s" "resources/free_mem.txt"
  else
    run_diagnostic "free" "resources/free_mem.txt"
  fi
}

ntp_checks() {
  if cmd ntpq; then
    run_diagnostic "ntpq -p" "networking/ntpq_output.txt"
  fi
}

#===[System checks]=============================================================

selinux_checks() {
  if [ -x /usr/sbin/sestatus ]; then
    run_diagnostic "/usr/sbin/sestatus" "system/selinux.txt"
  fi
}

get_umask() {
  umask > "${DROP?}/system/umask.txt"
}

facter_checks() {
  run_diagnostic "${PUPPET_BIN_DIR?}/puppet facts --debug --color=false" "system/facter_output.txt"
  split -l $(($(grep --color=never -nh "^{$" "${DROP?}/system/facter_output.txt" |cut -d ':' -f 1)- 1)) "$DROP"/system/facter_output.txt "$DROP"/system/facter_output
  mv "$DROP"/system/facter_outputaa "$DROP"/system/facter_output.debug.log
  mv "$DROP"/system/facter_outputab "$DROP"/system/facter_output.json
  rm "$DROP"/system/facter_output.txt
}

etc_checks() {
  cp -p /etc/resolv.conf "${DROP?}/system/etc"
  cp -p /etc/nsswitch.conf "${DROP}/system/etc"
  cp -p /etc/hosts "${DROP}/system/etc"

  # This symlink allows SOScleaner to redact hostnames in support script output:
  #   https://github.com/RedHatGov/soscleaner
  mkdir "${DROP}/etc"
  ln -s ../system/etc/hosts "${DROP}/etc/hosts"

  for f in "/etc/yum.conf" "/etc/yum.repos.d" "/etc/apt/apt.conf.d" "/etc/apt/sources.list.d"; do
    if [ -e $f ]; then
      cp --parents -Lr $f "$DROP"/system
    fi
  done

  case "${PLATFORM_NAME?}" in
    debian|ubuntu)
      CONFDIR="/etc/default"
    ;;
    *)
      CONFDIR="/etc/sysconfig"
    ;;
  esac

  for f in mcollective \
    pe-activemq \
    pe-console-services \
    pe-nginx \
    pe-orchestration-services \
    pe-pgsql \
    pe-puppetdb \
    pe-puppetserver \
    pe-razor-server \
    pgsql \
    puppet \
    pxp-agent; do
    if [ -f $CONFDIR/$f ]; then
      cp -p $CONFDIR/$f "${DROP}/system/etc"
    fi
  done
}

os_checks() {
  if [ ${PLATFORM_NAME?} = "solaris" ]; then
    # Probably want more information than this here
    echo "Solaris" > "${DROP?}/system/os_checks.txt"
  elif cmd lsb_release; then
    run_diagnostic "lsb_release -a" "system/lsb_release.txt"
  fi

  run_diagnostic "uname -a" "system/uname.txt"
  run_diagnostic "uptime" "system/uptime.txt"
}

ps_checks() {
  run_diagnostic "ps aux" "system/ps_aux.txt"
  $(ps -e f &> /dev/null) && run_diagnostic "ps -e f" "system/ps_tree.txt"
}

list_all_services() {
  case "${PLATFORM_NAME?}" in
    solaris)
      run_diagnostic "svcs -a" "system/services.txt"
    ;;
    rhel|centos|sles|debian|ubuntu)
      if (pidof systemd &> /dev/null); then
        run_diagnostic "systemctl list-units" "system/services.txt"
      else
        if cmd chkconfig; then
          run_diagnostic "chkconfig --list" "system/services.txt"
        fi
      fi
    ;;
    *)
      # unsupported platform
    ;;
  esac
}

grab_env_vars() {
  run_diagnostic "env" "system/env.txt"
}


# Copy PE service logs to support script output.
#
# Captures /var/log/puppetlabs along with journalctl output
# for each PE service.
#
# Global Variables Used:
#   DROP
#   SERVER_DATA_DIR
#   MAX_LOG_AGE
#
# Arguments:
#   None
#
# Returns:
#   None
pe_logs() {
  local pe_services
  local agent_services
  local pg_upgrade_logs
  local find_filter=()
  local journalctl_filter=()

  # A little odd, but portable. Tests that the value of MAX_LOG_AGE
  # does not match a glob expression for non-digit characters.
  if [[ $MAX_LOG_AGE != *[!0-9]* ]];then
    find_filter=('-mtime' "-${MAX_LOG_AGE}")
    journalctl_filter=('--since' "'${MAX_LOG_AGE} days ago'")
  fi

  (
    cd /var/log/puppetlabs || exit 1

    while IFS= read -r -d $'\0' logfile; do
      logfile="${logfile#./}"
      targetdir="${DROP?}/logs/${logfile%/*}"

      [[ -d $targetdir ]] || mkdir -p "${targetdir}"
      cp -Lp "${logfile}" "${targetdir}/"
    done < <(find . -type f "${find_filter[@]}" -exec printf '%s\0' {} \;)
  )

  pe_services=(
    'nginx'
    'puppetserver'
    'puppetdb'
    'activemq'
    'console-services'
    'orchestration-services'
    'postgresql'
  )

  agent_services=(
    'puppet'
    'pxp-agent'
    'mcollective'
  )

  if cmd journalctl; then
    # journalctl always exits with code 1 if a unit hasn't logged any output.
    # Therefore, we mask the exit code with `|| true` so that tests pass.
    for s in "${pe_services[@]}"; do
      if [[ -d "${DROP}/logs/${s}" ]]; then
        run_diagnostic "journalctl --full --output=short-iso --unit=pe-${s} ${journalctl_filter[*]} || true" "logs/${s}/${s}-journalctl.log"
      fi
    done

    for s in "${agent_services[@]}"; do
      run_diagnostic "journalctl --full --output=short-iso --unit=${s} ${journalctl_filter[*]} || true" "logs/${s}-journalctl.log"
    done
  fi

  if [[ -d '/var/lib/peadmin/.mcollective.d' ]]; then
    mkdir -p "${DROP}/logs/peadmin"
    cp -LpR /var/lib/peadmin/.mcollective.d/client.log* "${DROP}/logs/peadmin"
  fi


  # Logs left by pg_upgrade if migration of Postgres data fails.
  # pg_upgrade # writes these to the directory it was run from
  # which is set to $SERVER_DATA_DIR/postgresql by the pe_install
  # module.
  pg_upgrade_logs=(
    'pg_upgrade_internal.log'
    'pg_upgrade_server.log'
    'pg_upgrade_utility.log'
  )

  for f in "${pg_upgrade_logs[@]}"; do
    if [[ -f "${SERVER_DATA_DIR?}/postgresql/${f}" ]]; then
      mkdir -p "${DROP}/logs/postgresql"
      cp -Lp "${SERVER_DATA_DIR?}/postgresql/${f}" "${DROP}/logs/postgresql/${f}"
    fi
  done
}

# Copy PE metrics to support script output
#
# Captures data produced by the puppet_metrics_collector module, or its
# predecessor, the pe_metric_curl_cron_jobs module.
#
# Global Variables Used:
#   DROP
#
# Arguments:
#   None
#
# Returns:
#   None
pe_metrics() {
  if [[ -d /opt/puppetlabs/puppet-metrics-collector ]]; then
    mkdir -p "${DROP?}/metrics"
    cp -LpR /opt/puppetlabs/puppet-metrics-collector "${DROP}/metrics/"
  elif [[ -d /opt/puppetlabs/pe_metric_curl_cron_jobs ]]; then
    mkdir -p "${DROP?}/metrics"
    cp -LpR /opt/puppetlabs/pe_metric_curl_cron_jobs "${DROP}/metrics/"
  fi
}

# Copy puppet agent state directory
#
# Global Variables Used:
#   DROP
#   PUPPET_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
get_state() {
  local configured_state_dir
  local state_dir

  configured_state_dir=$(get_puppet_config "agent" "statedir")
  state_dir="${configured_state_dir:=/opt/puppetlabs/puppet/cache/state/}"

  cp -LpR "${state_dir}" "${DROP?}/enterprise/state"
}

other_logs() {
  for log in "system" "syslog" "messages"; do
    if [ -f /var/log/${log} ]; then
      cp -pR /var/log/${log} "${DROP?}/logs" && gzip -9 "${DROP}/logs/${log}"
    fi
  done
  if [ -x /bin/dmesg ]; then
    /bin/dmesg > "$DROP"/logs/dmesg.txt
  fi
}

#===[Puppet Enterprise checks]==================================================

# Copy configuration from /etc/puppetlabs to support script output.
#
# Configuration keys with "password" in their names are redacted from the
# copied files.
#
# Global Variables Used:
#   DROP
#   FILESYNC
#   SERVER_DATA_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
gather_enterprise_files() {
  local pe_config_files
  local config_dir
  local postgres_datadirs
  local postgres_drop_location
  local postgres_config_files

  # Whitelist of configuration files and directories to copy. Each entry is
  # relative to /etc/puppetlabs.
  pe_config_files=(
    'activemq/activemq.xml'
    'activemq/jetty.xml'
    'activemq/log4j.properties'

    'client-tools/orchestrator.conf'
    'client-tools/puppet-access.conf'
    'client-tools/puppet-code.conf'
    'client-tools/puppetdb.conf'

    'code/hiera.yaml'

    'console-services/bootstrap.cfg'
    'console-services/conf.d'
    'console-services/logback.xml'
    'console-services/rbac-certificate-whitelist'
    'console-services/request-logging.xml'

    'enterprise/conf.d'
    'enterprise/hiera.yaml'

    'facter/facter.conf'

    'installer/answers.install'

    'mcollective/server.cfg'

    'nginx/conf.d'
    'nginx/nginx.conf'

    'orchestration-services/bootstrap.cfg'
    'orchestration-services/conf.d'
    'orchestration-services/logback.xml'
    'orchestration-services/request-logging.xml'

    'puppet/auth.conf'
    'puppet/autosign.conf'
    'puppet/classfier.yaml'
    'puppet/fileserver.conf'
    'puppet/hiera.yaml'
    'puppet/puppet.conf'
    'puppet/puppetdb.conf'
    'puppet/routes.yaml'

    'puppetdb/bootstrap.cfg'
    'puppetdb/certificate-whitelist'
    'puppetdb/conf.d'
    'puppetdb/logback.xml'
    'puppetdb/request-logging.xml'

    'puppetserver/bootstrap.cfg'
    'puppetserver/code-manager-request-logging.xml'
    'puppetserver/conf.d'
    'puppetserver/logback.xml'
    'puppetserver/request-logging.xml'

    'pxp-agent/modules'
    'pxp-agent/pxp-agent.conf'

    'r10k/r10k.yaml'
  )

  # Copy code-staging if filesync debugging is enabled.
  if [[ "${FILESYNC?}" = 'y' ]]; then
    pe_config_files=("${pe_config_files[@]}" 'code-staging')
  fi

  mkdir -p "${DROP?}/enterprise/etc/puppetlabs"
  for f in "${pe_config_files[@]}"; do
    if [[ -e "/etc/puppetlabs/${f}" ]]; then
      config_dir=$(dirname "${f}")
      mkdir -p "${DROP}/enterprise/etc/puppetlabs/${config_dir}"

      cp -LpR "/etc/puppetlabs/${f}" "${DROP}/enterprise/etc/puppetlabs/${f}"
    fi
  done

  # Collect MCollective client configuration if present

  if [[ -f '/var/lib/peadmin/.mcollective' ]]; then
    mkdir -p "${DROP}/enterprise/etc/puppetlabs/peadmin"
    cp -Lp '/var/lib/peadmin/.mcollective' "${DROP}/enterprise/etc/puppetlabs/peadmin/client.cfg"
  fi

  # Collect Postgres configuration if present

  postgres_datadirs=(
    "${SERVER_DATA_DIR?}"/postgresql/*/data
  )
  postgres_config_files=(
    'postgresql.conf'
    'postmaster.opts'
    'pg_ident.conf'
    'pg_hba.conf'
  )
  for d in "${postgres_datadirs[@]}"; do
    if [[ -e "${d}" ]]; then
      postgres_drop_location="${DROP}/enterprise/etc/puppetlabs/postgres/$(basename "$(dirname "${d}")")"
      mkdir -p "${postgres_drop_location}"

      for f in "${postgres_config_files[@]}"; do
        if [[ -f "${d}/${f}" ]]; then
          cp -Lp "${d}/${f}" "${postgres_drop_location}/${f}"
        fi
      done
    fi
  done

  # Redact passwords from copied config files.

  if [[ -f "${DROP}/enterprise/etc/puppetlabs/activemq/activemq.xml" ]]; then
    # A Regex which looks for an XML attribute names ending in "password", one
    # per line, and redacts their values.
    sed -i'' -e 's/^\(.*password="\)[^"]*\(.*\)/\1REDACTED\2/' \
      "${DROP}/enterprise/etc/puppetlabs/activemq/activemq.xml"
  fi

  local files_to_redact
  files_to_redact=(
    "${DROP}/enterprise/etc/puppetlabs/peadmin/client.cfg"
    "${DROP}/enterprise/etc/puppetlabs/mcollective/server.cfg"
    "${DROP}/enterprise/etc/puppetlabs"/*/conf.d/*
  )

  for f in "${files_to_redact[@]}"; do
    if [[ -f "${f}" ]]; then
      # A regex which matches key names ending in "password", one per line, and
      # redacts their values. Works for most pretty printed JSON, YAML, HOCON
      # and INI formats.
      sed -i'' -e 's/^\(.*password"\?\s*[=:]\).*/\1 "REDACTED"/' "${f}"
    fi
  done

  # Ensure enterprise/conf.d/... is executable to simplify cleanup
  # via `rm -rf` when tarballs are extracted.
  if [[ -d "${DROP}/enterprise/etc/puppetlabs/enterprise" ]]; then
    find "${DROP}/enterprise/etc/puppetlabs/enterprise" -type d -exec chmod u+x {} +
  fi
}

# Display listings of the Puppet Enterprise files and module files
list_pe_and_module_files() {
  local enterprise_dirs="/etc/puppetlabs /opt/puppetlabs /var/lib/peadmin /var/log/puppetlabs"
  local modulepath=$(${PUPPET_BIN_DIR?}/puppet master --configprint modulepath)
  local basemodulepath=$(${PUPPET_BIN_DIR?}/puppet master --configprint basemodulepath)
  local environmentpath=$(${PUPPET_BIN_DIR?}/puppet master --configprint environmentpath)
  local paths=$(echo "${modulepath}:${basemodulepath}:${environmentpath}" | tr '[:\n]' '\0' | xargs -0)
  # Remove directories under directories in $enterprise_dirs so the listings aren't duplicated
  for dir in ${enterprise_dirs}; do
    paths=$(echo $paths | sed "s,${dir}/[^ ]*,,g")
  done
  enterprise_dirs="${enterprise_dirs} ${paths}"
  for dir in ${enterprise_dirs}; do
    dir_desc=$(echo "${dir}" | sed 's,\/,_,g')
    if [ -d "${dir}" ]; then
      find "${dir}" -ls | gzip -f9 > "${DROP?}/enterprise/find/${dir_desc}.txt.gz"
    else
      echo "No directory ${dir}" > "${DROP}/enterprise/find/${dir_desc}.txt"
    fi
  done
}

# Gather all modules installed on the modulepath
# Expects enterprise/puppetserver_environments.json to already be in place from puppetserver_environments()
module_listing() {
  local agent_cert=$("${PUPPET_BIN_DIR}/puppet" config print --section agent hostcert)
  local agent_key=$("${PUPPET_BIN_DIR}/puppet" config print --section agent hostprivkey)

  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -k https://${PLATFORM_HOSTNAME}:8140/puppet/v3/environment_modules --cert ${agent_cert} --key ${agent_key}" "enterprise/modules.json"
}

# Check r10k deployment status
#
# Global Variables Used:
#   PUPPET_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
check_r10k() {
  local r10k_config=""

  if [[ -e /opt/puppetlabs/server/data/code-manager/r10k.yaml ]]; then
    # Code Manager
    r10k_config=/opt/puppetlabs/server/data/code-manager/r10k.yaml
  elif [[ -e /etc/puppetlabs/r10k/r10k.yaml ]]; then
    # Custom r10k config
    r10k_config=/etc/puppetlabs/r10k/r10k.yaml
  fi

  if [[ -x "${PUPPET_BIN_DIR}/r10k" ]] && [[ -n "${r10k_config}" ]]; then
    run_diagnostic "${PUPPET_BIN_DIR}/r10k deploy display -p --detail -c ${r10k_config}" "enterprise/r10k_deploy_display.txt"
  fi

  if [[ -x "/opt/puppetlabs/server/data/code-manager" ]]; then
    run_diagnostic "du -h --max-depth=1 /opt/puppetlabs/server/data/code-manager/" "resources/r10k_cache_sizes_from_du.txt"
  fi
}

# Gather all changes to the installed Puppet Enterprise modules
module_changes() {
  if [ -f "${PUPPET_BIN_DIR?}/puppet" ]; then
    pe_module_path="/opt/puppetlabs/puppet/modules"
    for module in $(ls "${pe_module_path?}"); do
      echo "${module?}:" >> "${DROP?}/enterprise/module_changes.txt"
      run_diagnostic "${PUPPET_BIN_DIR?}/puppet module changes ${pe_module_path?}/${module?} --render-as yaml" "enterprise/module_changes.txt"
    done
  fi
}

# Print an ASCII bar for readability
bar() {
  for (( i=0; i<$1; i++ )); do
    printf "="
  done

  printf "\n"
}

# Gather all packages that are part of the Puppet Enterprise installation
package_listing() {
  pkg_file=enterprise/packages.txt
  pkg_verify_file="${DROP}/enterprise/packages_verify.txt"
  case "${PLATFORM_PACKAGING?}" in
    rpm)
      run_diagnostic "rpm -qa | $PLATFORM_EGREP '^pe-|^puppet'" $pkg_file
      for pkg in $(rpm -qa | $PLATFORM_EGREP '^pe-|^puppet'); do
        printf "\n%s\n" "$pkg" >> "$pkg_verify_file"
        bar ${#pkg} >> "$pkg_verify_file"
        rpm -V "$pkg" >> "$pkg_verify_file" || true
      done
    ;;

    dpkg)
      run_diagnostic "dpkg-query -W -f '\${Package}\n' | $PLATFORM_EGREP '^pe-|^puppet'" $pkg_file
      for pkg in $(dpkg-query -W -f '${Package}\n' | $PLATFORM_EGREP '^pe-|^puppet'); do
        printf "\n%s\n" "$pkg" >> "$pkg_verify_file"
        bar ${#pkg} >> "$pkg_verify_file"
        dpkg -V "$pkg" >> "$pkg_verify_file" || true
      done

    ;;

    pkgadd)
      run_diagnostic "pkginfo | $PLATFORM_EGREP 'PUP.*'" $pkg_file
    ;;

    *)
      #fail
    ;;
  esac
}

# List gem versions used by puppet and puppetserver
#
# Global Variables Used:
#   PUPPET_BIN_DIR
#   SERVER_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
gem_listing() {
  if [[ -x "${PUPPET_BIN_DIR?}/gem" ]]; then
    run_diagnostic "${PUPPET_BIN_DIR}/gem list --local" "enterprise/puppet_gems.txt"
  fi

  if [[ -x "${SERVER_BIN_DIR?}/puppetserver" ]]; then
    run_diagnostic "${SERVER_BIN_DIR}/puppetserver gem list --local" "enterprise/puppetserver_gems.txt"
  fi
}

check_certificates() {
  local cadir

  cadir=$(get_puppet_config "master" "cadir")

  if [[ -e "${cadir}" ]]; then
    run_diagnostic "${PUPPET_BIN_DIR?}/puppet cert list --all" "enterprise/certs.txt"
  fi
}

mco_commands() {
  if [ -f "${PUPPET_BIN_DIR}/mco" ]; then
    mco_user="peadmin"
    if getent passwd ${mco_user} &> /dev/null; then
      run_diagnostic --timeout 15 "su - ${mco_user?} -c 'mco ping'" "enterprise/mco_ping_$mco_user.txt"
      run_diagnostic --timeout 15 "su - ${mco_user?} -c 'mco inventory ${PLATFORM_HOSTNAME}'" "/enterprise/mco_inventory_${mco_user}.txt"
    else
      echo "No such user: '${mco_user}'." > "${DROP?}/enterprise/mco_$mco_user.txt"
    fi
  fi
}

activemq_limits() {
  echo "File descriptors in use by pe-activemq:" > "${DROP?}/enterprise/activemq_resource_limits"
  if cmd lsof; then
    run_diagnostic "lsof -u pe-activemq | wc -l" "enterprise/activemq_resource_limits"
  else
    echo "lsof: command not found" >> "${DROP}/enterprise/activemq_resource_limits"
  fi

  echo -e "\n\nResource limits for pe-activemq:\n" >> "${DROP}/enterprise/activemq_resource_limits"
  run_diagnostic --user pe-activemq "ulimit -a" "enterprise/activemq_resource_limits"
}

# Curls the status of the console
console_status() {
  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 http://127.0.0.1:4432/status/v1/services?level=debug" "enterprise/console_status.json"
}

# Collects output from the Orchestration Services status endpoint
#
# Global Variables Used:
#   PUPPET_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
orchestration_status() {
  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -k https://127.0.0.1:8143/status/v1/services?level=debug" "enterprise/orchestration_status.json"
}

# Collects inventory from the Orchestration Services api if an API token is available
#
# Global Variables Used:
#   PUPPET_BIN_DIR
#   HOME
#
# Arguments:
#   None
#
# Returns:
#   None
orchestration_inventory() {
  if [[ -e ${HOME}/.puppetlabs/token ]]; then
    run_diagnostic "${PUPPET_BIN_DIR?}/curl --silent --show-error --connect-timeout 5 --max-time 60 -k -H X-Authentication:$(cat "${HOME?}/.puppetlabs/token") https://127.0.0.1:8143/orchestrator/v1/inventory" "enterprise/orchestration_inventory.json"
  fi
}

# Collects output from the Puppet Server status endpoint
#
# Global Variables Used:
#   PUPPET_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
puppetserver_status() {
  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -k https://127.0.0.1:8140/status/v1/services?level=debug" "enterprise/puppetserver_status.json"
}

# Collects output from the Puppet Server environments endpoint
#
# Global Variables Used:
#   DROP
#   PUPPET_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
puppetserver_environments() {
  local agent_cert
  local agent_key
  local environmentdirs
  local environments
  local droppath

  agent_cert=$(get_puppet_config "agent" "hostcert")
  agent_key=$(get_puppet_config "agent" "hostprivkey")

  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --fail --connect-timeout 5 --max-time 60 --cert ${agent_cert} --key ${agent_key} -k https://127.0.0.1:8140/puppet/v3/environments" "enterprise/puppetserver_environments.json" || return

  environmentdirs=$("${PUPPET_BIN_DIR}/ruby" -rjson -e 'puts JSON.load(ARGF.read)["search_paths"].reject{|p| p.start_with?("data:")}.map{|p| p.sub(%r{^file://}, "")}.join(" ")' "${DROP?}/enterprise/puppetserver_environments.json")
  environments=$("${PUPPET_BIN_DIR}/ruby" -rjson -e 'puts JSON.load(ARGF.read)["environments"].keys.join(" ")' "${DROP}/enterprise/puppetserver_environments.json")

  for e in $environments; do
    for d in $environmentdirs; do
      droppath="${DROP}/enterprise/etc/puppetlabs/code/$(basename "${d}")/${e}"
      if [[ -d "${d}/${e}" ]]; then
        if [[ -e "${d}/${e}/environment.conf" ]]; then
          mkdir -p "${droppath}"
          cp -Lp "${d}/${e}/environment.conf" "${droppath}"
        fi

        if [[ -e "${d}/${e}/hiera.yaml" ]]; then
          mkdir -p "${droppath}"
          cp -Lp "${d}/${e}/hiera.yaml" "${droppath}"
        fi

        break
      fi
    done
  done
}

# Gather current database settings
#
# This function runs a database query that gets the current effective
# value of PostgreSQL settings. This output can be compared against
# config files like postgresql.conf.
#
# Global Variables Used:
#   DROP
#   SERVER_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
get_db_settings() {
  local postgres_settings_query="select * from pg_settings;"

  run_diagnostic --user pe-postgres "${SERVER_BIN_DIR?}/psql -x -c \"${postgres_settings_query}\"" "enterprise/postgres_settings.txt"
}

get_rbac_directory_settings_info() {
    local t_rbac_info_query="SELECT row_to_json(row) FROM ( SELECT \
id, display_name, help_link, type, hostname, port, ssl, login, \
connect_timeout, base_dn, user_rdn, user_display_name_attr, user_email_attr, \
user_lookup_attr, group_rdn, group_object_class, group_name_attr, \
group_member_attr, group_lookup_attr FROM directory_settings) row;"

    run_diagnostic --user pe-postgres "${SERVER_BIN_DIR?}/psql -d pe-rbac -c \"${t_rbac_info_query}\"" "enterprise/rbac_directory_settings.json"
}

# Check for thundering herds
#
# This function runs a database query that checks the
# distribution of agent run start times by using the
# PuppetDB reports table.
#
# Global Variables Used:
#   SERVER_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
check_thundering_herd() {
  local thundering_herd_query="select date_part('month', start_time) as month, date_part('day', start_time) as day, date_part('hour', start_time) as hour, date_part('minute', start_time) as minute, count(*) from reports where start_time between now() - interval '7 days' and now() GROUP BY date_part('month', start_time), date_part('day', start_time), date_part('hour', start_time), date_part('minute', start_time) ORDER BY date_part('month', start_time) DESC, date_part('day', start_time) DESC, date_part( 'hour', start_time ) DESC, date_part('minute', start_time) DESC;"

  run_diagnostic --user pe-postgres "${SERVER_BIN_DIR?}/psql -d pe-puppetdb -c \"${thundering_herd_query}\"" "enterprise/thundering_herd_query.txt"
}

# Pull the database statistics
db_stat_checks() {
  run_diagnostic --user pe-postgres "${SERVER_BIN_DIR}/psql -c 'select * from pg_stat_activity order by query_start'" "enterprise/db_stat_activity.txt"
}


filesync_state() {
  if [ -x /opt/puppetlabs/server/data/puppetserver/filesync ]; then
    run_diagnostic "du -h --max-depth=1 /opt/puppetlabs/server/data/puppetserver/filesync/" "resources/filesync_repo_sizes_from_du.txt"

    # If explicitly requested, grab filesync data.
    if [ "$FILESYNC" = "y" ]; then
      cp -Rp /opt/puppetlabs/server/data/puppetserver/filesync "${DROP?}/enterprise"
    fi
  fi
}

# Collects output from the PuppetDB status endpoints
#
# Global Variables Used:
#   PUPPET_BIN_DIR
#
# Arguments:
#   None
#
# Returns:
#   None
puppetdb_status() {
  local q_puppetdb_plaintext_port

  if [ -d /etc/puppetlabs/puppetdb ]; then
    q_puppetdb_plaintext_port="$(get_ini_field '/etc/puppetlabs/puppetdb/conf.d/jetty.ini' 'port')"
    run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -X GET http://127.0.0.1:${q_puppetdb_plaintext_port}/status/v1/services?level=debug" "enterprise/puppetdb_status.json"
    run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -X GET http://127.0.0.1:${q_puppetdb_plaintext_port}/pdb/admin/v1/summary-stats" "enterprise/puppetdb_summary_stats.json"
    run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -X GET http://127.0.0.1:${q_puppetdb_plaintext_port}/pdb/query/v4 --data-urlencode 'query=nodes[certname] {deactivated is null and expired is null}'" "enterprise/puppetdb_nodes.json"
  fi
}

# Curls the classifier groups endpoint
classifier_data() {
  if $CLASSIFIER ; then
    agent_cert=$(get_puppet_config "agent" "hostcert")
    agent_key=$(get_puppet_config "agent" "hostprivkey")

    run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -k https://${PLATFORM_HOSTNAME}:4433/classifier-api/v1/groups --cert ${agent_cert} --key ${agent_key}" "enterprise/classifier.json"
  fi
}

# Write metadata to a JSON file
#
# This function writes out a metadata file which contains information about
# which script version was run. This will help future generations reason about
# support script output and parse data.
#
# Global Variables Used:
#   DROP
#   SCRIPT_VERSION
#   TICKET
#   TIMESTAMP
#
# Arguments:
#   None
#
# Returns:
#   None
write_metadata() {
  cat <<EOF > "${DROP?}/metadata.json"
{
  "version": "${SCRIPT_VERSION}",
  "ticket": "${TICKET}",
  "timestamp": "${TIMESTAMP}"
}
EOF
}

# Parameter Processing
#
# Optional support ticket parameter
# Optional output path parameter
# Global Variables Used:
#  DEFAULT_OUTPUT_DIRECTORY
#  OUTPUT_DIRECTORY
#  TICKET
#
# Arguments:
#   $@
read_params() {
  OUTPUT_DIRECTORY="$DEFAULT_OUTPUT_DIRECTORY"
  TICKET=
  CLASSIFIER=false
  ENCRYPT_OUTPUT=false
  MAX_LOG_AGE='14'
  local OPTARG opt
  while getopts ":d:l:t:ce" opt; do
    case $opt in
      d) OUTPUT_DIRECTORY="$OPTARG"
        ;;
      l)
        if [[ $OPTARG != *[!0-9]* || $OPTARG = 'all' ]]; then
          MAX_LOG_AGE="${OPTARG}"
        else
          fail "The argument to -l must be a number or the string 'all'. Got: ${OPTARG}"
        fi
        ;;
      t) TICKET="$OPTARG"
        ;;
      c) CLASSIFIER=true
        ;;
      e) ENCRYPT_OUTPUT=true
        if cmd gpg2; then
          GPG_CMD='gpg2'
        elif cmd gpg; then
          GPG_CMD='gpg'
        else
          fail "Could not find gpg or gpg2 on the PATH.  GPG must be installed to use the --encrypt option."
        fi
        ;;
      \?) echo "Invalid option -$OPTARG" >&2
        ;;
    esac
  done
}

#===[Main]======================================================================

display "Puppet Enterprise Support Script v${SCRIPT_VERSION}"

# Read command line parameters
read_params "$@"

# Default to no collection of filesync data
FILESYNC=${FILESYNC:-n}

detect_platform

case "${PLATFORM_NAME?}" in
  solaris)
    if [[ "${EUID?}" -ne 0 ]]; then
      fail "${SCRIPT_NAME?} must be run as root"
    fi
    ;;
  *)
    if [[ "$(id -u)" -ne 0 ]]; then
      fail "${SCRIPT_NAME?} must be run as root"
    fi
    ;;
esac

# Verify directory for drop files
if [ -d "$OUTPUT_DIRECTORY" ]; then 
  if [ -L "$OUTPUT_DIRECTORY" ]; then
    fail "Output directory $OUTPUT_DIRECTORY cannot be a symlink."
  fi
else
 fail "Output directory $OUTPUT_DIRECTORY does not exist."
fi

# Verify space for drop files
if [[ -d /var/log/puppetlabs ]]; then
  LOGDIR_SIZE=$(du -s /var/log/puppetlabs/ | cut -f 1)
else
  LOGDIR_SIZE=0
fi

if [[ -d /opt/puppetlabs/pe_metric_curl_cron_jobs ]]; then
  METRICS_SIZE=$(du -s /opt/puppetlabs/pe_metric_curl_cron_jobs | cut -f 1)
else
  METRICS_SIZE=0
fi

if [ "x${PLATFORM_NAME?}" = "xsolaris" ]; then
  DF=$(df -b "$OUTPUT_DIRECTORY" | tail -1 | awk '{print $2}')
else
  DF=$(df -Pk "$OUTPUT_DIRECTORY" | tail -n1 | awk '{print $4}')
fi

# Look for at least enough size for the logs, metrics, and 25MB of overhead
# We multiply by 2 since we make a copy before compressing.  Although the 
# compressed copy should be significantly smaller, there is no way to know
# the ratio for certain, so we err on the side of caution
TARGET_SIZE=$((LOGDIR_SIZE + METRICS_SIZE + 25600))
TARGET_SIZE=$((TARGET_SIZE * 2))

if [ "$DF" -lt $TARGET_SIZE ]; then
  fail "Not enough disk space in $OUTPUT_DIRECTORY. This script needs $((TARGET_SIZE / 1024)) MB or more to run."
fi

readonly TIMESTAMP=$(date -u '+%Y%m%d%H%M%S')
readonly DROPARRAY=("$OUTPUT_DIRECTORY/puppet_enterprise_support" "$TICKET" "$PLATFORM_HOSTNAME_SHORT" "$TIMESTAMP")
readonly DROP=$(join '_' "${DROPARRAY[@]}")

display "Creating output directory at ${DROP}"

mkdir -p "${DROP}"/{resources,system,system/etc,enterprise/find,networking,logs}
chmod 0700 "${DROP}"
pushd "${DROP}" &> /dev/null

display 'Collecting information'
display_newline

write_metadata

netstat_checks
selinux_checks
iptables_checks
df_checks
facter_checks
etc_checks
hostname_checks
ntp_checks
gather_enterprise_files
get_umask
list_pe_and_module_files
os_checks
package_listing
gem_listing
ps_checks
free_checks
list_all_services
grab_env_vars
can_contact_master
pe_logs
pe_metrics
get_state
other_logs
ifconfig_output

if is_package_installed 'pe-puppetserver'; then
  module_changes
  check_certificates
  check_r10k
  puppetserver_status
  puppetserver_environments
  module_listing
  filesync_state
fi

if is_package_installed 'pe-console-services'; then
  console_status
  classifier_data
fi

if is_package_installed 'pe-orchestration-services'; then
  orchestration_status
  orchestration_inventory
fi

if is_package_installed 'pe-postgresql-server'; then
  db_size_checks
  db_relation_size_checks
  get_db_settings
  get_rbac_directory_settings_info
  check_thundering_herd
  db_stat_checks
fi

if is_package_installed 'pe-puppetdb'; then
  puppetdb_status
fi

if [[ -d /var/lib/peadmin ]]; then
  mco_commands
fi

if is_package_installed 'pe-activemq'; then
  activemq_limits
fi

tar_change_directory=$(dirname "${DROP}")
tar_directory=$(basename "${DROP}")
support_archive="${DROP}.tar.gz"
(umask 0077 && tar cf - -C "${tar_change_directory?}" "${tar_directory?}" | gzip -f9 > "${support_archive?}")

if [[ "${ENCRYPT_OUTPUT}" == 'true' ]]; then
  display "Encrypting output with ${GPG_CMD}"

  # Create a temporary GPG home directory containing the Puppet public key.
  mkdir "${DROP}"/gpg
  chmod 600 "${DROP}"/gpg

  echo "${PUPPET_PUBKEY}" | "${GPG_CMD}" --import --homedir "${DROP}"/gpg

  "${GPG_CMD}" --trust-model always --homedir "${DROP}"/gpg --recipient FD172197 --encrypt  "${support_archive}" || printf "Unable to gpg encrypt the file.\n"

  rm "${support_archive}"

  support_archive="${support_archive}.gpg"
fi

popd &> /dev/null
rm -rf "${DROP}"


display 'Data collected, ready for submission'
display_newline
display "Support data is located at ${support_archive}"
display_newline
display "Current Puppet Enterprise customers:"
display_newline
display "We recommend that you examine the collected data before forwarding to Puppet,"
display "as it may contain sensitive information that you will wish to redact."
display "An overview of data collected by this tool can be found at:"
display_newline
display "  https://docs.puppet.com/pe/latest/overview_getting_support.html#the-pe-support-script"
display_newline
display "Please submit ${support_archive} to Puppet Support using the upload site you've been invited to."
display_newline
display_newline

exit 0
