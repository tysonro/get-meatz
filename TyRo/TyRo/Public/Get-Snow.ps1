Function Get-Snow {

# differen invoke-webrequest examples: http://www.leeholmes.com/blog/2012/03/31/how-to-download-an-entire-wordpress-blog/

# REST API
https://blogs.technet.microsoft.com/heyscriptingguy/2018/02/21/powershell-and-the-rest-api-for-the-it-pro/

# API call
# https://www.twilio.com/docs/usage/tutorials/how-to-make-http-basic-request-twilio-powershell

# https://www.gngrninja.com/script-ninja/2016/2/8/powershell-fun-with-weather-undergrounds-api-part-2
    

    $URI = 'https://www.wunderground.com/us/me/sugarloaf-mountain/precipitation?hdf=1'

    $WebRequest = Invoke-WebRequest -Uri $URI

    $Snow = $WebRequest.ParsedHtml.getElementsByTagName('p') | Select-Object -ExpandProperty outertext

}

    $findMe = "Sugarloaf Mountain"
    $find   = Invoke-RestMethod -Uri "http://autocomplete.wunderground.com/aq?query=$findMe"

    $baseURL      = 'http://api.wunderground.com/api/'



$response =     invoke-restmethod -uri 'https://www.wunderground.com/us/me/sugarloaf-mountain/precipitation?hdf=1'



# From gngrninja for a starting point:

