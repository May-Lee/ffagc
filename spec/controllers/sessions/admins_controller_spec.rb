describe Sessions::AdminsController do
  let!(:user) { FactoryBot.create(:admin, :activated) }
  let!(:inactive_user) { FactoryBot.create(:admin) }

  describe '#new' do
    it_behaves_like 'sessions new endpoint'
  end

  describe '#create' do
    it_behaves_like 'sessions create endpoint', 'admins', 'admin_id', '/admins/grant_submissions'
  end

  describe '#destroy' do
    it_behaves_like 'sessions destroy endpoint', 'admin_id', '/'
  end
end
