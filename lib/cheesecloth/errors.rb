# frozen_string_literal: true

module CheeseCloth
  class MissingScopeError < StandardError
    def message
      <<-MSG.strip_heredoc
        Was unable to determine the base scope. Perhaps you forgot to call `scope`?"

        Try something like:

        class Foo
          include CheeseCloth

          scope -> { Model.all }
        end
      MSG
    end
  end
end
