class ProductsController < ApplicationController

  helper_method :resource, :collection, :current_category, :filter
  
  def index
    render_responce
  end

  def show
    @related_products = resource.related_products
    @current_category = resource.same_taxon_products
  end
  
  def taxonomy
    taxon_ids = Taxon.where(taxonomy_id: selected_taxonomy.id).map(&:id)
    @products = collection.includes(:taxons).where(shop_taxons: { id: taxon_ids })
    seo_data(selected_taxonomy)
    render_responce
  end
  
  def taxon
    taxons = selected_taxon.self_and_descendants
    @products = collection.includes(:taxons).where(:shop_taxons => {:id => taxons})
    seo_data(selected_taxon)
    render_responce
  end

private

  # рендеринг результата
  def render_responce
    respond_to do |format|
      format.html { render :index }
      format.json do
        txt = Russian.p(collection.count, 'товар', 'товара', 'товаров')
        render json: { text: "Найдено #{collection.count} #{txt}" }
      end
    end
  end

  def resource
    @product ||= Product.friendly.find(params[:id])
  end

  # инстанс для поддержки гибкой фильтрации
  def filter
    @q = Product.search(params[:q])
  end

  # коллеция товаров
  # унаследована от инстанса фильтрации
  # чтобы учитывать гибкие параметры фильтрации на различных страницах
  def collection
    params[:brand_ids] ||= Brand.pluck(:id)
    @products ||= filter.result(distinct: true)
                        .where(brand_id: params[:brand_ids])
                        .page(params[:page]).per(20)
  end

  def selected_taxon
    @selected_taxon ||= @taxon || Taxon.where(id: params[:id]).first
    @selected_taxon
  end

  def selected_taxonomy
    @selected_taxonomy ||= @taxonomy || Taxonomy.where(slug: params[:id]).first
  end

  def current_category
    @current_category ||= selected_taxon.try(:title) || selected_taxonomy.try(:title) || 'Товары'
  end

end