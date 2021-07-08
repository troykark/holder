https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
$Dollars = "Look at this color"
$e = [char]27
foreach($n in (1..7 + 30..37 + 90..96)){write-host $n; "$e[${n}m$Dollars${e}[0m"}