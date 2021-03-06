module InstitutionsHelper
  def all_institutions_images
    (Institution.where(show_icon: true).pluck(:name) + Antenne.where(show_icon: true).pluck(:name))
      .map(&:parameterize).sort.uniq # Sort in Rails instead of SQL because it’s easier for case- and diacritics- insensitive sorting.
      .map(&method(:institution_image))
      .join.html_safe
  end

  def institution_image(name, extra_params = {})
    slug = name.parameterize
    possible_paths = "institutions/#{slug}.png", "institutions/#{slug}.svg", "institutions/#{slug}.jpg"
    path = possible_paths.find{ |path| resolve_asset_path(path, true) }
    params = { alt: name, title: name, class: 'institution_logo' }
    params.merge! extra_params
    image_tag(path, params) if path
  end
end
