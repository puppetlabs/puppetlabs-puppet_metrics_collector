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


#===[ Global variables ]================================================
readonly PUPPET_BIN_DIR='/opt/puppetlabs/puppet/bin'
readonly SERVER_BIN_DIR='/opt/puppetlabs/server/bin'
readonly SERVER_DATA_DIR='/opt/puppetlabs/server/data'
readonly SCRIPT_NAME="$(basename "${0}")"
readonly SCRIPT_VERSION='1.2.0'


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
      'suse linux' )
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
#
run_diagnostic() {
  local timeout=''
  # Parse options
  while :
  do
    case "$1" in
      --timeout)
        timeout=$2
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  local t_run_diagnostic__command="${1?}"
  local t_run_diagnostic__outfile="${DROP}/${2?}"

  display " ** Collecting output of \"${t_run_diagnostic__command?}\""
  display_newline

  if [ -n "$timeout" ] ; then
    if [ -x "${PUPPET_BIN_DIR?}/ruby" ] ; then
      local prefix_command="with_timeout $timeout "
    else
      display " ** Warning: --timeout X passed, but PE ruby is not present.  Ignoring timeout flag."
      display_newline
    fi
  fi

  if is_noop; then
    return 0
  else
    ( eval "${prefix_command:-}${t_run_diagnostic__command?} 2>&1" ) >> $t_run_diagnostic__outfile
    return $?
  fi
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

hostname_checks() {
  echo ${PLATFORM_HOSTNAME?} > $DROP/networking/hostname_output.txt

  # this part doesn't work so well if your hostname is mapped to 127.0.x.1 in /etc/hosts

  # See if hostname resolves
  # This won't work on solaris
  if ! [ ${PLATFORM_NAME?} = "solaris" ]; then
    ipaddress=`ping  -t1 -c1 ${PLATFORM_HOSTNAME?} | awk -F\( '{print $2}' | awk -F\) '{print $1}' | head -1`
    echo $ipaddress > $DROP/networking/guessed_ip_address.txt
    if cmd tracepath; then
      mapped_hostname=`tracepath $ipaddress | head -1 | awk '{print $2}'`
      echo $mapped_hostname > $DROP/networking/mapped_hostname_from_guessed_ip_address.txt
    fi
  fi
}

can_contact_master() {
  if cmd puppet && [ -f "${PUPPET_BIN_DIR?}/puppet" ]; then
    if [ "x${PLATFORM_NAME?}" = "xsolaris" ]; then
      PING="ping"
    else
      PING="ping -c 1"
    fi

    if $PING $(${PUPPET_BIN_DIR?}/puppet agent --configprint server) &> /dev/null; then
      echo "Master is alive." > $DROP/networking/puppet_ping.txt
    else
      echo "Master is unreachable." > $DROP/networking/puppet_ping.txt
    fi
  else
    echo "No puppet found, master status is unknown." > $DROP/networking/puppet_ping.txt
  fi
}

ifconfig_output() {
  if cmd ifconfig && ifconfig -a &> /dev/null; then
    run_diagnostic "ifconfig -a" "networking/ifconfig.txt"
  fi
}

#===[Resource checks]===========================================================

get_all_database_names() {
  echo "$(sudo -H -u pe-postgres ${SERVER_BIN_DIR?}/psql -t -c 'select datname from pg_catalog.pg_database;' | awk '{print $1}' | grep -v '^template')"
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
    local command="sudo -H -u pe-postgres ${SERVER_BIN_DIR?}/psql $db -c \
\"SELECT '$db' as dbname, nspname || '.' || relname AS relation, \
pg_size_pretty(pg_relation_size(C.oid)) AS size FROM pg_class C \
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) \
WHERE nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast') \
ORDER BY pg_relation_size(C.oid) DESC;\""
    run_diagnostic "${command?}" "resources/db_relation_sizes.txt"
  done
}

db_size_from_psql() {
  local db=$1
  local drop_file=resources/db_sizes_from_psql.txt
  local command="sudo -H -u pe-postgres ${SERVER_BIN_DIR?}/psql -c \"SELECT '$db' AS dbname, pg_size_pretty(pg_database_size('$db'));\""
  run_diagnostic "${command?}" "$drop_file"
}

