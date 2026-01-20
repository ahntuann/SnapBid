module VietqrHelper
  require "cgi"

  def vietqr_image_url(amount: nil, add_info: nil)
    bank   = ENV.fetch("VIETQR_BANK")
    acc    = ENV.fetch("VIETQR_ACCOUNT")
    name   = ENV.fetch("VIETQR_NAME")

    params = []
    params << "accountName=#{CGI.escape(name)}"
    params << "addInfo=#{CGI.escape(add_info)}" if add_info.present?
    params << "amount=#{amount}" if amount.present?

    "https://img.vietqr.io/image/#{bank}-#{acc}-compact2.png?#{params.join('&')}"
  end
end
