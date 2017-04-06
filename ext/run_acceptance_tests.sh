#!/bin/bash

# A small shell script that spawns a beaker test for each PE
# infrastructure platform, in parallel, then launches a
# webserver to display the test results. Defaults to testing
# the latest good LTS build, but can be directed at other
# release series by passing an X.Y version number
# as an argument:
#
#     ./ext/run_acceptance_tests.sh 2017.1

PE_TEST_SERIES=${1-"2017.2"}
LATEST_GOOD_BUILD=$(curl -q "http://getpe.delivery.puppetlabs.net/latest/${PE_TEST_SERIES}")

echo "Testing build: ${LATEST_GOOD_BUILD?}"

export BEAKER_PE_DIR="http://enterprise.delivery.puppetlabs.net/${PE_TEST_SERIES}/ci-ready/"
export BEAKER_PE_VER="${LATEST_GOOD_BUILD}"

execute_beaker() {
  # Changing preserve-hosts to "onfail" will leave VMs behind for debugging.
  bundle exec beaker \
    --preserve-hosts never \
    --config "$1" \
    --debug \
    --keyfile ~/.ssh/id_rsa-acceptance \
    --pre-suite tests/beaker/pre-suite | \
  grep 'PE-15434' | while read line; do
    echo "${1}: ${line}"
  done
}

pids=""
for config in tests/beaker/configs/* ; do
  echo "Spawning test for: $(basename "${config}")"
  execute_beaker "${config}" &
  pids="${pids} $!"
done

for pid in ${pids};do
  wait "${pid}"
done

pushd junit &> /dev/null || exit 1
python -m SimpleHTTPServer
