RSpec.shared_examples 'crud create' do |data_source|
  describe "#POST" do

    data_source.create_requests.each do |req|
      describe "will create a valid model" do
        before do
          expect {
            send(data_source.create_req, :post, data_source.base_url, data_source.eval_params(req[:params]))
          }.to change { data_source.model.count }
        end

        it "has a valid response" do
          has_http_status(:created)
          verify_response_body(req[:expects])
        end
      end
    end

    describe "will NOT create an invalid model" do
      before do
        expect {
          send(data_source.create_req, :post, data_source.base_url, data_source.eval_params(data_source.invalid_params))
        }.to_not change { data_source.model.count }
      end

      it "responds with unprocessable_identity" do
        unprocessable_entity
      end
    end

    describe "will show an error if parameters are missing" do
      before do
        send(data_source.create_req, :post, data_source.base_url, data_source.missing_data_params)
      end

      it "responds with bad_request" do
        bad_request
      end
    end
  end
end