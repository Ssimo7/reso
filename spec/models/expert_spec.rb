# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expert, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :antenne
      is_expected.to have_many(:assistances_experts).dependent(:destroy)
      is_expected.to have_many :assistances
      is_expected.to have_and_belong_to_many :users
      is_expected.to have_and_belong_to_many :communes
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:antenne)
        is_expected.to validate_presence_of(:email)
      end
    end

    describe 'email format' do
      it do
        is_expected.to allow_value('test@beta.gouv.fr').for(:email)
        is_expected.to allow_value('0_@1-.2').for(:email)
        is_expected.not_to allow_value('test').for(:email)
        is_expected.not_to allow_value('te@st').for(:email)
      end
    end
  end

  describe 'associations dependencies' do
    let(:expert) { create :expert }
    let(:assistance) { create :assistance }
    let(:ae) { create :assistance_expert, expert: expert, assistance: assistance }

    before do
      create :match, assistance_expert: ae
    end

    context 'when removing an assistance' do
      it {
        expect{ expert.assistances = [] }.not_to raise_error
        expect(expert.assistances).to eq []
      }
    end
  end

  describe 'scopes' do
    describe 'of_naf_code' do
      subject { Expert.of_naf_code naf_code }

      let(:commerce_naf_code) { '6202A' }
      let(:artisanry_naf_code) { '1011Z' }

      let(:commerce_institution) { create :institution, qualified_for_artisanry: false, qualified_for_commerce: true }
      let(:artisanry_institution) { create :institution, qualified_for_artisanry: true, qualified_for_commerce: false }

      let(:artisanry_expert) do
        create(:expert,
          antenne: create(:antenne, institution: artisanry_institution))
      end
      let(:commerce_expert) do
        create(:expert,
          antenne: create(:antenne, institution: commerce_institution))
      end

      context 'naf code is for artisanry' do
        let(:naf_code) { artisanry_naf_code }

        it 'returns the expert for artisanry' do
          is_expected.to match_array [artisanry_expert]
        end
      end

      context 'naf code is for commerce' do
        let(:naf_code) { commerce_naf_code }

        it 'returns the expert for commerce' do
          is_expected.to match_array [commerce_expert]
        end
      end
    end

    describe 'commune zone scopes' do
      let(:expert_with_custom_communes) { create :expert, antenne: antenne, communes: [commune1] }
      let(:expert_without_custom_communes) { create :expert, antenne: antenne }
      let(:commune1) { create :commune }
      let(:commune2) { create :commune }
      let!(:antenne) { create :antenne, communes: [commune1, commune2] }

      describe 'with_custom_communes' do
        subject { Expert.with_custom_communes }

        it { is_expected.to match_array [expert_with_custom_communes] }
      end

      describe 'without_custom_communes' do
        subject { Expert.without_custom_communes }

        it { is_expected.to match_array [expert_without_custom_communes] }
      end
    end
  end

  describe 'to_s' do
    let(:expert) { build :expert, full_name: 'Ivan Collombet' }

    it { expect(expert.to_s).to eq 'Ivan Collombet' }
  end

  describe 'generate_access_token' do
    let(:expert) { create :expert }

    context 'it is a new expert' do
      context 'there is no expert with this access_token' do
        before { allow(SecureRandom).to receive(:hex).once.and_return('access_token') }

        it { expect(expert.access_token).to eq 'access_token' }
      end

      context 'there is already a expert with this access_token' do
        let!(:expert_with_same_access_token) { create :expert }

        before do
          expert_with_same_access_token.update access_token: 'access_token'
          allow(SecureRandom).to receive(:hex).at_least(:once).and_return('access_token', 'other_access_token')
        end

        it { expect(expert.access_token).to eq 'other_access_token' }
      end
    end

    context 'expert is already created' do
      before do
        allow(SecureRandom).to receive(:hex).once.and_return('access_token')
        expert.save
      end

      it { expect(expert.access_token).to eq 'access_token' }
    end
  end
end
