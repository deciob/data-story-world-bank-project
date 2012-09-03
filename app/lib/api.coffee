iso_country_codes = ["AF","AX","AL","DZ","AS","AD","AO","AI","AQ","AG","AR","AM","AW","AU","AT","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT","BO","BA","BW","BV","BR","IO","BN","BG","BF","BI","KH","CM","CA","CV","KY","CF","TD","CL","CN","CX","CC","CO","KM","CG","CD","CK","CR","CI","HR","CU","CY","CZ","DK","DJ","DM","DO","EC","EG","SV","GQ","ER","EE","ET","FK","FO","FJ","FI","FR","GF","PF","TF","GA","GM","GE","DE","GH","GI","GR","GL","GD","GP","GU","GT","GG","GN","GW","GY","HT","HM","VA","HN","HK","HU","IS","IN","ID","IR","IQ","IE","IM","IL","IT","JM","JP","JE","JO","KZ","KE","KI","KP","KR","KW","KG","LA","LV","LB","LS","LR","LY","LI","LT","LU","MO","MK","MG","MW","MY","MV","ML","MT","MH","MQ","MR","MU","YT","MX","FM","MD","MC","MN","ME","MS","MA","MZ","MM","NA","NR","NP","NL","AN","NC","NZ","NI","NE","NG","NU","NF","MP","NO","OM","PK","PW","PS","PA","PG","PY","PE","PH","PN","PL","PT","PR","QA","RE","RO","RU","RW","SH","KN","LC","PM","VC","WS","SM","ST","SA","SN","RS","SC","SL","SG","SK","SI","SB","SO","ZA","GS","ES","LK","SD","SR","SJ","SZ","SE","CH","SY","TW","TJ","TZ","TH","TL","TG","TK","TO","TT","TN","TR","TM","TC","TV","UG","UA","AE","GB","US","UM","UY","UZ","VU","VE","VN","VG","VI","WF","EH","YE","ZM","ZW"]

class API
  indicatorCache: {}

  # A single page request from the World Bank API
  _loadPage: (url, page, success) ->
    $.ajax
      url: url
      dataType: 'jsonp'
      contentType: 'application/json'
      jsonp: 'prefix'
      data:
        format: 'jsonp'
        per_page: 2000
        page: page
      success: (data) -> success(data[1], data[0])

  # Accumulate data and callback after each page update
  _paginatedLoad: (url, callback) ->
    @_loadPage url, 1, (accum, pageinfo) =>
      pages = pageinfo.pages
      #console.log("loaded page #{ pageinfo.page }/#{ pages }")
      callback(accum)

      return if pages < 2

      for i in [2..pages]
        @_loadPage url, i, (data, pageinfo) ->
          #console.log("loaded page #{ pageinfo.page }/#{ pages }")
          for datum in data
            accum.push(datum)
          callback(accum)

  # Load a list of climate indicators.
  loadIndicators: (callback) ->
    if @_indicators
      callback(@_indicators)
      return
    @_paginatedLoad 'http://api.worldbank.org/topic/19/indicator', (@_indicators) =>
      callback(@_indicators)

  # Load the most recent values for every country for a given
  # indicator.
  loadIndicator: (id, callback) ->
    if @indicatorCache[id]?
      callback(@indicatorCache[id])
      return

    url = "http://api.worldbank.org/countries/all/indicators/#{id}?mrv=1"
    @_paginatedLoad url, (rawdata) =>
      data = {}
      #@mrv = null  # used to pick up the date of the current visualization
      for datum in rawdata
        #if not @mrv then @mrv = datum.date
        data[datum.country.id] =
          country: datum.country.id
          # I guess we can save the country names elswhere and reference
          # them with the id, but for now this is the easiest for me (decio)
          name: datum.country.value
          value: if datum.value then parseFloat(datum.value) else null
          date: datum.date
      @indicatorCache[id] = data
      callback(data)

  loadIndicatorCountries: (id, callback) ->
    @loadIndicator id, (data) ->
      filtered = {}
      for code in iso_country_codes
        filtered[code] = data[code] if data[code]?
      callback(filtered)

  loadCountry: (indicator, codes, callback) ->
    # Accepts either a code or an array of codes
    codesurl = if typeof codes == "string" then codes else codes.join(',')
    url = "http://api.worldbank.org/countries/#{codesurl}/indicators/#{indicator}"
    @_paginatedLoad url, (rawdata) =>
      data = {}

      # Initialise empty arrays
      if typeof codes == "string"
        data[codes] = []
      else
        for code in codes
          data[code] = []

      for datum in rawdata
        data[datum.country.id].push
          date: datum.date
          value: if datum.value then parseFloat(datum.value) else null

      callback(data)


module.exports = new API()
