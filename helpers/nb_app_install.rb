class NBAppInstall
  include AppConfiguration

  def initialize(slug:)
    @slug = slug
  end

  attr_reader :slug

  def url
    "https://#{slug}.nationbuilder.com" \
      "/oauth/authorize?response_type=code" \
      "&client_id=#{app_client_id}" \
      "&redirect_uri=#{app_base_url}/oauth/callback?slug=#{slug}"
  end
end
