test_name 'Params' do
  step 'PE-20886 - - Test directory parameter' do
    hosts.each do |host|
      result = on(host, puppet("enterprise support --dir /tmp", 'ENV' => {'BEAKER_TESTING' => '1'}))
      directory = result.stdout.match(/^Support data is located at (.*)\/puppet_enterprise_support/).captures.first
      assert_match(/\/tmp/, directory, "Path should begin with /tmp as specified by --dir /tmp")
    end
  end

  step 'PE-19805 -- Test ticket parameter' do
    hosts.each do |host|
      result = on(host, puppet("enterprise support --ticket 12345", 'ENV' => {'BEAKER_TESTING' => '1'}))
      ticket = result.stdout.match(/^Support data is located at \/var\/tmp\/puppet_enterprise_support_(.*)_/).captures.first
      assert_match(/12345/, ticket, "Path should include 12345 as specified by --ticket 12345")
    end
  end
end