db_size_from_fs() {
  local db=$1
  local drop_file=resources/db_sizes_from_du.txt
  local oid=$(sudo -H -u pe-postgres "${SERVER_BIN_DIR?}/psql" -t -c "SELECT oid FROM pg_database WHERE datname='$db';")

  run_diagnostic "echo -e -n '${db}\t' ; find ${SERVER_DATA_DIR}/postgresql/ -name ${oid} -print0 | xargs -0 du -sh " "$drop_file"
}

db_size_checks() {
  # Check size of databases, both from the filesystem's perspective and the
  # database's perspective
  local database_names=$(get_all_database_names)
  for db in $database_names; do
    # Find size via psql
    db_size_from_psql $db

    # Find size via filesystem
    db_size_from_fs $db
  done
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
  umask > $DROP/system/umask.txt
}

facter_checks() {
  run_diagnostic "${PUPPET_BIN_DIR?}/puppet facts" "system/facter_output.txt"
}

etc_checks() {
  cp -p /etc/resolv.conf $DROP/system/etc
  cp -p /etc/nsswitch.conf $DROP/system/etc
  cp -p /etc/hosts $DROP/system/etc
  case "${PLATFORM_NAME?}" in
    debian|ubuntu)
      CONFDIR="/etc/default"
    ;;
    *)
      CONFDIR="/etc/sysconfig"
    ;;
  esac
  if [ -f $CONFDIR/mcollective ]; then
    cp -p $CONFDIR/mcollective $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-activemq ]; then
    cp -p $CONFDIR/pe-activemq $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-console-services ]; then
    cp -p $CONFDIR/pe-console-services $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-nginx ]; then
    cp -p $CONFDIR/pe-nginx $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-orchestration-services ]; then
    cp -p $CONFDIR/pe-orchestration-services $DROP/system/etc
  fi
  if [ -d $CONFDIR/pe-pgsql ]; then
    cp -Rp $CONFDIR/pe-pgsql $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-puppetdb ]; then
    cp -p $CONFDIR/pe-puppetdb $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-puppetserver ]; then
    cp -p $CONFDIR/pe-puppetserver $DROP/system/etc
  fi
  if [ -f $CONFDIR/pe-razor-server ]; then
    cp -p $CONFDIR/pe-razor-server $DROP/system/etc
  fi
  if [ -d $CONFDIR/pgsql ]; then
    cp -Rp $CONFDIR/pgsql $DROP/system/etc
  fi
  if [ -f $CONFDIR/puppet ]; then
    cp -p $CONFDIR/puppet $DROP/system/etc
  fi
  if [ -f $CONFDIR/pxp-agent ]; then
    cp -p $CONFDIR/pxp-agent $DROP/system/etc
  fi
}

os_checks() {
  if [ ${PLATFORM_NAME?} = "solaris" ]; then
    # Probably want more information than this here
    echo "Solaris" > $DROP/system/os_checks.txt
  elif cmd lsb_release; then
    run_diagnostic "lsb_release -a" "system/lsb_release.txt"
  fi

  run_diagnostic "uname -a" "system/uname.txt"
  run_diagnostic "uptime" "system/uptime.txt"
}

ps_checks() {
  run_diagnostic "ps -ef" "system/ps_ef.txt"
  $(ps -e f &> /dev/null) && run_diagnostic "ps -e f" "system/ps_tree.txt"
}

list_all_services() {
  case "${PLATFORM_NAME?}" in
    solaris)
      run_diagnostic "svcs -a" "system/services.txt"
    ;;
    rhel|centos|sles)
      run_diagnostic "chkconfig --list" "system/services.txt"
    ;;
    debian|ubuntu)
      # no chkconfig here. thanks debian.
    ;;
    *)
      # unsupported platform
    ;;
  esac
}

grab_env_vars() {
  run_diagnostic "env" "system/env.txt"
}

