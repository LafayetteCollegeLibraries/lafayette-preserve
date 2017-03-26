require 'spec_helper'

describe GenericWork do

  it 'has a title' do
    subject.title = ['foo']
    expect(subject.title).to eq ['foo']
  end

  context 'when there are related files' do
    subject { FactoryGirl.create(:work_with_representative_file) }

    it 'exposes an absolute URI to the JPEG2000 derivative' do
      expect(subject.jp2_path).to match /#{Regexp.escape('http://localhost/downloads/')}.+?#{Regexp.escape('?file=jp2')}/
    end
    
  end

  context 'with attached files' do
    subject { FactoryGirl.create(:work_with_files) }

    it 'exposes IIIF endpoints' do
      subject { build(:work, date_uploaded: Date.today) }

      expect(subject.iiif_images.size).to eq(2)
      expect(subject.iiif_images.first).to include("http://localhost.localdomain/loris/")
      expect(subject.iiif_images.last).to include("http://localhost.localdomain/loris/")
    end
  end

  context 'with a thumbnail' do
    subject { FactoryGirl.create(:work_with_files) }

    before do
      subject.thumbnail = subject.ordered_members.to_a.last
    end

    it "can have the thumbnail set to the work" do
      expect(subject.thumbnail_path).to match /#{Regexp.escape('http://localhost/downloads/')}.+?#{Regexp.escape('?file=thumbnail')}/
    end
    
    it 'exposes an absolute URI to the preservation master' do
      expect(subject.download_path).to match /#{Regexp.escape('http://localhost/downloads/')}\w+$/
    end
  end
end
