class ProductImage < ActiveRecord::Base
  belongs_to :product
  
  has_attached_file :image, styles: {catalog: {geometry: "200x200#"},
                                     product: {geometry: "300x300#"},
                                     ico: {geometry: "70x70#"}
                                     }
                            
end