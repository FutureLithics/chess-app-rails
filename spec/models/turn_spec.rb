# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Turn, type: :model do
  it 'belongs to a game' do
    association = described_class.reflect_on_association(:game)

    expect(association.macro).to eq(:belongs_to)
  end
end
