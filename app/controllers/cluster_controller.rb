class ClusterController < ApplicationController

  def index
    candidates = Lookup.pluck(:cc, :number)
    codes = candidates.map { |e| e[0] }.uniq
    numbers = candidates.map { |e| e[1] }.uniq


    @clusters = Credential.where(phone: numbers, country: codes)
  end

  def new
  	@cluster = Credential.new
  	@cluster.country = ''
  	@cluster.phone = ''
  end

  def create

  end

  def test_mt

    credential = Credential.where(phone: params[:phone], country: params[:country])

    session = Cluster::Session.create(credential.id, credential.username, credential.password)

    code, res = Cluster::Api.send_test_message(session, params[:test_mt])

    

  end
end
