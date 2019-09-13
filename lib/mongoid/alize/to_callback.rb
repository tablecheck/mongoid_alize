require 'mongoid/compatibility'

module Mongoid
  module Alize
    class ToCallback < Callback

      def attach
        define_denorm_attrs

        define_callback
        alias_callback
        set_callback

        define_destroy_callback
        alias_destroy_callback
        set_destroy_callback
      end

      def define_callback
        klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1

          def #{callback_name}#{force_param}

            #{iterable_relation}.each do |relation|
              next if relation.attributes.frozen?

              is_one = #{is_one?}
              if is_one
                field_values = #{field_values("self")}
              else
                field_values = #{field_values("self", :id => true)}
              end

              prefixed_name = #{prefixed_name}
              if is_one
                #{relation_set('prefixed_name', 'field_values')}
              else
                #{pull_from_inverse}
                #{relation_push('prefixed_name', 'field_values')}
              end

            end

            #{debug ? "puts \"#{callback_name}\"": ""}
            true
          end
          protected :#{callback_name}
        CALLBACK
      end

      def define_destroy_callback
        klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1

          def #{destroy_callback_name}
            #{iterable_relation}.each do |relation|
              next if relation.attributes.frozen?

              is_one = #{is_one?}
              prefixed_name = #{prefixed_name}
              if is_one
                #{relation_unset('prefixed_name')}
              else
                #{pull_from_inverse}
              end
            end

            #{debug ? "puts \"#{destroy_callback_name}\"": ""}
            true
          end
          protected :#{destroy_callback_name}
        CALLBACK
      end

      def pull_from_inverse
        <<-RUBIES
          #{relation_pull('prefixed_name', '{ "_id" => self.id }')}
          if _f = relation.send(prefixed_name)
            _f.reject! do |hash|
              hash["_id"] == self.id
            end
          end
        RUBIES
      end

      def prefixed_name
        if inverse_relation
          ":#{inverse_relation}_fields"
        else
          <<-RUBIES
            (#{find_relation}.name.to_s + '_fields')
          RUBIES
        end
      end

      def relation_set(field, value)
        Mongoid::Compatibility::Version.mongoid4_or_newer? ? "relation.set(#{field}.to_sym => #{value})" : "relation.set(#{field}, #{value})"
      end

      def relation_unset(field)
        "relation.unset(#{field}.to_sym)"
      end

      def relation_pull(field, value)
        Mongoid::Compatibility::Version.mongoid4_or_newer? ? "relation.pull(#{field}.to_sym => #{value})" : "relation.pull(#{field}, #{value})"
      end

      def relation_push(field, value)
        Mongoid::Compatibility::Version.mongoid4_or_newer? ? "relation.push(#{field}.to_sym => #{value})" : "relation.push(#{field}, #{value})"
      end

      def is_one?
        if inverse_relation
          if self.inverse_metadata.relation.superclass == Mongoid::Associations::One
            "true"
          else
            "false"
          end
        else
          <<-RUBIES
            (#{find_relation}.relation.superclass == Mongoid::Associations::One)
          RUBIES
        end
      end

      def find_relation
        "relation.class.associations.values.find { |metadata| metadata.inverse(self) == :#{relation} && metadata.class_name == self.class.name }"
      end

      def iterable_relation
        "[self.#{relation}].flatten.compact"
      end

      def set_callback
        unless callback_attached?("save", aliased_callback_name)
          klass.set_callback(:save, :after, aliased_callback_name)
        end
      end

      def set_destroy_callback
        unless callback_attached?("destroy", aliased_destroy_callback_name)
          klass.set_callback(:destroy, :after, aliased_destroy_callback_name)
        end
      end

      def alias_destroy_callback
        unless callback_defined?(aliased_destroy_callback_name)
          klass.send(:alias_method, aliased_destroy_callback_name, destroy_callback_name)
          klass.send(:public, aliased_destroy_callback_name)
        end
      end

      def aliased_destroy_callback_name
        :"denormalize_destroy_#{direction}_#{relation}"
      end

      def destroy_callback_name
        :"_#{aliased_destroy_callback_name}"
      end

      def direction
        "to"
      end

    end
  end
end
