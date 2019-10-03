module Jobs
  class RefreshInfusionsoftAccessToken < ::Jobs::Base
    def execute(args)
      Infusionsoft::Authorization.refresh_access_token
    end
  end
end
