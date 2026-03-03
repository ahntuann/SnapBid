module HomeHelper
  # Returns [icon_class, css_color_class] for a category based on its name
  CATEGORY_ICON_MAP = {
    /áo/i            => ["bi-person-standing-dress", "sb-cat-icon--ao"],
    /quần/i          => ["bi-rulers",                "sb-cat-icon--quan"],
    /gi[aà]y/i       => ["bi-boot-fill",             "sb-cat-icon--giay"],
    /d[eé]p/i        => ["bi-layout-text-window",    "sb-cat-icon--dep"],
    /túi|handbag/i   => ["bi-handbag-fill",          "sb-cat-icon--tui"],
    /váy/i           => ["bi-person-dress",          "sb-cat-icon--ao"],
    /ví|wallet/i     => ["bi-wallet2",               "sb-cat-icon--ph"],
    /phụ\s*kiện|accessories/i => ["bi-gem",          "sb-cat-icon--ph"],
    /adidas/i        => ["bi-lightning-fill",         "sb-cat-icon--brand"],
    /nike/i          => ["bi-check-circle-fill",      "sb-cat-icon--brand"],
    /gucci/i         => ["bi-award-fill",             "sb-cat-icon--brand"],
    /dior/i          => ["bi-stars",                 "sb-cat-icon--brand"],
    /chanel/i        => ["bi-flower1",               "sb-cat-icon--brand"],
  }.freeze

  def category_icon(category_name)
    CATEGORY_ICON_MAP.each do |pattern, (icon, color)|
      return [icon, color] if category_name.to_s.match?(pattern)
    end
    ["bi-tag-fill", "sb-cat-icon--other"]
  end
end
