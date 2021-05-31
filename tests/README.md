Unit Tests
==========

NOTE
:   The `unittest` command uses namespaces to isolate itself and the
    tests it runs from the running firewall. It needs user namespaces
    to be enabled.

Run tests as:

~~~~
./unittest directory-or-conffile...
~~~~

Any number of files and directories (in which case all .conf files found
are tested) can be specified.

The base-name of the directory is used to determine the tool to run with.
e.g. all `.conf` files under `firehol/` are expected to run as FireHOL
configurations.


Writing new test configurations
===============================

We will consider a new test `mytest`.

This test consists of a standard `mytest.conf` somewhere under the
directory for the program. It may be in any subdirectory.

In addition the following optional scripts may be present, at the
same level as the test. If they have their execute bit set, then:

*   `mytest.pre.sh` - this is run before the script, e.g. to set up a
    custom `/etc/firehol` directory (the default is empty) or to
    pre-load extra state for checking.

*   `mytest.run.sh` - this is used instead of running the script
    in normal `start` mode, e.g. if we want to test a different
    command line. It also works well if the expected status
    is non-zero (maybe we are testing that an error is produced) - we
    can check the value we want and return 0 if what we wanted to
    happen, happened.

*   `mytest.check.sh` - this is used in addition to the standard
    output checks e.g. if we want to identify specific content in
    the output logfile.

All the optional scripts are expected to return 0 if they consider
themselves successful. Any other status is treated as an error. A
simple example of all three is the `firehol/cmdline/stop-test.conf`
setup.

The scripts have access to these environment variables:

* `conf` - the config file path
* `pre_sh` - the pre-run script path
* `run_sh` - the run script path
* `post_sh` - the post-run script path
* `runlog` - the logfile where command output should go

FireHOL scripts can use these:

* `out4` - the iptables output
* `out6` - the ip6tables output
* `aud4` - the expected iptables output
* `aud6` -the expected ip6tables output

FireQOS scripts can use these:

* `outqdisc` - the tc qdisc output
* `outclass` - the tc class output
* `outfilter` - the tc filter output
* `audqdisc` - the expected tc qdisc output
* `audclass` - the expected tc class output
* `audfilter` - the expected tc filter output

If any script returns an error the standard output checks are skipped.
Otherwise following checks are made:

For FireHOL tests
:   The files `mytest.out4` and  `mytest.out6` will be compared to
    the output of `iptables-save` and `ip6tables-save` to check that
    the expected firewall has been produced and is running.

    Note that the the expectation is the outputs will all have
    been processed by `tools/clean-iptables` which imposes some
    additional consistency to make diffs easier. The audits
    should have similarly been processed.

    In particular, specifying IPv6 addresses as e.g. `::10.0.0.1`
    will ensure the test output will be identical to the IPv4
    equivalent `10.0.0.1`.

For FireQOS tests
:   The files `mytest.qdisc.out`, `mytest.class.out` ands
    `mytest.filter.out` will be compared to the output
    of `tc [type] show dev veth0` to check that the expected
    traffic control configuration has been produced and is running.

    Note the use of `veth0` which is set up automatically and is
    the only device which will be checked, so it must be the
    interface used in test configurations.

For Link Balancer tests
:   TODO
