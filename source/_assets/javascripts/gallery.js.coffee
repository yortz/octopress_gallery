class @Gallery
  constructor: (selector) ->
    @domain    = "http://domain.com"
    @$selector = jQuery(selector)
    @url       = "#{@domain}/galleries.json"
    @$attr     = 'data-gallery'
    @retrieve(@$selector)

  retrieve: (selector) =>
    @fetch selector.attr(@$attr) if selector.length != 0

  fetch: (name) =>
    jQuery.getJSON @url, (galleries) =>
      gallery = _.find(galleries, (g) => g.gallery.name == name)
      @get_assets_for(gallery)

  get_assets_for: (gallery) =>
      times   = gallery.gallery.thumbs.length - 1
      assets  = [0..times]
      images  = []
      for asset in assets
        images.push @template_for(gallery, asset)
      @$selector.html(images.join(''))

  template_for: (gallery, asset) =>
    thumb  = gallery.gallery.thumbs[asset]
    medium = gallery.gallery.medium[asset]
    rel    = gallery.gallery.name
    title  = medium.replace(/((\w*\/){4}|(-\S*))/g, "")
    li = "<a class=\"fancy\" href=\"#{@domain}/#{medium}\" rel=\"#{rel}\" title=\"#{title}\"> <img src =\"#{@domain}/#{thumb}\" class=\"noresize\" /></a>"