pe_logs() {
  cp -LpR /var/log/puppetlabs/* "${DROP}/logs"

  if [[ -d '/var/lib/peadmin/.mcollective.d' ]]; then
    mkdir -p "${DROP}/logs/peadmin"
    cp -LpR /var/lib/peadmin/.mcollective.d/client.log* "${DROP}/logs/peadmin"
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

  configured_state_dir=$("${PUPPET_BIN_DIR}/puppet" config print --section=agent statedir)
  state_dir="${configured_state_dir:=/opt/puppetlabs/puppet/cache/state/}"

  cp -LpR "${state_dir}" "${DROP?}/enterprise/state"
}

other_logs() {
  for log in "system" "syslog" "messages"; do
    if [ -f /var/log/${log} ]; then
      cp -pR /var/log/${log} $DROP/logs && gzip -9 $DROP/logs/${log}
    fi
  done
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
  local postgres_config

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

  # NOTE: Echo is used here so that the glob, *, is properly expanded.
  postgres_config=$(echo "${SERVER_DATA_DIR?}"/postgresql/*/data/postgresql.conf)
  if [[ -f "${postgres_config}" ]]; then
    mkdir -p "${DROP}/enterprise/etc/puppetlabs/postgres"
    cp -Lp "${postgres_config}" "${DROP}/enterprise/etc/puppetlabs/postgres"
  fi

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
}

# Display listings of the Puppet Enterprise files and module files
list_pe_and_module_files() {
  local enterprise_dirs="/etc/puppetlabs /opt/puppetlabs /var/lib/peadmin"
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
      find "${dir}" -ls > $DROP/enterprise/find/${dir_desc}.txt
    else
      echo "No directory ${dir}" > $DROP/enterprise/find/${dir_desc}.txt
    fi
  done
}

# Gather all modules installed on the modulepath
module_listing() {
  if [ -f "${PUPPET_BIN_DIR?}/puppet" ]; then
    run_diagnostic "${PUPPET_BIN_DIR?}/puppet module list" "enterprise/modules.txt"
  fi
}

# Check r10k version and deployment status
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

  if [[ -x "${PUPPET_BIN_DIR?}/gem" ]]; then
    run_diagnostic "${PUPPET_BIN_DIR}/gem list r10k" "enterprise/r10k_gem_version.txt"
  fi

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
}

# Gather all changes to the installed Puppet Enterprise modules
module_changes() {
  if [ -f "${PUPPET_BIN_DIR?}/puppet" ]; then
    pe_module_path="/opt/puppetlabs/puppet/modules"
    for module in $(ls "${pe_module_path?}"); do
      echo "${module?}:" >> "${DROP}/enterprise/module_changes.txt"
      run_diagnostic "${PUPPET_BIN_DIR?}/puppet module changes ${pe_module_path?}/${module?}" "enterprise/module_changes.txt"
    done
  fi
}

# Gather all packages that are part of the Puppet Enterprise installation
package_listing() {
  pkg_file=enterprise/packages.txt
  case "${PLATFORM_PACKAGING?}" in
    rpm)
      run_diagnostic "rpm -qa | $PLATFORM_EGREP '^pe-.*'" $pkg_file
    ;;

    dpkg)
      run_diagnostic "dpkg-query -W -f '\${Package}\n' | $PLATFORM_EGREP '^pe-.*$'" $pkg_file
    ;;

    pkgadd)
      run_diagnostic "pkginfo | $PLATFORM_EGREP 'PUP.*'" $pkg_file
    ;;

    *)
      #fail
    ;;
  esac
}

check_certificates() {
  local cadir

  cadir=$("${PUPPET_BIN_DIR?}/puppet" config print --section master cadir)

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
      echo "No such user: '${mco_user}'." > "${DROP}/enterprise/mco_$mco_user.txt"
    fi
  fi
}

activemq_limits() {
  echo "File descriptors in use by pe-activemq:" > $DROP/enterprise/activemq_resource_limits
  if cmd lsof; then
    run_diagnostic "lsof -u pe-activemq | wc -l" "enterprise/activemq_resource_limits"
  else
    echo "lsof: command not found" >> $DROP/enterprise/activemq_resource_limits
  fi

  echo -e "\n\nResource limits for pe-activemq:\n" >> $DROP/enterprise/activemq_resource_limits
  run_diagnostic "su -s /bin/bash pe-activemq -c 'ulimit -a'" "enterprise/activemq_resource_limits"
}

