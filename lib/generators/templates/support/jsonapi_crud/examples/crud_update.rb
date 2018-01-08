RSpec.shared_examples 'crud update' do
  describe "#PATCH" do
    it_behaves_like "record not found", :patch, { }

    describe "will update a #{model}" do
      before do
        make_req(api_user, base_url(obj.id), :patch, update_params)
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(expected_update_attributes)
      end
    end

    describe "will show an error if parameters are missing" do
      before do
        make_req(api_user, base_url(obj.id), :patch, { })
      end

      it "responds with bad request" do
        bad_request
      end
    end

    unprocessable_parms.each do |p|
      describe "will not update with invalid attributes" do

        before do
          make_req(api_user, base_url(obj.id), :patch, p )
        end

        it "responds with unprocessable entity" do
          unprocessable_entity
        end
      end
    end
  end
end