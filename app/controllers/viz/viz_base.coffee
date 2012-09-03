Spine = require('spine')
API = require('lib/api')


#class VizBase extends Spine.Controller
class VizBase extends Spine.Module

  @extend(Spine.Events)

  # this is still a mess
  # it should contain all configuration and methods 
  # that are common across all visualisations...

  constructor: ->
    super
    
  
    @wb_regions =
      "1A": "Arab World"
      "1W": "World"
      "4E": "East Asia & Pacific (developing only)"
      "7E": "Europe & Central Asia (developing only)"
      "8S": "South Asia"
      "EU": "European Union"
      "OE": "OECD members"
      "XC": "Euro area"
      "XD": "High income"
      "XE": "Heavily indebted poor countries (HIPC)"
      "XJ": "Latin America & Caribbean (developing only)"
      "XL": "Least developed countries: UN classification"
      "XM": "Low income"
      "XN": "Lower middle income"
      "XO": "Low & middle income"
      "XP": "Middle income"
      "XQ": "Middle East & North Africa (developing only)"
      "XR": "High income: nonOECD"
      "XS": "High income: OECD"
      "XT": "Upper middle income"
      "XU": "North America"
      "XY": "Not classified"
      "Z4": "East Asia & Pacific (all income levels)"
      "Z7": "Europe & Central Asia (all income levels)"
      "ZF": "Sub-Saharan Africa (developing only)"
      "ZG": "Sub-Saharan Africa (all income levels)"
      "ZJ": "Latin America & Caribbean (all income levels)"
      "ZQ": "Middle East & North Africa (all income levels)"
      
    @iso_country_codes =
      "AF":"Afghanistan"
      "AX":"Åland Islands"
      "AL":"Albania"
      "DZ":"Algeria"
      "AS":"American Samoa"
      "AD":"Andorra"
      "AO":"Angola"
      "AI":"Anguilla"
      "AQ":"Antarctica"
      "AG":"Antigua and Barbuda"
      "AR":"Argentina"
      "AM":"Armenia"
      "AW":"Aruba"
      "AU":"Australia"
      "AT":"Austria"
      "AZ":"Azerbaijan"
      "BS":"Bahamas"
      "BH":"Bahrain"
      "BD":"Bangladesh"
      "BB":"Barbados"
      "BY":"Belarus"
      "BE":"Belgium"
      "BZ":"Belize"
      "BJ":"Benin"
      "BM":"Bermuda"
      "BT":"Bhutan"
      "BO":"Bolivia"
      "BA":"Bosnia and Herzegovina"
      "BW":"Botswana"
      "BV":"Bouvet Island"
      "BR":"Brazil"
      "IO":"British Indian Ocean Territory"
      "BN":"Brunei Darussalam"
      "BG":"Bulgaria"
      "BF":"Burkina Faso"
      "BI":"Burundi"
      "KH":"Cambodia"
      "CM":"Cameroon"
      "CA":"Canada"
      "CV":"Cape Verde"
      "KY":"Cayman Islands"
      "CF":"Central African Republic"
      "TD":"Chad"
      "CL":"Chile"
      "CN":"China"
      "CX":"Christmas Island"
      "CC":"Cocos (Keeling) Islands"
      "CO":"Colombia"
      "KM":"Comoros"
      "CG":"Congo"
      "CD":"Congo, The Democratic Republic of The"
      "CK":"Cook Islands"
      "CR":"Costa Rica"
      "CI":"Cote D'ivoire"
      "HR":"Croatia"
      "CU":"Cuba"
      "CY":"Cyprus"
      "CZ":"Czech Republic"
      "DK":"Denmark"
      "DJ":"Djibouti"
      "DM":"Dominica"
      "DO":"Dominican Republic"
      "EC":"Ecuador"
      "EG":"Egypt"
      "SV":"El Salvador"
      "GQ":"Equatorial Guinea"
      "ER":"Eritrea"
      "EE":"Estonia"
      "ET":"Ethiopia"
      "FK":"Falkland Islands (Malvinas)"
      "FO":"Faroe Islands"
      "FJ":"Fiji"
      "FI":"Finland"
      "FR":"France"
      "GF":"French Guiana"
      "PF":"French Polynesia"
      "TF":"French Southern Territories"
      "GA":"Gabon"
      "GM":"Gambia"
      "GE":"Georgia"
      "DE":"Germany"
      "GH":"Ghana"
      "GI":"Gibraltar"
      "GR":"Greece"
      "GL":"Greenland"
      "GD":"Grenada"
      "GP":"Guadeloupe"
      "GU":"Guam"
      "GT":"Guatemala"
      "GG":"Guernsey"
      "GN":"Guinea"
      "GW":"Guinea-bissau"
      "GY":"Guyana"
      "HT":"Haiti"
      "HM":"Heard Island and Mcdonald Islands"
      "VA":"Holy See (Vatican City State)"
      "HN":"Honduras"
      "HK":"Hong Kong"
      "HU":"Hungary"
      "IS":"Iceland"
      "IN":"India"
      "ID":"Indonesia"
      "IR":"Iran, Islamic Republic of"
      "IQ":"Iraq"
      "IE":"Ireland"
      "IM":"Isle of Man"
      "IL":"Israel"
      "IT":"Italy"
      "JM":"Jamaica"
      "JP":"Japan"
      "JE":"Jersey"
      "JO":"Jordan"
      "KZ":"Kazakhstan"
      "KE":"Kenya"
      "KI":"Kiribati"
      "KP":"Korea, Democratic People's Republic of"
      "KR":"Korea, Republic of"
      "KW":"Kuwait"
      "KG":"Kyrgyzstan"
      "LA":"Lao People's Democratic Republic"
      "LV":"Latvia"
      "LB":"Lebanon"
      "LS":"Lesotho"
      "LR":"Liberia"
      "LY":"Libyan Arab Jamahiriya"
      "LI":"Liechtenstein"
      "LT":"Lithuania"
      "LU":"Luxembourg"
      "MO":"Macao"
      "MK":"Macedonia, The Former Yugoslav Republic of"
      "MG":"Madagascar"
      "MW":"Malawi"
      "MY":"Malaysia"
      "MV":"Maldives"
      "ML":"Mali"
      "MT":"Malta"
      "MH":"Marshall Islands"
      "MQ":"Martinique"
      "MR":"Mauritania"
      "MU":"Mauritius"
      "YT":"Mayotte"
      "MX":"Mexico"
      "FM":"Micronesia, Federated States of"
      "MD":"Moldova, Republic of"
      "MC":"Monaco"
      "MN":"Mongolia"
      "ME":"Montenegro"
      "MS":"Montserrat"
      "MA":"Morocco"
      "MZ":"Mozambique"
      "MM":"Myanmar"
      "NA":"Namibia"
      "NR":"Nauru"
      "NP":"Nepal"
      "NL":"Netherlands"
      "AN":"Netherlands Antilles"
      "NC":"New Caledonia"
      "NZ":"New Zealand"
      "NI":"Nicaragua"
      "NE":"Niger"
      "NG":"Nigeria"
      "NU":"Niue"
      "NF":"Norfolk Island"
      "MP":"Northern Mariana Islands"
      "NO":"Norway"
      "OM":"Oman"
      "PK":"Pakistan"
      "PW":"Palau"
      "PS":"Palestinian Territory, Occupied"
      "PA":"Panama"
      "PG":"Papua New Guinea"
      "PY":"Paraguay"
      "PE":"Peru"
      "PH":"Philippines"
      "PN":"Pitcairn"
      "PL":"Poland"
      "PT":"Portugal"
      "PR":"Puerto Rico"
      "QA":"Qatar"
      "RE":"Reunion"
      "RO":"Romania"
      "RU":"Russian Federation"
      "RW":"Rwanda"
      "SH":"Saint Helena"
      "KN":"Saint Kitts and Nevis"
      "LC":"Saint Lucia"
      "PM":"Saint Pierre and Miquelon"
      "VC":"Saint Vincent and The Grenadines"
      "WS":"Samoa"
      "SM":"San Marino"
      "ST":"Sao Tome and Principe"
      "SA":"Saudi Arabia"
      "SN":"Senegal"
      "RS":"Serbia"
      "SC":"Seychelles"
      "SL":"Sierra Leone"
      "SG":"Singapore"
      "SK":"Slovakia"
      "SI":"Slovenia"
      "SB":"Solomon Islands"
      "SO":"Somalia"
      "ZA":"South Africa"
      "GS":"South Georgia and The South Sandwich Islands"
      "ES":"Spain"
      "LK":"Sri Lanka"
      "SD":"Sudan"
      "SR":"Suriname"
      "SJ":"Svalbard and Jan Mayen"
      "SZ":"Swaziland"
      "SE":"Sweden"
      "CH":"Switzerland"
      "SY":"Syrian Arab Republic"
      "TW":"Taiwan, Province of China"
      "TJ":"Tajikistan"
      "TZ":"Tanzania, United Republic of"
      "TH":"Thailand"
      "TL":"Timor-leste"
      "TG":"Togo"
      "TK":"Tokelau"
      "TO":"Tonga"
      "TT":"Trinidad and Tobago"
      "TN":"Tunisia"
      "TR":"Turkey"
      "TM":"Turkmenistan"
      "TC":"Turks and Caicos Islands"
      "TV":"Tuvalu"
      "UG":"Uganda"
      "UA":"Ukraine"
      "AE":"United Arab Emirates"
      "GB":"United Kingdom"
      "US":"United States"
      "UM":"United States Minor Outlying Islands"
      "UY":"Uruguay"
      "UZ":"Uzbekistan"
      "VU":"Vanuatu"
      "VE":"Venezuela"
      "VN":"Viet Nam"
      "VG":"Virgin Islands, British"
      "VI":"Virgin Islands, U.S."
      "WF":"Wallis and Futuna"
      "EH":"Western Sahara"
      "YE":"Yemen"
      "ZM":"Zambia"
      "ZW":"Zimbabwe"
      
    @continents = ["Z4", "Z7", "ZG", "ZJ", "XU", "ZQ"]
    @income_groups = ["XD", "XM", "XN", "XT"]
    
    # this is here, so we do not set up the svg dimensions more than once
    @is_initialized = false
    
    
  
  isRegion: (code) -> 
    bool = if @wb_regions[code] then true else false
    
  
  getCountryList: ->
    countries = []
    for iso, name of @iso_country_codes
      countries.push({code: iso, country: name})
    countries
    
    
  getQuantiles: (data, breaks=10) ->
    range = [0..breaks]
    q = []
    for br in range
      q.push(d3.quantile(data.sort( (a, b) -> d3.ascending(a, b) ), br / breaks))
    q
    
    
  getMedian: (data) ->
    # special case of getQuantiles for finding the median value of an array of values
    median = d3.quantile(data.sort( (a,b) -> d3.ascending(a, b) ), 0.5)
    
    
  getCounGrData: (json, group) ->
    data = []
    for code, obj of json
      if obj.country in group and obj.value
        data.push(obj)
    data
    
    
  getCountryData: (json) ->
    data = []
    for code, obj of json
      if obj.value and not @isRegion(obj.country)
        data.push(obj)
    data
        

  getDataVals: (json, countries=false, regions=[]) ->
    # returns a 2-dimensional array with data vals and country ids
    data = []
    ids = []
    names = []
    
    for code, obj of json
      if (obj.value isnt null and obj.value >= 0 and regions.length == 0 and not @isRegion(code))
        data.push(obj.value)
        ids.push(code)
        if countries
          names.push(obj.name)
