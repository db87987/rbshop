# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.auto_highlight = true
  navigation.active_leaf_class = 'active-leaf'

  navigation.items do |primary|
    primary.dom_class = 'main-menu__root js-main-menu'
    Taxonomy.all.each do |taxonomy|
      item_class = 'main-menu__item'
      item_class += ' m-arrow' if taxonomy.taxons.any?

      primary.item "taxonomy-#{taxonomy.id}", taxonomy.title, poly_taxonomy_path(taxonomy), class: item_class do |taxons|

        taxons.dom_class = 'main-menu__2level js-main-menu-2level'

        if taxonomy.taxons.by_age.roots.any?
          taxons.item 'by_age', 'По возрасту', '#', class: 'main-menu__item-title' do |age_taxon|
            taxonomy.taxons.by_age.roots.each do |taxon|
              age_taxon.item "taxon-#{taxon.id}", taxon.title, poly_taxon_path(taxon), class: 'main-menu__item'
            end
          end
        end

        if taxonomy.taxons.by_care_type.roots.any?
          taxons.item 'by_care_type', 'По типу ухода', '#', class: 'main-menu__item-title' do |care_taxon|
            taxonomy.taxons.by_care_type.roots.each do |taxon|
              care_taxon.item "taxon-#{taxon.id}", taxon.title, poly_taxon_path(taxon), class: 'main-menu__item'
            end
          end
        end

        if taxonomy.taxons.by_product_type.roots.any?
          taxons.item 'by_product_type', 'По типу средства', '#', class: 'main-menu__item-title' do |product_taxon|
            taxonomy.taxons.by_product_type.roots.each do |taxon|
              product_taxon.item "taxon-#{taxon.id}", taxon.title, poly_taxon_path(taxon), class: 'main-menu__item'
              #
              # пока что не показываем второй уровень вложенности таксонов
              # product_taxon.item "taxon-#{taxon.id}", taxon.title, poly_taxon_path(taxon) do |subtaxons|
              #   subtaxons.dom_class = '_left-menu-second-level js-left-menu-node'
              #   taxon.children.each do |subtaxon|
              #     subtaxons.item "taxon-#{subtaxon.id}", subtaxon.title, poly_taxon_path(taxon), class: 'empty'
              #   end
              # end
            end
          end
        end


      end
    end

    primary.item "promos", 'Акции', promos_path, class: 'main-menu__item'
    primary.item "cases", 'Случаи применения', cases_path, class: 'main-menu__item', highlights_on: %r{cases}
  end
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items.
  # Defaults to 'selected' navigation.selected_class = 'your_selected_class'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  # navigation.active_leaf_class = 'your_active_leaf_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that
  # will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name, item| "<span>#{name}</span>"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false
  
  # If this option is set to true, all item names will be considered as safe (passed through html_safe). Defaults to false.
  # navigation.consider_item_names_as_safe = false

  # Define the primary navigation
  # navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>if: -> { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>unless: -> { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #
    # primary.item :key_1, 'name', url, options

    # Add an item which has a sub navigation (same params, but with block)
    # primary.item :key_2, 'name', url, options do |sub_nav|
      # Add an item to the sub navigation (same params again)
      # sub_nav.item :key_2_1, 'name', url, options
    # end

    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    # primary.item :key_3, 'Admin', url, class: 'special', if: -> { current_user.admin? }
    # primary.item :key_4, 'Account', url, unless: -> { logged_in? }

    # you can also specify html attributes to attach to this particular level
    # works for all levels of the menu
    # primary.dom_attributes = {id: 'menu-id', class: 'menu-class'}

    # You can turn off auto highlighting for a specific level
    # primary.auto_highlight = false
  # end
end
