require 'spec_helper'

describe Spree::Gateway::Esewa do
  let(:gateway) { described_class.create!(name: 'Esewa') }

  context '.provider_class' do
    it 'is a Esewa gateway' do
      expect(gateway.provider_class).to eq ::Spree::Gateway::Esewa
    end
  end
end
