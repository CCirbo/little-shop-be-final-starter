class CouponSerializer
    include JSONAPI::Serializer
    attributes :id, :name, :code, :dollar_off, :percent_off, :active, :times_used, :merchant_id
  end