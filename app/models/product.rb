# == Schema Information
#
# Table name: products
#
#  id                   :integer          not null, primary key
#  title                :string(255)
#  packing              :string(255)
#  text                 :text
#  ingredients          :text
#  brand_id             :integer
#  visible_professional :boolean          default(FALSE)
#  visible_dealer1      :boolean          default(FALSE)
#  visible_dealer2      :boolean          default(FALSE)
#  visible_dealer3      :boolean          default(FALSE)
#  price_professional   :decimal(8, 2)
#  price_dealer1        :decimal(8, 2)
#  price_dealer2        :decimal(8, 2)
#  price_dealer3        :decimal(8, 2)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  short_description    :text
#  product_category_id  :integer
#  latest               :boolean
#  slug                 :string(255)
#  seo_title            :string(255)
#  seo_description      :text
#  seo_text             :text
#  taxon_id             :integer
#  position             :integer          default(0)
#  sku                  :string(255)
#  price                :integer          default(0)
#  new_price            :integer
#  applying             :string(255)
#  in_stock             :boolean          default(TRUE)
#  bought               :integer          default(0)
#  product_type         :integer          default(0)
#  promo_id             :integer
#  promo_products_price :integer
#  show_in_slider       :boolean          default(FALSE)
#

class Product < ActiveRecord::Base
  belongs_to :brand
  has_many :product_images
  has_many :product_taxons
  has_many :taxons, through: :product_taxons
  # has_and_belongs_to_many :procedures
  has_and_belongs_to_many :cases, join_table: "shop_cases_products"
  has_and_belongs_to_many :related_products,
                          class_name: 'Product',
                          join_table: "related_products",
                          foreign_key: "product_id",
                          association_foreign_key: "related_product_id"
  has_and_belongs_to_many :same_taxon_products,
                          class_name: 'Product',
                          join_table: "same_taxon_products",
                          foreign_key: "product_id",
                          association_foreign_key: "same_product_id"                          
  belongs_to :promo, class_name: "Product"
  has_many :products, class_name: "Product",
                      foreign_key: "promo_id"
  has_one :slide  
  after_save :count_separate_product_price, :if => lambda {|product| product.product_type == 'promo' }
  
  scope :in_stock, -> { where(in_stock: true) }
  scope :important, -> { where('latest = TRUE OR product_type = 1') }
  scope :ordered, -> (field) {order(field)}
  
  enum product_type: [ :regular, :promo ]

  accepts_nested_attributes_for :product_images, allow_destroy: true
  accepts_nested_attributes_for :slide, allow_destroy: true

  after_update :reprocess_images


  # строим особый SQL
  # чтобы запросить только те товары
  # которые имеют переданные таксоны
  # не через ИЛИ,а через И
  # на входе массив taxon_id
  def self.filtered_by_taxons(taxons)
    joins = []
    taxons.each_with_index.map do |taxon_id, i|
      joins << "INNER JOIN shop_product_taxons up#{i} ON products.id = up#{i}.product_id"
      joins << "INNER JOIN shop_taxons p#{i} ON p#{i}.id = up#{i}.taxon_id"
    end.flatten!

    wheres = []
    taxons.each_with_index.map do |taxon_id, i|
      wheres << "p#{i}.id=#{taxon_id}"
      wheres << "AND" unless i == taxons.count-1
    end
    joins(joins.join(' ')).where(wheres.join(' '))
  end



  def reprocess_images
    self.product_images.each do |image|
      image.save
    end

    if self.promo?
      self.slide.image.save
    end
  end
  
  extend FriendlyId
  friendly_id :short_description, use: :slugged
  
  def count_separate_product_price
    price = self.products.map {|p| p.price.to_i}.sum
    self.update_columns(promo_products_price: price)
  end
  
  def current_price
    unless new_price.nil? || new_price.zero?
      new_price
    else
      price
    end
  end
  
  def old_price
    if price && price != 0
      price
    else
      nil
    end
  end
  
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

  def discount?
    if new_price
      true 
    else
      false
    end
  end
  
  def buy(quantity)
    self.bought += quantity
    self.save!
  end
end