#      else if (obj.value isnt null and regions.length > 0 and @isRegion(obj.country))
#        for region in regions
#          if obj.country == region
#            #console.log parseFloat(obj.value), obj.country.value
#            data.push(parseFloat(obj.value))
#            ids.push(obj.country)

    data_vals = if countries then [data, ids, names] else [data, ids]
    
    
    
  getDataValsObj: (json, regions=[]) ->
    # return a data object
    data_array = @getDataVals(json, regions)
    data_obj = {}
    for data, i in data_array[1]
      data_obj[data] = data_array[0][i]
    data_obj
    
    
  _compareDataValsObjArray: (a, b) ->
    if a.id < b.id
       return -1
    if a.id > b.id
      return 1
    return 0
    
    
  getDataValsObjArray: (json, regions=[]) ->
    # return a data object
    data_array = @getDataVals(json, regions).sort(@_compareDataValsObjArray)
    data_obj = []
    for data, i in data_array[1]
      data_obj.push({value: data_array[0][i], id: data})
    data_obj
      
    
  cleanData: (json) ->
    cleand = []
    for obj in json[1]
      if (obj.value isnt null and not @isRegion(obj.country.id))
        cleand.push(obj)
    cleand
    
    
  getMapDimensions: (wh, ww) ->  
    free_width = ww * (1 - @left_factor) * .98
    free_height = wh * (1 - @bottom_factor) * .98
    canvas_ratio = free_width / free_height
    map_ratio = 2 #TODO: hardcoded?
    if canvas_ratio > map_ratio
      mh = free_height
      mw = mh * map_ratio
    else
      mw = free_width
      mh = mw / map_ratio    
    dimensions = 
      map_width: mw
      map_height: mh
      
      
  truncText: (txt, max_length) ->
    if txt.length > max_length
      return txt[0...(max_length - 3)] + '...'
    else
      return txt
      
      
  extrUnitMeasure: (txt) ->
    begin = txt.indexOf('(')
    end = txt.indexOf(')')
    unit = txt.slice(begin,end)
    
  
  setDimensions: (conf) ->
    par = conf.par or .21
    wrapp = $("##{conf.wrapper}")
    @outer_width = wrapp.width() * .8
    @outer_height = wrapp.height() * .8
    @offset = @outer_width * par
    @inner_width = @outer_width - @offset
    @inner_height = @outer_height - @offset
    @is_initialized = true
    
    
#  getSource: (ind) ->
#    source_value = ind.sourceValue
#    source_org = ind.sourceOrganization
#    "Source value: #{source_value}. Source organization: #{source_org}"
    
    
module.exports = VizBase