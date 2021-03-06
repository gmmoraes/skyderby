class Skyderby.views.TournamentFormView extends Backbone.View

  finish_line: ''
  exit_point: {}

  events:
    'input [name="tournament[finish_start_lat]"]' : 'on_change_finish_line_start_lat'
    'input [name="tournament[finish_start_lon]"]' : 'on_change_finish_line_start_lon'
    'input [name="tournament[finish_end_lat]"]'   : 'on_change_finish_line_end_lat'
    'input [name="tournament[finish_end_lon]"]'   : 'on_change_finish_line_end_lon'
    'input [name="tournament[exit_lat]"]'         : 'on_change_exit_lat'
    'input [name="tournament[exit_lon]"]'         : 'on_change_exit_lon'

  initialize: ->
    @read_current_form_values()

    @listenToOnce(Skyderby, 'maps_api:ready', @on_maps_api_ready)
    Skyderby.helpers.init_maps_api()

  on_maps_api_ready: ->
    @maps_ready = true

    options =
      zoom: 2,
      center: new google.maps.LatLng(20, 20),
      mapTypeId: google.maps.MapTypeId.SATELLITE

    @map = new google.maps.Map(@$('#tournament-form-map')[0], options)
    @render_map()
    
  render_finish_line: ->
    @finish_line.setMap(null) if @finish_line
    return unless @finish_start_lat &&
                  @finish_start_lon &&
                  @finish_end_lat &&
                  @finish_end_lon

    @finish_line = new google.maps.Polyline(
      path: [
        { lat: @finish_start_lat, lng: @finish_start_lon },
        { lat: @finish_end_lat, lng: @finish_end_lon }
      ],
      geodesic: true,
      strokeColor: '#E84855',
      strokeOpacity: 1.0,
      strokeWeight: 2)

    @finish_line.setMap(@map)

  render_center_line: ->
    @center_line.setMap(null) if @center_line
    return unless @finish_start_lat &&
                  @finish_start_lon &&
                  @finish_end_lat &&
                  @finish_end_lon &&
                  @exit_lat &&
                  @exit_lon

    center_lat = @finish_start_lat + (@finish_end_lat - @finish_start_lat) / 2
    center_lon = @finish_start_lon + (@finish_end_lon - @finish_start_lon) / 2

    center_line_path = [
      {lat: center_lat, lng: center_lon},
      {lat: @exit_lat, lng: @exit_lon}
    ]

    @center_line = new google.maps.Polyline(
      path: center_line_path,
      geodesic: true,
      strokeColor: '#E84855',
      strokeOpacity: 1.0,
      strokeWeight: 2
    )

    @center_line.setMap(@map)

  fit_bounds: ->
    bounds = new google.maps.LatLngBounds()

    if @finish_start_lat && @finish_start_lon
      bounds.extend(new google.maps.LatLng(
        @finish_start_lat,
        @finish_start_lon
      ))

    if @finish_end_lat && @finish_end_lon
      bounds.extend(new google.maps.LatLng(
        @finish_end_lat,
        @finish_end_lon
      ))

    if @exit_lat && @exit_lon
      bounds.extend(new google.maps.LatLng(
        @exit_lat,
        @exit_lon
      ))

    @map.fitBounds(bounds)
    @map.setCenter(bounds.getCenter())

  render_map: ->
    return unless @maps_ready

    @render_finish_line()
    @render_center_line()
    @fit_bounds()

  on_change_finish_line_start_lat: (event) ->
    @finish_start_lat = Number($(event.currentTarget).val())
    @render_map()

  on_change_finish_line_start_lon: (event) ->
    @finish_start_lon = Number($(event.currentTarget).val())
    @render_map()

  on_change_finish_line_end_lat: (event) ->
    @finish_end_lat = Number($(event.currentTarget).val())
    @render_map()

  on_change_finish_line_end_lon: (event) ->
    @finish_end_lon = Number($(event.currentTarget).val())
    @render_map()

  on_change_exit_lat: (event) ->
    @exit_lat = Number($(event.currentTarget).val())
    @render_map()

  on_change_exit_lon: (event) ->
    @exit_lon = Number($(event.currentTarget).val())
    @render_map()
  
  read_current_form_values: ->
    @finish_start_lat = Number(@$('[name="tournament[finish_start_lat]"]').val())
    @finish_start_lon = Number(@$('[name="tournament[finish_start_lon]"]').val())
    @finish_end_lat = Number(@$('[name="tournament[finish_end_lat]"]').val())
    @finish_end_lon = Number(@$('[name="tournament[finish_end_lon]"]').val())

    @exit_lat = Number(@$('[name="tournament[exit_lat]"]').val())
    @exit_lon = Number(@$('[name="tournament[exit_lon]"]').val())
