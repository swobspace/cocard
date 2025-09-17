# frozen_string_literal: true

require 'rails_helper'
module CardTerminals
  RSpec.describe RMI::OrgaV1::Info do
    let(:properties) {{
      "rmi_smcb_pinEnabled" => true, 
      "rmi_pairingEHealthTerminal_enabled" => true
    }}

    subject { CardTerminals::RMI::OrgaV1::Info.new(properties) }

    it { expect(subject.remote_pin_enabled).to eq(true) }
    it { expect(subject.remote_pairing_enabled).to eq(true) }
  end
end
