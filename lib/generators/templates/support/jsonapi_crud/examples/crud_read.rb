RSpec.shared_examples 'crud read' do |data_source, examples|
  examples ||= [:index, :show]

  describe "#GET" do
    it_behaves_like "record not found", data_source

    if examples.include?(:index)
      describe "index" do
        before do
          make_req(api_user, data_source.base_url)
        end

        it "will show all models" do
          expect(json_data).to be_an_instance_of(Array)
          expect(json_data.count).to eq(data_source.index_count)
        end
      end
    end

    describe "show" do
      before do
        make_req(api_user, data_source.base_url(obj.id), :get, data_source.default_params)
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(data_source.expected_show_attributes)
      end
    end
  end
end