RSpec.shared_examples 'crud read' do
  describe "#GET" do
    it_behaves_like "record not found"

    describe "index" do
      before do
        make_req(api_user, base_url)
      end

      it "will show all #{model}" do
        expect(json_data).to be_an_instance_of(Array)
        expect(json_data.count).to eq(index_count)
      end
    end

    describe "show" do
      before do
        make_req(api_user, base_url(obj.id))
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(expected_show_attributes)
      end
    end
  end
end