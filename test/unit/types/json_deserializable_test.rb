# frozen_string_literal: true

require "test_helper"

class Types::JsonDeserializableTest < ActiveSupport::TestCase
  class DummyArray < Array
    def as_json(*)
      { "unexpected" => "structure" }
    end
  end

  setup do
    @type = Types::JsonDeserializable.new(DummyArray)
  end

  test "cast_value with nil" do
    assert_nil @type.cast_value(nil)
  end

  test "cast_value with instance of klass" do
    instance = DummyArray.new([1, 2, 3])

    result = @type.cast_value(instance)

    assert_equal instance, result
    assert_instance_of DummyArray, result
  end

  test "cast_value with raw data" do
    raw_data = [1, 2, 3]
    expected = DummyArray.new(raw_data)

    result = @type.cast_value(raw_data)

    assert_equal expected, result
    assert_instance_of DummyArray, result
  end

  test "deserialize parses JSON and casts to klass" do
    json_string = "[1,2,3]"
    expected = DummyArray.new([1, 2, 3])

    result = @type.deserialize(json_string)

    assert_equal expected, result
    assert_instance_of DummyArray, result
  end

  test "serialize converts custom Array/Hash subclasses to bypass their overridden as_json" do
    input = DummyArray.new([1, 2, 3])

    # If it weren't for `PlainData`, Rails 8.1's JSON encoder would call DummyArray#as_json,
    # resulting in `"{\"unexpected\":\"structure\"}"`.
    # Because `PlainData.normalize` strips the object identity, it serializes as a plain array.
    serialized = @type.serialize(input)

    assert_equal "[1,2,3]", serialized
  end

  test "serialize handles nil" do
    assert_nil @type.serialize(nil)
  end
end
