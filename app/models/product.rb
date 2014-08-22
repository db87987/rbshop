class Product < ActiveRecord::Base
  belongs_to :brand
  has_many :product_images
  has_many :product_taxons
  has_many :taxons, through: :product_taxons
  has_and_belongs_to_many :procedures
  has_and_belongs_to_many :cases
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
  
  extend FriendlyId
  friendly_id :short_description, use: :slugged
  
  def current_price
    if new_price
      new_price
    else
      price
    end
  end
end