# Curls the status of the console
console_status() {
  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 http://127.0.0.1:4432/status/v1/services?level=debug" "enterprise/console_status.json"
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

  agent_cert=$(${PUPPET_BIN_DIR}/puppet config print --section agent hostcert)
  agent_key=$(${PUPPET_BIN_DIR}/puppet config print --section agent hostprivkey)

  run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 --cert ${agent_cert} --key ${agent_key} -k https://127.0.0.1:8140/puppet/v3/environments" "enterprise/puppetserver_environments.json"
}

get_rbac_directory_settings_info() {
    local t_rbac_info_query="SELECT row_to_json(row) FROM ( SELECT \
id, display_name, help_link, type, hostname, port, ssl, login, \
connect_timeout, base_dn, user_rdn, user_display_name_attr, user_email_attr, \
user_lookup_attr, group_rdn, group_object_class, group_name_attr, \
group_member_attr, group_lookup_attr FROM directory_settings) row;"

    run_diagnostic "sudo -u pe-postgres ${SERVER_BIN_DIR?}/psql -d pe-rbac -c \"${t_rbac_info_query}\"" "enterprise/rbac_directory_settings.json"
}

filesync_state() {
  if [ -x /opt/puppetlabs/server/data/puppetserver/filesync ]; then
    # If explicitly requested, grab filesync data.
    if [ "$FILESYNC" = "y" ]; then
      cp -Rp /opt/puppetlabs/server/data/puppetserver/filesync "$DROP/enterprise"
    fi
  fi
}

get_puppetdb_summary_stats() {
  if [ -d /etc/puppetlabs/puppetdb ]; then
      local q_puppetdb_plaintext_port="$(get_ini_field '/etc/puppetlabs/puppetdb/conf.d/jetty.ini' 'port')"
      run_diagnostic "${PUPPET_BIN_DIR}/curl --silent --show-error --connect-timeout 5 --max-time 60 -X GET http://127.0.0.1:${q_puppetdb_plaintext_port}/pdb/admin/v1/summary-stats" "enterprise/puppetdb_summary_stats.json"
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
  "timestamp": "${TIMESTAMP}"
}
EOF
}

#===[Main]======================================================================

display "Puppet Enterprise Support Script v${SCRIPT_VERSION}"

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

# Verify space for drop files
if [ "x${PLATFORM_NAME?}" = "xsolaris" ]; then
  DF=$(df -b /var/tmp | $PLATFORM_EGREP -v Filesystem | awk '{print $2}')
else
  DF=$(df -Pk /var/tmp | $PLATFORM_EGREP -v Filesystem | awk '{print $4}')
fi

if [ "$DF" -lt "25600" ]; then
  fail "Not enough disk space in /var/tmp. This script needs 25MB or more to run."
fi

readonly TIMESTAMP=$(date -u '+%Y%m%d%H%M%S')
readonly DROP="/var/tmp/puppet_enterprise_support_${PLATFORM_HOSTNAME_SHORT}_${TIMESTAMP}"

display "Creating drop directory at ${DROP?}"

mkdir -p $DROP/{resources,system,system/etc,enterprise/find,networking,logs}
pushd $DROP &> /dev/null

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
ps_checks
free_checks
list_all_services
grab_env_vars
can_contact_master
pe_logs
get_state
other_logs
ifconfig_output

if is_package_installed 'pe-puppetserver'; then
  module_listing
  module_changes
  check_certificates
  check_r10k
  puppetserver_status
  puppetserver_environments
  filesync_state
fi

if is_package_installed 'pe-console-services'; then
  console_status
fi

if is_package_installed 'pe-postgresql-server'; then
  db_size_checks
  db_relation_size_checks
  get_rbac_directory_settings_info
fi

if is_package_installed 'pe-puppetdb'; then
  get_puppetdb_summary_stats
fi

if [[ -d /var/lib/peadmin ]]; then
  mco_commands
fi

if is_package_installed 'pe-activemq'; then
  activemq_limits
fi

support_archive="${DROP?}.tar"
tar cvf ${support_archive?} -C $(dirname $DROP) $(basename $DROP) &> /dev/null
gzip -f9 ${support_archive?}

popd &> /dev/null
rm -rf $DROP


display 'Data collected, ready for submission'
display_newline
display "Support data is located at ${support_archive?}.gz"
display_newline
display "Current Puppet Enterprise customers:"
display "Please submit ${support_archive?}.gz to Puppet Support using the upload site you've been invited to."
display_newline
display_newline

exit 0
