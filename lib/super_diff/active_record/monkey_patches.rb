# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class ActiveRecord::Base
  # TODO: Remove this monkey patch if possible
  def attributes_for_super_diff
    id_attr = self.class.primary_key

    (attributes.keys.sort - [id_attr]).reduce(
      { id_attr.to_sym => id }
    ) { |hash, key| hash.merge(key.to_sym => attributes[key]) }
  end
end
# rubocop:enable Style/ClassAndModuleChildren
