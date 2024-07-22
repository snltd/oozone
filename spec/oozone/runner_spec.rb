#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require_relative '../spec_helper'
require_relative '../../lib/oozone/runner'

# Test runner methods
#
class TestRunner < Minitest::Test
  include Oozone::Runner

  def test_execute!
    assert_nil(execute!('/bin/echo string', return_output: false))
    assert_nil(execute!('/bin/echo string'))
    assert_equal("string\n", execute!('/bin/echo string', return_output: true))

    assert_raises(Errno::ENOENT) { execute!('/no/such/command') }

    out, err = capture_io do
      assert_raises(SystemExit) { execute!('/bin/false') }
    end

    assert_match(/OUTPUT BEGINS/, out)
    assert_match(/OUTPUT ENDS/, out)
    assert_empty(err)
  end

  def test_executes_successfully?
    assert executes_successfully?('/bin/true')
    assert_silent { executes_successfully?('/bin/ls') }
    refute executes_successfully?('/bin/false')
  end

  def test_execute_for_output!
    assert_equal('string', execute_for_output!('/bin/echo string'))
    assert_raises(Errno::ENOENT) { execute_for_output!('/no/such/command') }
    assert_match(/No such file or directory/,
                 execute_for_output!('/bin/ls /no/such/dir'))
  end

  def test_zexecute!
    skip unless ZLOGIN.exist?
    execute = Spy.on(self, :execute!)
    zexecute!('/bin/true', 'test-zone')
    assert_equal(1, execute.calls.count)
    assert_equal(["#{ZLOGIN} /bin/true \"test-zone\""],
                 execute.calls.first.args)
    execute.unhook

    # This will fail if you run the test in the global zone. But why would you
    # ever do that?
    #
    assert_output(
      "---- OUTPUT BEGINS ------------------\n" \
      "zlogin: 'zlogin' may only be used from the global zone\n" \
      "---- OUTPUT ENDS --------------------\n" \
      "exited 1\n",
      nil
    ) do
      assert_raises(SystemExit) do
        zexecute!('/bin/true', 'test-zone')
      end
    end
  end

  def test_ssh_execute!
    input = {
      user: 'tester',
      host: 'testhost',
      cmd: 'testcmd'
    }

    popen = Spy.on(Open3, :popen3)

    ssh_execute!(input)

    assert_equal(1, popen.calls.count)
    assert_equal(
      ["/bin/ssh -o StrictHostKeyChecking=no tester@testhost 'testcmd'"],
      popen.calls.first.args
    )
    popen.unhook
  end

  def test_cope_with_failure
    assert_output(
      "---- OUTPUT BEGINS ------------------\n" \
      "test failure\n" \
      "---- OUTPUT ENDS --------------------\n" \
      "exited 4\n",
      nil
    ) do
      system_exit = assert_raises(SystemExit) do
        cope_with_failure('test failure', 4)
      end

      assert_equal(4, system_exit.status)
    end
  end

  def test_safe_copy!
    dest_dir = Pathname.new('/tmp/testtarget')
    dest_file = dest_dir.join('target.yaml')

    refute dest_dir.exist?
    refute dest_file.exist?

    safe_copy!(RES_DIR.join('test_zone_01.yaml'), dest_file)

    assert dest_dir.exist?
    assert dest_file.exist?

    FileUtils.rm_r(dest_dir)
  end
end
