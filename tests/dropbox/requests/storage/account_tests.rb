Shindo.tests('Fog::Storage[:dropbox] | account requests', ['dropbox', 'account']) do

  @account_info_format = {
     "referral_link"  => String,
     "display_name"   => String,
     "uid"            => Integer,
     "country"        => String,
     "quota_info"     => {
       "shared"       => Integer,
       "quota"        => Integer,
       "normal"       => Integer
     },
     "email"          => String
  }

  tests('success') do

    tests('#get_account_info()').formats(@account_info_format) do
      Fog::Storage[:dropbox].get_account_info().body
    end
  end

end