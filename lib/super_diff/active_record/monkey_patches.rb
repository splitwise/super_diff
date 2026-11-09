# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class ActiveRecord::Base
  # TODO: Remove this monkey patch if possible
  def attributes_for_super_diff
    id_attrs = Array(self.class.primary_key).compact
    other_attrs = attributes.keys.sort - id_attrs
    attributes_to_hash = ->(keys, hash) { keys.reduce(hash) { |memo, key| memo.merge(key.to_sym => attributes[key]) } }

    attributes_to_hash.call(id_attrs, {})
                      .then { |result| attributes_to_hash.call(other_attrs, result) }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
