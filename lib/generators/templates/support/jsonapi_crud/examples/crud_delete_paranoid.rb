RSpec.shared_examples 'crud delete paranoid' do
  describe "#DELETE" do
    it_behaves_like "record not found", :delete, { }

    describe "will soft delete a #{model}" do
      before do
        api_user
        expect {
          make_req(api_user, base_url(obj.id), :delete, delete_params(obj.id))
        }.to change { model.with_deleted.count }.by(0)
         .and change { model.count }.by(-1)
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(expected_soft_delete_attributes)
      end
    end

    describe "will not hard delete a #{model} that is already deleted unless specified" do
      before do
        api_user
        deleted_obj
        expect {
          make_req(api_user, base_url(deleted_obj.id), :delete, delete_params(deleted_obj.id, false) )
        }.to change { model.with_deleted.count }.by(0)
                 .and change { model.count }.by(0)
      end

      it "has a valid response" do
        has_http_status(:ok)
        verify_response_body(expected_soft_delete_attributes)
      end
    end

    describe "will not find a deleted record" do
      before do
        user_req(api_user, :get, base_url(deleted_obj.id), { })
      end

      it "responds like record not found" do
        record_not_found
      end
    end

    describe "will hard delete a #{model}" do
      before do
        api_user
        deleted_obj
        expect {
          make_req(api_user, base_url(deleted_obj.id), :delete, delete_params(deleted_obj.id, true) )
        }.to change { model.with_deleted.count }.by(-1)
         .and change { model.count }.by(0)
      end

      it "has a valid response" do
        has_http_status(:no_content)
      end
    end
  end
end