function Get-Weather {
    param()
   
    $findMe = $city
    $find   = Invoke-RestMethod -Uri "http://autocomplete.wunderground.com/aq?query=$findMe"

    if ($find) {
        
        $cityAPI  = $find.Results[0].l
        $city     = $find.Results[0].name
        
        $fullURL  = $baseURL + $apiKey + "/features/conditions/hourly/forecast/webcams/alerts" + "$cityAPI.json"
        $radarURL = "http://api.wunderground.com/api/$apiKey/animatedradar/animatedsatellite" + "$cityAPI.gif?num=6&delay=50&interval=30"
        
        Write-Host `n"API URLS for $city" -foregroundcolor $foregroundColor
        Write-Host `t$fullURL
        Write-Host `t$radarURL
        
        $weatherForecast = Invoke-RestMethod -Uri $fullURL -ContentType $acceptHeader
        
        $currentCond     = $weatherForecast.current_observation
        
        Write-Host `n"Current Conditions for: $city" -foregroundColor $foregroundColor
        Write-Host $currentCond.Weather 
        Write-Host "Temperature:" $currentCond.temp_f"F"
        Write-Host "Winds:" $currentCond.wind_string
        
        $curAlerts = $weatherForecast.alerts 
        
        if ($curAlerts) {
            
            if ($lifx) { Get-LIFXAPI -action flashcolor -brightness 1 -color Red -state on }
            
            $typeName = Get-WeatherFunction -Weather 'alert' -value $weatherForecast.alerts
            
            $alertDate  = $curAlerts.date
            $alertExp   = $curAlerts.expires 
            $alertMsg   = $curAlerts.message
            
            Write-Host `n"Weather Alert! ($typeName)" -foregroundcolor Red
            Write-Host "Date: $alertDate Expires: $alertExp"
            Write-Host "$alertMsg"    
            
            if ($sendAlertEmail) {

                Foreach ($email in $alertList) {
                    
                    Send-WeatherEmail -to $email -Subject "Weather Alert!" -Body "Alert Type: $typeName City: $city Message: $alertMsg"
                
                }
            }                  

        } 
        
    }

    Switch ($forecast) {
    
        {$_ -eq 'hourly'} {
 
            if ($sendEmail) {

                $hourlyForecast = $weatherForecast.hourly_forecast
                
                $body = "<p></p>"
                $body += "<p>Here is your hourly forecast!</p>"
                
                $selCam   = Get-Random $weatherForecast.webcams.count
                
                $camImg   = $weatherforecast.webcams[$selCam].CURRENTIMAGEURL
                $camName  = $weatherForecast.webcams[$selCam].linktext
                $camLink  = $weatherForecast.webcams[$selCam].link
                
                $body += "<p>Random webcam shot from: <a href=`"$camLink`">$camName</a></p>"
                $body += "<p><img src=`"$camImg`"></p>"                 
                                
                $body += "<p>$city Radar:</p>"
                $body += "<p><img src=`"$radarURL`"></p>"  
                
                if ($curAlerts) {
                    
                    $body += "<p><b><font color=`"red`">Weather Alert! ($typeName)</font></b></p>"
                    $body += "<p>Date: $alertDate Expires: $alertExp</p>"
                    $body += "<p>$alertMsg</p>"    
    
                }           
                
                foreach ($hour in $hourlyForecast) {
                    
                    $body += "<p></p>"
                    $body += "<p></p>"
                    
                    $prettyTime       = $hour.fcttime.pretty
                    $hourTemp         = $hour.temp.english  
                    $hourImg          = $hour.icon_url
                    
                    [int]$hourChill   = $hour.windchill.english
                    
                    if ($hourChill -eq -9999) {
                    
                        $hourChilltxt = 'N/A'
                        
                    } else {
                        
                        $hourChilltxt = $hourChill.ToString() + 'F'
                   
                    }
                                        
                    $hourWind         = $hour.wspd.english
                    $windDir          = $hour.wdir.dir
                    $hourUV           = $hour.uvi
                    $dewPoint         = $hour.dewpoint.english
                    $hourFeels        = $hour.feelslike.english
                    $hourHum          = $hour.humidity
                    $conditions       = $hour.condition
                    [int]$hourPrecip  = $hour.pop
                    
                    $popText = Get-WeatherFunction -Weather 'preciptext' -value $hourPrecip
                    
                    $body += "<p><b>$prettyTime</b></p>"
                    $body += "<p><img src=`"$hourImg`">$conditions</p>"
                    $body += "<p>Chance of precipitation: $hourPrecip% / $popText</p>"
                    $body += "<p>Current Temp: $hourTemp`F Wind Chill: $hourChilltxt Feels Like: $hourFeels`F</p>"
                    $body += "<p>Dew Point: $dewPoint</p>"
                    $body += "<p>Wind Speed: $hourWind`mph Direction: $windDir</p>"
                    $body += "<p>Humidity: $hourHum%</p>"
                    $body += "<p>UV Index: $hourUV"     
                    
                }
                
                foreach ($email in $weatherList) {Send-WeatherEmail -To $email -Subject "Your hourly forecast for $city" -body $body}
            
            }            
        
        }
        
        {$_ -eq 'forecast'} {                
              
            if ($sendEmail) {

                $todayForecast = $weatherForecast.forecast.simpleforecast.forecastday
                
                $body = "<p></p>"
                $body += "<p>Here is your 4 day forecast!</p>"
                
                $selCam   = Get-Random $weatherForecast.webcams.count
                
                $camImg   = $weatherforecast.webcams[$selCam].CURRENTIMAGEURL
                $camName  = $weatherForecast.webcams[$selCam].linktext
                $camLink  = $weatherForecast.webcams[$selCam].link
                
                $body += "<p>Random webcam shot from: <a href=`"$camLink`">$camName</a></p>"
                $body += "<p><img src=`"$camImg`"></p>"                 
                
                $body += "<p>$city Radar:</p>"
                $body += "<p><img src=`"$radarURL`"></p>"      
                
                $curAlerts = $weatherForecast.alerts 
                
                if ($curAlerts) {
                    
                    $body += "<p><b><font color=`"red`">Weather Alert! ($typeName)</font></b></p>"
                    $body += "<p>Date: $alertDate Expires: $alertExp</p>"
                    $body += "<p>$alertMsg</p>"    

                }                   
               
                foreach ($day in $todayForecast) {
                    
                    $body += "<p></p>"
                    $body += "<p></p>"
                    
                    $dayImg          = $day.icon_url
                    $dayMonth        = $day.date.monthname
                    $dayDay          = $day.date.day
                    $dayName         = $day.date.weekday
                    $dayHigh         = $day.high.fahrenheit  
                    $dayLow          = $day.low.fahrenheit
                    $maxWind         = $day.maxwind.mph
                    $aveWind         = $day.avewind.mph
                    $aveHum          = $day.avehumidity
                    $conditions      = $day.conditions
                    [int]$dayPrecip  = $day.pop
                    
                    $popText = Get-WeatherFunction -Weather 'preciptext' -value $dayPrecip
                    
                    $body += "<p><b>$dayName, $dayMonth $dayDay</b></p>"
                    $body += "<p><img src=`"$dayImg`">$conditions</p>"
                    $body += "<p>Chance of precipitation: $dayPrecip% / $popText</p>"
                    $body += "<p>High: $dayHigh`F Low: $dayLow`F</p>"
                    $body += "<p>Ave Winds: $aveWind`mph Max Winds: $maxWind`mph</p>"
                    $body += "<p>Humidity: $aveHum%</p>"
         
                }

                foreach ($email in $weatherList) {Send-WeatherEmail -To $email -Subject "Your 4 day forecast for $city" -body $body}
            
            }  
            
        }

        {$_ -eq 'camera'} {
            
            $selCam    = Get-Random $weatherForecast.webcams.count
            
            $camImg    = $weatherforecast.webcams[$selCam].CURRENTIMAGEURL
            $camName   = $weatherForecast.webcams[$selCam].linktext
            $camLink   = $weatherForecast.webcams[$selCam].link
            
            $fileExt   = $camImg.SubString($camImg.LastIndexOf("."),4)
            
            $cityShort = $city.substring(0,$city.lastindexof(","))
            
            $fileName  = $cityShort + $fileExt
            
            $location  = (Get-Location).Path
            
            $camFile   = Invoke-WebRequest -Uri $camImg -OutFile "$location\$fileName"   
            
            $file = $location + "\" + $fileName
            
            $gallery = 'YourSquareSpaceGalleryOrEmailToSendAttachmentTo' 
            
            $SMTPClient             = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
            $SMTPMessage            = New-Object System.Net.Mail.MailMessage($emailFrom,$gallery,"$city cam","$city cam")
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($emailUser,$emailPass)
            
            $att                    = New-Object Net.Mail.Attachment($file)
            $SMTPClient.EnableSsl   = $true
           
            Switch (($fileName.substring($fileName.LastIndexOf(".")+1)).tolower()) {
                
                {$_ -like "*png*"} {
                
                    $typeExt = 'png'    
                    
                }
                
                {$_ -like "*jpg*"} {
                
                    $typeExt = 'jpg'     
                    
                }
                
                {$_ -like "*gif*"} {
                    
                    $typeExt = 'gif' 
                    
                }                                
                
            }
            
            $SMTPMessage.Attachments.Add($att)
            ($smtpmessage.Attachments).contenttype.mediatype = "image/$typeExt"
            
            $SMTPClient.Send($SMTPMessage)
            
            $att.Dispose()
            $SMTPMessage.Dispose()
            
            Remove-Item $file
            
        }
    
    } 
    
    Return $weatherForecast

}