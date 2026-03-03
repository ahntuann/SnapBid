module VietqrHelper
  require "cgi"

  # Tạo QR code thanh toán qua SePay (https://qr.sepay.vn)
  def sepay_qr_image_url(amount: nil, des: nil)
    bank = ENV.fetch("VIETQR_BANK")
    acc  = ENV.fetch("VIETQR_ACCOUNT")

    params = {
      acc:      acc,
      bank:     bank,
      template: "compact2"
    }
    params[:amount] = amount.to_i if amount.present?
    params[:des]    = des         if des.present?

    query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
    "https://qr.sepay.vn/img?#{query}"
  end

  # Giữ lại alias cũ phòng nơi nào đó còn dùng
  def vietqr_image_url(amount: nil, add_info: nil)
    sepay_qr_image_url(amount: amount, des: add_info)
  end
end
