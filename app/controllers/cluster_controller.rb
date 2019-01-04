class ClusterController < ApplicationController

  def index
    candidates = Lookup.pluck(:cc, :number)
    codes = candidates.map { |e| e[0] }.uniq
    numbers = candidates.map { |e| e[1] }.uniq


    @clusters = Credential.where(phone: numbers, country: codes)
  end
end
