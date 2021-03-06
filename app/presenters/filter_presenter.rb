class FilterPresenter

  def initialize(template)
    @template = template
  end

  # список чекбоксов поискового фильтра по таксону
  # принимает
  #   - имя enum из модели Taxon
  #   - f объект формы под чекбоксы
  #   - html параметры
  def taxons_list(type, f, *args)
    taxons = allowed_taxons(type)

    if taxons.present?
      h.content_tag :ul, *args do
        taxons.map do |taxon|
          h.content_tag :li do
            f.label "taxons_id_in_#{taxon.id}" do
              f.check_box( :taxons_id_in, { multiple: true }, taxon.id, nil) +
              h.content_tag(:span, taxon.title)
            end
          end
        end.flatten.compact.join.html_safe
      end
    else
      nil
    end
  end

  # блок фильтрации по бренду
  # принимает
  #   - html параметры для блока с чекбоксами
  def by_brands(f, *args)
    h.content_tag(:h5, 'По бренду') +
    h.content_tag(:ul, *args )do
      Brand.all.each_with_index.map do |brand, i|
        h.content_tag :li do
          f.label "brand_id_in_#{brand.id}" do
            html = [f.check_box( :brand_id_in, { multiple: true }, brand.id, nil)]
            html << h.content_tag(:span, brand.title)
            # встраиваем подсказки.
            # подсказки привязываются к айдишнику бренда,
            # как бы тупо это не выглядело
            html << hint("brand_#{i+1}")
            html.join.html_safe
          end
        end
      end.flatten.compact.join.html_safe
    end
  end


  # заголовок поискового фильтра по таксону
  # принимает
  #   - имя enum из модели Taxon
  #   - html параметры
  def taxons_title(type, *args)
    if allowed_taxons(type).present?
      h.content_tag(:h5, *args) do
        h.content_tag(:span, h.t(type, scope: 'activerecord.attributes.taxon.taxon_types')) +
        hint(type, :help)
      end
    end
  end

  # заголовок ценового фильтра
  # принимает ничего
  def price_title(*args)
    h.content_tag(:h5, 'по цене', *args)
  end


  # область с фильтром по цене
  # принимает
  #   - f объект формы под чекбоксы
  #   - html параметры
  def price_list(f, *args)
    html = []

    html << h.content_tag(:div, nil, class: 'js-price-slider-handler')

    html << h.content_tag(:li) do
          h.content_tag(:span, 'от') +
          f.text_field(:new_price_or_price_gteq,
                       class: 'js-price-slider-input-min',
                       'data-default' => products_min_price
          )
    end

    html << h.content_tag(:li) do
          h.content_tag(:span, 'до') +
          f.text_field( :new_price_or_price_lteq,
                        class: 'js-price-slider-input-max',
                        'data-default' => products_max_price
          )
    end

    h.content_tag :ul, *args do
      html.flatten.compact.join.html_safe
    end
  end

private

  # делаем выборку по разрешенным к показу таксонам
  # если есть выбранный таксон, то разрешаем брать все кроме него
  # если нет таксона, но есть выбранная таксономия,то отдаем только ее таксоны
  # если нет ничего такого, то отдаем все возможные таксоны
  def allowed_taxons(type)
    if h.selected_taxon
      h.selected_taxonomy.taxons.send(type) unless type.to_s == h.selected_taxon.taxon_type.to_s
    elsif h.selected_taxonomy
      h.selected_taxonomy.taxons.send(type)
    else
      Taxon.send(type)
    end
  end

  def h
    @template
  end

  # максимальная цена поиска для слайдера цены
  def products_max_price
    Product.maximum(:price)
  end

  # минимальная цена поиска для слайдера цены
  def products_min_price
    Product.minimum(:price)
  end

  # коллекция подсказок, которые применяются в фильтре
  def hints
    @hints ||= Hint.all
  end

  def hint(name, type=:info)
    hint = hints.where(name: name.to_s).first
    css_class = "m-#{type.to_s}"
    title = hint.try(:text)
    if hint && title
      h.content_tag(:i, nil, class: "hint js-hint #{css_class}", title: title)
    else
      nil
    end
  end

end