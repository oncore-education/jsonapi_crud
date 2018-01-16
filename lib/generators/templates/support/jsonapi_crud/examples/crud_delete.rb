RSpec.shared_examples 'crud delete' do |data_source|
  describe "#DELETE" do
    it_behaves_like "record not found", data_source, :delete

    describe "will hard delete a #{model}" do
      before do
        api_user
        deleted_obj
        expect {
          make_req(api_user, data_source.base_url(deleted_obj.id), :delete, data_source.delete_params(deleted_obj.id, true) )
        }.to change { data_source.model.count }.by(-1)
      end

      it "has a valid response" do
        has_http_status(:no_content)
      end
    end
  end
end