# Make a small set of voice samples to compare voices before generating everything.
. "$PSScriptRoot\azure-tts.ps1"
$out = Join-Path (Split-Path $PSScriptRoot -Parent) 'voice-samples'
New-Item -ItemType Directory -Force $out | Out-Null

$voices = [ordered]@{
  'Ana'    = @{ name = 'en-US-AnaNeural';               note = '儿童女声' }
  'Jenny'  = @{ name = 'en-US-JennyNeural';             note = '温柔女声，支持开心/兴奋语气' }
  'Ava'    = @{ name = 'en-US-AvaMultilingualNeural';   note = '最自然的女声' }
  'Emma'   = @{ name = 'en-US-EmmaMultilingualNeural';  note = '明亮女声' }
  'Andrew' = @{ name = 'en-US-AndrewMultilingualNeural'; note = '自然男声' }
}
$texts = @('a red apple', 'I see a zebra.', 'The cow says moo.', 'Who has a long neck?', 'The rabbit is hiding behind the tree.')

$rows = @()
foreach ($v in $voices.Keys) {
  $cells = @()
  for ($i = 0; $i -lt $texts.Count; $i++) {
    $f = "$v-$i.mp3"
    Invoke-Tts -Text $texts[$i] -Voice $voices[$v].name -OutFile (Join-Path $out $f) | Out-Null
    $cells += "<td><audio controls preload='none' src='$f'></audio></td>"
  }
  $rows += "<tr><th>$v<br><small>$($voices[$v].note)</small></th>$($cells -join '')</tr>"
}

# Praise in different moods
$praise = @(
  @('Jenny-excited', 'en-US-JennyNeural', 'excited'), @('Jenny-cheerful', 'en-US-JennyNeural', 'cheerful'),
  @('Aria-excited', 'en-US-AriaNeural', 'excited'), @('Ana', 'en-US-AnaNeural', ''), @('Ava', 'en-US-AvaMultilingualNeural', '')
)
$prow = @()
foreach ($p in $praise) {
  $f1 = "praise-$($p[0])-1.mp3"; $f2 = "praise-$($p[0])-2.mp3"
  Invoke-Tts -Text 'Amazing!' -Voice $p[1] -Style $p[2] -Rate '0%' -OutFile (Join-Path $out $f1) | Out-Null
  Invoke-Tts -Text 'Perfect! You are amazing!' -Voice $p[1] -Style $p[2] -Rate '0%' -OutFile (Join-Path $out $f2) | Out-Null
  $prow += "<tr><th>$($p[0])</th><td><audio controls preload='none' src='$f1'></audio></td><td><audio controls preload='none' src='$f2'></audio></td></tr>"
}

$head = ($texts | ForEach-Object { "<th>$_</th>" }) -join ''
$html = @"
<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Moon英语 · 声音样本</title>
<style>body{font-family:-apple-system,'Microsoft YaHei',sans-serif;margin:20px;color:#333}table{border-collapse:collapse}th,td{border:1px solid #ddd;padding:8px;text-align:center}th small{color:#888;font-weight:400}audio{width:200px}</style></head><body>
<h2>朗读声音（学习内容）</h2><table><tr><th>声音</th>$head</tr>$($rows -join '')</table>
<h2>夸奖的语气</h2><table><tr><th>声音 / 语气</th><th>Amazing!</th><th>Perfect! You are amazing!</th></tr>$($prow -join '')</table>
</body></html>
"@
[IO.File]::WriteAllText((Join-Path $out 'index.html'), $html, (New-Object Text.UTF8Encoding($true)))
Write-Host "done: $out"
