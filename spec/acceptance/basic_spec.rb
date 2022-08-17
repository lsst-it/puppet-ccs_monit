# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ccs_monit class' do
  include_examples 'the example', 'basic.pp'
end
