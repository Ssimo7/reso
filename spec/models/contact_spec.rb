# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'associations' do
    it do
      is_expected.to belong_to :company
      is_expected.to have_many(:diagnoses).dependent(:restrict_with_error)
    end
  end

  describe 'validations' do
    describe 'presence' do
      it do
        is_expected.to validate_presence_of(:full_name)
        is_expected.to validate_presence_of(:role)
        is_expected.to validate_presence_of(:company)
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

    describe 'email or phone_number' do
      context 'without any contact type' do
        it do
          contact = build :contact
          expect(contact).not_to be_valid
        end
      end

      context 'with email' do
        it do
          contact = build :contact, :with_email
          expect(contact).to be_valid
        end
      end

      context 'with phone number' do
        it do
          contact = build :contact, :with_phone_number
          expect(contact).to be_valid
        end
      end
    end
  end

  describe 'can_be_viewed_by?' do
    subject { contact.can_be_viewed_by?(user) }

    let(:user) { create :user }
    let(:contact) { create :contact, :with_email }

    before do
      create :diagnosis, advisor: advisor
      create :diagnosis, advisor: advisor, visitee: contact
    end

    context 'diagnosis advisor is the user' do
      let(:advisor) { user }

      it { is_expected.to eq true }
    end

    context 'diagnosis advisor is not the user' do
      let(:advisor) { create :user }

      it { is_expected.to eq false }
    end
  end

  describe 'to_s' do
    let(:contact) { build :contact, full_name: 'Ivan Collombet' }

    it { expect(contact.to_s).to eq 'Ivan Collombet' }
  end
end
