# Azure text-to-speech helper. The key is read from a local file that is never committed:
#   line 1 = key, line 2 = region (e.g. eastasia)
param([string]$KeyFile = "$env:USERPROFILE\.secrets\azure-key.txt")

$lines = Get-Content $KeyFile | Where-Object { $_.Trim() -ne '' }
$script:TtsKey = $lines[0].Trim()
$script:TtsRegion = $lines[1].Trim().ToLower().Replace(' ', '')
$script:TtsUrl = "https://$($script:TtsRegion).tts.speech.microsoft.com/cognitiveservices/v1"

function ConvertTo-XmlText([string]$s) { [Security.SecurityElement]::Escape($s) }

# Synthesize one text to an mp3 file. Retries when the free tier asks us to slow down (429).
function Invoke-Tts {
  param([string]$Text, [string]$Voice, [string]$OutFile, [string]$Style = '', [string]$Rate = '-8%', [string]$Pitch = '0%')
  $inner = "<prosody rate='$Rate' pitch='$Pitch'>$(ConvertTo-XmlText $Text)</prosody>"
  if ($Style) { $inner = "<mstts:express-as style='$Style'>$inner</mstts:express-as>" }
  $ssml = "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xmlns:mstts='https://www.w3.org/2001/mstts' xml:lang='en-US'><voice name='$Voice'>$inner</voice></speak>"
  $headers = @{
    'Ocp-Apim-Subscription-Key' = $script:TtsKey
    'X-Microsoft-OutputFormat'  = 'audio-24khz-48kbitrate-mono-mp3'
    'User-Agent'                = 'moon-english'
  }
  for ($try = 1; $try -le 8; $try++) {
    try {
      Invoke-WebRequest -UseBasicParsing -Method Post -Uri $script:TtsUrl -Headers $headers `
        -ContentType 'application/ssml+xml' -Body ([Text.Encoding]::UTF8.GetBytes($ssml)) -OutFile $OutFile -TimeoutSec 30
      return $true
    } catch {
      $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
      if ($code -eq 429 -or $code -ge 500 -or $code -eq 0) { Start-Sleep -Seconds ([Math]::Min(60, 5 * $try)); continue }
      Write-Host "  failed ($code): $Text" -ForegroundColor Red
      return $false
    }
  }
  Write-Host "  gave up: $Text" -ForegroundColor Red
  return $false
}
