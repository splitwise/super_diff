class A
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def attributes_for_super_diff
    { name: name }
  end
end
