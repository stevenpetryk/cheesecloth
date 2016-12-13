# frozen_string_literal: true

module CheeseCloth
  class MissingScopeError < StandardError
    def initialize(klass)
      @klass = klass
    end

    def message
      <<-MSG.strip_heredoc
        Was unable to determine the base scope. Perhaps you forgot to call `scope`?"

        Try something like:

        class #{@klass.name}
          include CheeseCloth

          scope -> { Model.all }
        end
      MSG
    end
  end
end
