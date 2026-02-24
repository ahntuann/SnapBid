class HelpController < ApplicationController
  def index
    # Dummy data cho FAQs trang chủ Help
    @popular_faqs = [
      { id: 1, question: "Làm thế nào để đặt giá thầu (bid)?", answer: "Bạn cần đăng nhập, nạp đủ số dư khả dụng và nhấn nút Đặt giá tại trang chi tiết sản phẩm." },
      { id: 2, question: "Chi phí vận chuyển được tính như thế nào?", answer: "Phí vận chuyển phụ thuộc vào khoảng cách và kích thước kiện hàng. Phí này sẽ được hiển thị khi bạn tiến hành thanh toán." },
      { id: 3, question: "Tôi có thể huỷ đơn hàng sau khi trúng đấu giá không?", answer: "Không. Theo quy định, nếu bạn trúng đấu giá bạn bắt buộc phải thanh toán. Từ chối thanh toán sẽ dẫn tới khoá tài khoản." },
      { id: 4, question: "Làm sao để đăng bán một sản phẩm?", answer: "Truy cập mục 'Bán hàng', điền đầy đủ hình ảnh, mô tả, mức giá khởi điểm và thời gian kết thúc mong muốn." }
    ]
  end

  def selling
    # Trang hướng dẫn dành cho người bán
  end
end
