module SolandraObject
  module Timestamps
    extend ActiveSupport::Concern

    included do
      time :created_at
      time :updated_at

      before_create do
        self.created_at ||= Time.current
        self.updated_at ||= Time.current
      end

      before_update :if => :changed? do
        self.updated_at = Time.current
      end
    end
  end
end
