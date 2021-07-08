#https://stackoverflow.com/questions/20705102/how-to-colorise-powershell-output-of-format-table
#https://duffney.io/usingansiescapesequencespowershell/
#$Dollars = "Look at this color"
$global:e = [char]27
#foreach($n in (1..7 + 30..37 + 90..96)){write-host $n; "$e[${n}m$Dollars${e}[0m"}

#"$e[5;36mThisIsAScript${e}[0m"

$asciiTitle = @(                                            
    " _   __  ___  ______  _   __ _   _  _____  _   _  _____  _      _     ",
    "| | / / / _ \ | ___ \| | / /| | | |/  ___|| | | ||  ___|| |    | |    ",
    "| |/ / / /_\ \| |_/ /| |/ / | | | |\ `--. | |_| || |__  | |    | |    ",
    "|    \ |  _  ||    / |    \ | | | | `--. \|  _  ||  __| | |    | |    ",
    "| |\  \| | | || |\ \ | |\  \| |_| |/\__/ /| | | || |___ | |____| |____",
    "\_| \_/\_| |_/\_| \_|\_| \_/ \___/ \____/ \_| |_/\____/ \_____/\_____/")
                                                                                     
                                                                                    
# Colors h
#foreach($num in 0..80){
#
#    "$e[5;36mThisIsAScript${e}[0m"
#
#}
function ListMenu (){
    

}

Class drawObject {
    [int]$x
    [int]$y
    $ascii
    [int]$color
    [bool]$redraw
    [bool]$strsubset
    [array]$slice

    drawObject(
        [int]$xo,
        [int]$yo,
        $s,
        [int]$c
    ){
    $this.x      = $xo
    $this.y      = $yo
    $this.ascii  = $s
    $this.color  = $c
    $this.redraw = $false
    $this.strsubset = $false
    $this.slice = (0, $s.Length)    
    }
    [string[]] cleanup() {
        $global:buffer = $null
        $global:y = $this.y
        foreach($l in $this.ascii){
            #$global:buffer += $global:e + "[" + $global:y + ";" + $this.x + "H" + $global:e + "[" + $this.color + "m" + (" " * $l.Length) + $global:e +"[0m"
            write-host ($global:e + "[" + $global:y + ";" + $this.x + "H" + $global:e + "[" + $this.color + "m" + (" " * $l.Length) + $global:e +"[0m")
            $global:y +=1
        }
    return $global:buffer
    }

    [string[]] drawString(){
        $global:buffer = $null
        $global:y = $this.y
        if($this.strsubset){
            foreach($l in $this.ascii[$this.slice[0]..$this.slice[1]]){
                $global:buffer += $global:e + "[" + $global:y + ";" + $this.x + "H" + $global:e + "[" + $this.color + "m" + $l + $global:e +"[0m"
                #$global:e + "[" + $global:y + ";" + $this.x + "H" + $global:e + "[" + $this.color + "m" + $l + $global:e +"[0m"
                $global:y +=1
            }
        }    
        else{
            foreach($l in $this.ascii){
                $global:buffer += $global:e + "[" + $global:y + ";" + $this.x + "H" + $global:e + "["  + $this.color + "m" + $l + $global:e +"[0m"
                #$global:e + "[" + $global:y + ";" + $this.x + "H" + $global:e + "["  + $this.color + "m" + $l + $global:e +"[0m"
                $global:y +=1
            }
        }
        
        return $global:buffer
    }
}

$TitleObject = [drawObject]::new(5,5,$asciiTitle,92)
# Example of class execution
#$titleObject3 = [drawObject]::new(20, 20, @('dogs','Elves'), 92)
#$titleObject3.drawString()
$enter = [drawObject]::new(4,20,@('Enter Your Name:'),36)
$keypress = [drawObject]::new(20,20,@(' '),36)
$report    = [drawObject]::new(40,10, ((get-service | ft | out-string).Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)), 36)
$report.strsubset = $true
$report.slice = (0,8)
############  This creates the border object and assigns it to whatever
$ymax = $host.ui.rawui.WindowSize.Height - 1
$xmax = $host.ui.rawui.WindowSize.Width
$borderAscii = ''
foreach($y in 1..$ymax){
    foreach($x in 1..$xmax){
        if($x -eq 1 -OR $X -eq $xmax -or $y -eq 1 -or $y -eq $ymax){
            $borderAscii+="$e[${y};${x}H${e}[7m#$e[0m"
            }
        }
    }                   

# Functions live here
#clear-display
function clear-display(){
    "$e[2J${e}[t${e}[0m"
}


function Screen-Blit($objectArray){
    $buffer = @()
    
    #Takes updates objects from the object array and draws them.
        foreach($obj in $objectArray){
            $obj.drawString()
        }
    return $buffer
}

#Setup and initialization 
$objects = @($titleObject, $keypress,$report,$enter)
clear-display
$borderAscii
$e = [char]27
function TestMenu ($titleObject, $keypress,$report,$enter) {
    $objects = @($titleObject, $keypress,$report,$enter)
    while($true){
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        # arrow keys move the title, and letters are presented in the middle of the screen
        Switch($key.virtualKeyCode){
            37 {$titleObject.cleanup() ;$titleObject.x -=1; $titleObject.color += 1;$objects +=$titleObject }
            38 {$report.slice[0] +=1; $report.slice[1] +=1; ; $report.color = 6; $objects += $report }
            39 {$titleObject.cleanup(); $titleObject.x +=1; $titleObject.color += 1;$objects += $titleObject }
            40 {$report.slice[0] -=1; $report.slice[1] -=1; $report.color = 5; $objects += $report}
            8 {$keypress.ascii = @(' ');$keypress.drawstring();$keypress.x -=1; $objects+= $keypress }
            default {$keypress.ascii = @($key.character);$keypress.drawstring(); $keypress.x += 1 }
        }
        Screen-Blit $objects
        $objects = @()
}
}
testMenu $titleObject $keypress $report $enter

#while($true){
#    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#}