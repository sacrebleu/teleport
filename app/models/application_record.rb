# frozen_string_literal: true

# base activerecord class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
