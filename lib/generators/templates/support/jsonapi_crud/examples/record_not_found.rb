RSpec.shared_examples "record not found" do |method, params, url|
  before do
    method ||= :get
    params ||= {}
    url ||=  base_url(-1)
    user_req(api_user, method, url, params)
  end

  it "has a valid response" do
    record_not_found
  end
end