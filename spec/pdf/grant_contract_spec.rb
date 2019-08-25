# If this test fails the grant contracts were probably updated without updating
# the golden files. To fix run `bundle exec rake grant_contracts:create_golden`
# to create new golden files. You should hand-inspect the pdf output to make
# sure it appears correct.

describe GrantContract do
  shared_examples 'generates expected grant document' do |template_name|
    it do
      pdf_fixtures_path = File.join(Rails.root, 'spec', 'fixtures', 'pdfs')
      golden_file = File.join(pdf_fixtures_path, "#{template_name}.txt")
      golden_text = File.open(golden_file, 'rb').read.strip

      pdf = GrantContract.new(
        template_name,
        'SubmissionName',
        'ArtistName',
        'RequestedFundingDollars',
        Time.parse('2017-01-07 20:17:40')
      )

      pdf_text = PDF::Inspector::Text.analyze(pdf.render).strings.join("\n").strip

      expect(golden_text).to eq(pdf_text)
    end
  end

  described_class.template_names.each do |template_name|
    include_examples 'generates expected grant document', template_name
  end
end
