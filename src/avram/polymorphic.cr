module Avram::Polymorphic
  macro polymorphic(name, associations)
    def {{ name.id }}
      # Generates something like: post || video
      {{ associations.map(&.id).join(" || ").id }}
    end

    def {{ name.id }}!
      # Generates something like: post! || video!
      {% associations_with_a_bang = associations.map(&.id).map { |assoc| "#{assoc}!" } %}
      {{ associations_with_a_bang.join(" || ").id }}
    end

    macro finished
      class SaveOperation
        before_save do
          {% list_of_foreign_keys = associations.map(&.id).map { |assoc| "#{assoc.id}_id".id } %}

          # TODO: Needs to  actually get the foreign key from the ASSOCIATIONS constant
          validate_at_most_one_filled {{ list_of_foreign_keys.map(&.id).join(", ").id }}
        end
      end
    end
  end
end
