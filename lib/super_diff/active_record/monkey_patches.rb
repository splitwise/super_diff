# rubocop:disable Style/BracesAroundHashParameters, Style/ClassAndModuleChildren
class ActiveRecord::Base
  def attributes_for_super_diff
    (attributes.keys.sort - ["id"]).reduce({ id: id }) do |hash, key|
      hash.merge(key.to_sym => attributes[key])
    end
  end
end
# rubocop:enable Style/BracesAroundHashParameters, Style/ClassAndModuleChildren
