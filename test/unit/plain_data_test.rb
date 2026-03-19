# frozen_string_literal: true

require "test_helper"

class PlainDataTest < ActiveSupport::TestCase
  test "returns primitives unchanged" do
    assert_equal 42, PlainData.normalize(42)
    assert_equal "hello", PlainData.normalize("hello")
    assert_nil PlainData.normalize(nil)
    assert PlainData.normalize(true)
  end

  test "returns plain Hash unchanged" do
    input = { "a" => 1, "b" => 2 }

    assert_equal input, PlainData.normalize(input)
  end

  test "returns plain Array unchanged" do
    input = [1, 2, 3]

    assert_equal input, PlainData.normalize(input)
  end

  test "converts Hash subclass to plain Hash" do
    subclass = Class.new(Hash)
    input = subclass["a", 1, "b", 2]

    result = PlainData.normalize(input)

    assert_equal({ "a" => 1, "b" => 2 }, result)
    assert_instance_of Hash, result
  end

  test "converts Array subclass to plain Array" do
    subclass = Class.new(Array)
    input = subclass.new([1, 2, 3])

    result = PlainData.normalize(input)

    assert_equal [1, 2, 3], result
    assert_instance_of Array, result
  end

  test "recursively converts nested subclasses" do
    hash_subclass = Class.new(Hash)
    array_subclass = Class.new(Array)

    inner_array = array_subclass.new([1, 2])
    inner_hash = hash_subclass["x", 10]
    input = { "list" => inner_array, "nested" => inner_hash }

    result = PlainData.normalize(input)

    assert_equal({ "list" => [1, 2], "nested" => { "x" => 10 } }, result)
    assert_instance_of Array, result["list"]
    assert_instance_of Hash, result["nested"]
  end

  test "converts JSON::JWK::Set to plain Array" do
    jwk_set = JSON::JWK::Set.new([kty: "RSA", kid: "test-kid"])

    result = PlainData.normalize(jwk_set)

    assert_instance_of Array, result
    assert_equal "test-kid", result.dig(0, "kid")
  end

  test "converts JSON::JWK to plain Hash" do
    jwk = JSON::JWK.new(kty: "RSA", kid: "test-kid")

    result = PlainData.normalize(jwk)

    assert_instance_of Hash, result
    assert_equal "test-kid", result["kid"]
  end
end
