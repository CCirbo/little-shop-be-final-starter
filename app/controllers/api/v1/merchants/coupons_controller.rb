class Api::V1::Merchants::CouponsController < ApplicationController
    def index
      coupons = Coupon.where(merchant_id: params[:merchant_id])
      # require 'pry'; binding.pry
      render json: CouponSerializer.new(coupons)
    end
  
    def show
    
      coupon = Coupon.find(params[:coupon_id])
      render json: CouponSerializer.new(coupon), status: :ok
    end
  
    def create
      merchant = Merchant.find(params[:merchant_id])
      coupon = merchant.coupons.new(coupon_params)
      coupon.merchant_id = params[:merchant_id]
      # require 'pry'; binding.pry
      coupon.validate_coupon  
   
      if coupon.save
        render json: CouponSerializer.new(coupon), status: :created
      else
        render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def update
      coupon = Coupon.find(params[:coupon_id])
  
      if coupon.update(coupon_params)
        render json: coupon, status: :ok
      else
        render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
   def change_status 
    coupon = Coupon.find(params[:coupon_id])
    status = request.fullpath.split("/")[-1]
    coupon.activate_or_deactivate(status)
    render json: CouponSerializer.new(coupon), status: :ok
   end


  
    private
  
    def coupon_params
      params.permit(:name, :code, :dollar_off, :percent_off, :active)
    end
  end