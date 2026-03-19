# frozen_string_literal: true

# Recursively converts Hash/Array subclasses to plain Ruby types.
#
# Rails 8.1's JSONGemCoderEncoder calls as_json on Array/Hash subclasses,
# which can produce unexpected structures (e.g. JSON::JWK::Set#as_json
# returns {keys: [...]} instead of a plain array). Use this at serialization
# boundaries to normalize data before JSON encoding.
module PlainData
  module_function

  def normalize(value)
    case value
    when Hash then value.to_h { |k, v| [k, normalize(v)] }
    when Array then value.map { |v| normalize(v) }
    else value
    end
  end
end
