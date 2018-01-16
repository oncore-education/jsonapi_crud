RSpec.shared_examples 'crud delete paranoid' do |data_source|
  describe "#DELETE" do
    it_behaves_like "record not found",data_source, :delete

    describe "will soft delete a model" do
      before do
        api_user
        obj
        expect {
          make_req(api_user, data_source.base_url(obj.id), :delete, data_source.delete_params(obj.id))
        }.to change { data_source.model.with_deleted.count }.by(0)
         .and change { data_source.model.count }.by(-1)
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(data_source.expected_soft_delete_attributes)
      end
    end

    describe "will not hard delete a model that is already deleted unless specified" do
      before do
        api_user
        deleted_obj
        expect {
          make_req(api_user, data_source.base_url(deleted_obj.id), :delete, data_source.delete_params(deleted_obj.id, false) )
        }.to change { data_source.model.with_deleted.count }.by(0)
                 .and change { data_source.model.count }.by(0)
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(data_source.expected_soft_delete_attributes)
      end
    end

    describe "will not find a deleted record" do
      before do
        user_req(api_user, :get, data_source.base_url(deleted_obj.id), data_source.default_params)
      end

      it "responds like record not found" do
        record_not_found
      end
    end

    describe "will hard delete a model" do
      before do
        api_user
        deleted_obj
        expect {
          make_req(api_user, data_source.base_url(deleted_obj.id), :delete, data_source.delete_params(deleted_obj.id, true) )
        }.to change { data_source.model.with_deleted.count }.by(-1)
         .and change { data_source.model.count }.by(0)
      end

      it "has a valid response" do
        has_http_status(:no_content)
      end
    end
  end
end