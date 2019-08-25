describe Sessions::ArtistsController do
  let!(:user) { FactoryBot.create(:artist, :activated) }
  let!(:inactive_user) { FactoryBot.create(:artist) }

  describe '#new' do
    it_behaves_like 'sessions new endpoint'
  end

  describe '#create' do
    it_behaves_like 'sessions create endpoint', 'artists', 'artist_id', '/grant_submissions'
  end

  describe '#destroy' do
    it_behaves_like 'sessions destroy endpoint', 'artist_id', '/'
  end
end
