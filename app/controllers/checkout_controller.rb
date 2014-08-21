class CheckoutController < ApplicationController
  
  def cart
    @cart = current_cart
  end
  
  def checkout
    if current_cart.line_items.empty?
      redirect_to root_path, notice: 'Извините, ваша корзина пуста'
    else
      @order = Order.new
    end
  end
  
  def order
    @order = Order.create(params[:order])
    @order.add_line_items_from_cart(current_cart)
    
    if @order.save
      # отправляем мейлы
      Cart.destroy(session[:cart_id])
      session[:cart_id] = nil
      redirect_to root_path, notice: 'Заказ успешно создан, наши менеджеры свяжуться с вами'
    else
      redirect_to root_path, notice: 'Извините, что-то пошло не так'
    end
  end
end