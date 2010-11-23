class Context
  attr_accessor :failures

  def initialize(parent=nil, &block)
    @block = block
    @failures = []
    @subcontexts = {}
    @tests = {}
    @parent = parent
    instance_eval(&@block)
  end

  def run
    all_tests.each { |t| t.run }
    all_subcontexts.each { |s| s.run }
  end

  def context(name, &block)
    @subcontexts[methodize(name)] = self.class.new(self, &block)
  end

  def setup(&setup_block)
    @setup_block = setup_block
  end

  def run_setups(environment)
    @parent.run_setups(environment) if @parent
    environment.instance_eval(&@setup_block) if @setup_block
  end

  def should(name, &block)
    @tests[methodize(name)] = Test.new(self, &block)
  end

  def passed?
    @failures.empty? && all_subcontexts.inject(true) { |result, s| result && s.passed? }
  end

  def method_missing(name, *args)
    @subcontexts[name] || @tests[name]
  end

  class Test
    def initialize(context, &block)
      @context = context
      @test_block = block
    end

    def run
      environment = TestEnvironment.new(@context)
      @context.run_setups(environment)
      environment.instance_eval(&@test_block)
    end
  end

  class TestEnvironment
    def initialize(context)
      @context = context
    end

    def assert(expression, message=nil)
      unless expression
        @context.failures << message
      end
    end

    def assert_equal(expected, actual)
      assert actual == expected, "Expected #{expected.inspect} but got #{actual.inspect}"
    end
  end

  private

  def methodize(name)
    name.gsub(" ", "_").to_sym
  end

  def all_subcontexts
    @subcontexts.values
  end

  def all_tests
    @tests.values
  end

end