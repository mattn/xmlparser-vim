so ../xmlparse.vim

let loc = 'Osaka'
let xml = system('curl -s http://www.google.com/ig/api?weather='.loc)
unlet! doc
let doc = ParseXml(xml)
echo loc.'''s current weather is '.doc.find('weather').find('current_conditions').find('condition').attr['data']

" 2010/03/12 11:15:00 JST
" Osaka's current weather is Clear
"

" <?xml version="1.0"?>
" <xml_api_reply version="1">
" 	<weather module_id="0" tab_id="0" mobile_row="0" mobile_zipped="1" row="0" section="0" >
" 		<forecast_information>
" 			<city data="Osaka, Osaka"/>
" 			<postal_code data="Osaka"/>
" 			<latitude_e6 data=""/>
" 			<longitude_e6 data=""/>
" 			<forecast_date data="2010-03-12"/>
" 			<current_date_time data="2010-03-12 10:21:00 +0000"/>
" 			<unit_system data="US"/>
" 		</forecast_information>
" 		<current_conditions>
" 			<condition data="Clear"/>
" 			<temp_f data="60"/>
" 			<temp_c data="16"/>
" 			<humidity data="Humidity: 54%"/>
" 			<icon data="/ig/images/weather/sunny.gif"/>
" 			<wind_condition data="Wind: SW at 7 mph"/>
" 		</current_conditions>
" 		<forecast_conditions>
" 			<day_of_week data="Fri"/>
" 			<low data=""/>
" 			<high data="60"/>
" 			<icon data="/ig/images/weather/mostly_sunny.gif"/>
" 			<condition data="Partly Sunny"/>
" 		</forecast_conditions>
" 		<forecast_conditions>
" 			<day_of_week data="Sat"/>
" 			<low data="50"/>
" 			<high data="60"/>
" 			<icon data="/ig/images/weather/mostly_sunny.gif"/>
" 			<condition data="Partly Sunny"/>
" 		</forecast_conditions>
" 		<forecast_conditions>
" 			<day_of_week data="Sun"/>
" 			<low data="46"/>
" 			<high data="62"/>
" 			<icon data="/ig/images/weather/mostly_sunny.gif"/>
" 			<condition data="Partly Sunny"/>
" 		</forecast_conditions>
" 		<forecast_conditions>
" 			<day_of_week data="Mon"/>
" 			<low data="51"/>
" 			<high data="59"/>
" 			<icon data="/ig/images/weather/chance_of_rain.gif"/>
" 			<condition data="Chance of Rain"/>
" 		</forecast_conditions>
" 	</weather>
" </xml_api_reply>
" 
