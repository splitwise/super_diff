class Person
  attr_accessor :name, :age

  def initialize(name:, age:)
    @name = name
    @age = age
  end
end

describe "My test" do
  it "does something" do
    actual = {
      customer: {
        person: Person.new(name: "Marty McFly, Jr.", age: 17),
        shipping_address: {
          line_1: "456 Ponderosa Ct.",
          city: "Hill Valley",
          state: "CA",
          zip: "90382"
        }
      },
      items: [
        {
          name: "Fender Stratocaster",
          cost: 100_000,
          options: %w[red blue green]
        },
        { name: "Mattel Hoverboard" }
      ]
    }

    expected = {
      customer: {
        person: Person.new(name: "Marty McFly", age: 17),
        shipping_address: {
          line_1: "123 Main St.",
          city: "Hill Valley",
          state: "CA",
          zip: "90382"
        }
      },
      items: [
        {
          name: "Fender Stratocaster",
          cost: 100_000,
          options: %w[red blue green]
        },
        { name: "Chevy 4x4" }
      ]
    }

    expect(actual).to eq(expected)
  end
end
