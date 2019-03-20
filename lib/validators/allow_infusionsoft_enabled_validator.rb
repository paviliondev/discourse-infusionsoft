class AllowInfusionsoftEnabledValidator
  def initialize(opts = {})
    @opts = opts
  end

  def valid_value?(val)
    return true if val == "f"
    SiteSetting.infusionsoft_access_token.present?
  end

  def error_message
    I18n.t("site_settings.errors.infusionsoft_access_token_required");
  end
end
