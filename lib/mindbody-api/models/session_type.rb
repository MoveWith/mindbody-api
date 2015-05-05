module MindBody
  module Models
    class SessionType < Base
      attribute :id, Integer
      attribute :name, String
      attribute :num_deducted, Integer
    end
  end
end
