require 'test/unit'
require '../jtest'

class JTestTest < Test::Unit::TestCase
  def test_should_pass_when_all_tests_pass
    x = context "Given something" do
      should "work" do
        assert true
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_fail_when_all_tests_fail
    x = context "Given something" do
      should "work" do
        assert false
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_fail_when_any_tests_fail
    x = context "Given something" do
      should "work" do
        assert false
      end
      should "also work" do
        assert true
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_setup_to_provide_instance_variables
    x = context "Given something" do
      setup do
        @name = "james"
      end
      should "work" do
        assert_equal "james", @name
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_run_setup_before_every_test
    x = context "Given something" do
      setup do
        @name = "james"
      end
      should "work" do
        @name += " is awesome"
        assert_equal "james is awesome", @name
      end
      should "also work" do
        @name += " is the best"
        assert_equal "james is the best", @name
      end
    end
    x.run
    assert x.passed?, x.failures
  end

  def test_should_allow_nesting_of_contexts
    x = context "Given something" do
      context "and another thing" do
        should "work" do
          assert false
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_multiple_subcontexts
    x = context "Given something" do
      context "and another thing" do
        should "work" do
          assert false
        end
      end
      context "and another thing" do
        should "work" do
          assert true
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_deep_nesting_of_subcontexts
    x = context "Given something" do
      context "and another thing" do
        context "and one more thing" do
          should "work" do
            assert false
          end
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_call_all_setup_methods_when_running_tests_in_a_nested_context
    x = context "Given something" do
      setup do
        @name = "james"
      end
      context "and another thing" do
        setup do
          @name += " is amazing"
        end
        should "work" do
          assert_equal "james is amazing", @name
        end
      end
    end
    x.run
    assert x.passed?
  end

  private

  def context(name, &block)
    Context.new(&block)
  end
end