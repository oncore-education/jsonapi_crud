RSpec.shared_examples 'crud create' do
  describe "#POST" do
    describe "will create a valid #{model}" do
      before do
        expect {
          api_req(:post, base_url, create_params)
        }.to change { model.count }
      end

      it "has a valid response" do
        has_http_status(:created)
        verify_response_body(expected_create_attributes)
      end
    end

    describe "will NOT create an invalid #{model}" do
      before do
        expect {
          api_req( :post, base_url, invalid_params)
        }.to_not change { model.count }
      end

      it "responds with unprocessable_identity" do
        unprocessable_entity
      end
    end

    describe "will show an error if parameters are missing" do
      before do
        api_req(:post, base_url, missing_data_params)
      end

      it "responds with bad_request" do
        bad_request
      end
    end
  end
end