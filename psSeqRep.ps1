[CmdletBinding()] 
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)][int64]$begin,
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)][int64]$end,
        [Parameter(Mandatory=$false, ValueFromPipeline, ValueFromPipelineByPropertyName)][string]$logFile
    )
    
Begin{
    class seqRep{
        $op = @( '+', '-', '/', '*', ' ' )                
        $numbers = @(0,1,2,3,4,5,6,7,8,9)
        $results = @{}
        $begin = 0
        $end = 0
        $starttime = (get-date)
        $logfile = "seqRep.log"
        
        seqRep($begin, $end, $logFile){
            if($logFile -ne $null -and $logfile -ne ''){
                $this.logFile = $logFile
                "" | set-content "$($this.logFile)"
            }
            $this.begin = $begin
            $this.end = $end
        }

        [string]testEqn($eqn, $search){
            if($this.logFile -ne $null -and $this.logfile -ne ''){
                $eqn | add-content "$($this.logfile)"
            }
            
                if($this.results.keys -contains ([int]$search)){
                    return $this.results[ ([int]$search) ]
                }else{
                    try{
                        $sol = iex $eqn -errorAction silentlyContinue
                    }catch{
                        $sol = -1
                    }
                    
                    
                    if($sol -eq [math]::floor($sol) -and $sol -ge $this.begin -and $sol -le $this.end  ){
                        if(!($this.results.keys -contains ([int]$sol) )){
                            $this.results.add(
                                ([int]$sol), 
                                $eqn
                            )
                        }
                    }
                    if($sol -eq $search){
                        return $eqn
                    }else{
                        return ''
                    }
                }
            
        }
        
        [string] getEqn($a, $b, $c, $d, $e, $f, $g, $h, $i){
            $template = ""
            $index = 0;
            $this.numbers | % {
                $template += "$($_)"
                switch($index){
                    0 {$template += $this.op[$a]}
                    1 {$template += $this.op[$b]}
                    2 {$template += $this.op[$c]}
                    3 {$template += $this.op[$d]}
                    4 {$template += $this.op[$e]}
                    5 {$template += $this.op[$f]}
                    6 {$template += $this.op[$g]}
                    7 {$template += $this.op[$h]}
					8 {$template += $this.op[$i]}
                }
                $index++
            }
            $template = $template -replace ' \(','*(' -replace '\) ',')*' -replace ' ',''
            return $template
        }
        
        [string] getEqn($a, $b, $c, $d, $e, $f, $g, $h, $i, $first, $last){
            $template = ""
            $index = 0;
            $this.numbers | % {
                if($index -eq $first){ $template += "(" }
                $template += "$($_)"
                if($index -eq $last){ $template += ")" }
                switch($index){
                    0 {$template += $this.op[$a]}
                    1 {$template += $this.op[$b]}
                    2 {$template += $this.op[$c]}
                    3 {$template += $this.op[$d]}
                    4 {$template += $this.op[$e]}
                    5 {$template += $this.op[$f]}
                    6 {$template += $this.op[$g]}
                    7 {$template += $this.op[$h]}
					8 {$template += $this.op[$i]}
                }
                $index++
            }
            $template = $template -replace ' \(','*(' -replace '\) ',')*' -replace ' ',''
            return $template
        }
        
        execute(){
            $this.loop()
            write-host ([timespan]( (get-date) - $this.starttime))
        }
        
        loop(){
            $eqn = ""
            for($search = $this.begin; $search -le $this.end; $search++){
                $found = $false
                $iterations = 0
                while($iterations -lt 1000 -and $found -eq $false){
                    clear
                    write-host "Searching for: $($search)"
                    $this.results.getEnumerator() | sort Name | ft | out-string | write-host
                    
                    $iterations++
                    $a = (get-random -minimum 0 -maximum 5)
                    $b = (get-random -minimum 0 -maximum 5)
                    $c = (get-random -minimum 0 -maximum 5)
                    $d = (get-random -minimum 0 -maximum 5)
                    $e = (get-random -minimum 0 -maximum 5)
                    $f = (get-random -minimum 0 -maximum 5)
                    $g = (get-random -minimum 0 -maximum 5)
                    $h = (get-random -minimum 0 -maximum 5)
                    $i = (get-random -minimum 0 -maximum 5)
                    $opsIndex  = [System.Collections.Generic.List[System.Object]]( @($a, $b, $c, $d, $e, $f, $g, $h, $i) )
                    for($rot = 0; $rot -lt 9; $rot++){
                        $o1 = $opsIndex[0];
                        $opsIndex.removeAt(0)
                        $opsIndex.add($o1)
                        $a, $b, $c, $d, $e, $f, $g, $h, $i = $opsIndex
                        
                        if($found -eq $false){
                            $eqn = $this.getEqn($a, $b, $c, $d, $e, $f, $g, $h, $i)
                            if($this.testEqn($eqn, $search) -ne ''){
                                $found = $true
                            }
                        }
                    }
                                                        
                    #if multiplication or division is present, try with parenthesis
                    if(
                        $this.op[$a] -eq '/' -or $this.op[$a] -eq '*' -or
                        $this.op[$b] -eq '/' -or $this.op[$b] -eq '*' -or
                        $this.op[$c] -eq '/' -or $this.op[$c] -eq '*' -or
                        $this.op[$d] -eq '/' -or $this.op[$d] -eq '*' -or
                        $this.op[$e] -eq '/' -or $this.op[$e] -eq '*' -or
                        $this.op[$f] -eq '/' -or $this.op[$f] -eq '*' -or
                        $this.op[$g] -eq '/' -or $this.op[$g] -eq '*' -or
                        $this.op[$h] -eq '/' -or $this.op[$h] -eq '*' -or
                        $this.op[$i] -eq '/' -or $this.op[$i] -eq '*'
                    ){                                              
                        # add paranthesis grouping to selections of numbers
                        for($first = 0; $first -lt 8; $first++){
                            for($last = 9; $last -gt $first; $last--){
                                
                                $opsIndex  = [System.Collections.Generic.List[System.Object]]( @($a, $b, $c, $d, $e, $f, $g, $h, $i) )
                                for($rot = 0; $rot -lt 9; $rot++){
                                    $o1 = $opsIndex[0];
                                    $opsIndex.removeAt(0)
                                    $opsIndex.add($o1)

                                    $a, $b, $c, $d, $e, $f, $g, $h, $i = $opsIndex
                                    if($found -eq $false){
                                        $eqn = $this.getEqn($a, $b, $c, $d, $e, $f, $g, $h, $i, $first, $last)
                                        if($this.testEqn($eqn, $search) -ne ''){
                                            $found = $true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                if(!$found){
                    write-host "$($search) could not be found"
                }
            }
        }
    }
}
Process{
    clear;
    $error.clear()
    
    $seqRep = [seqRep]::new($begin, $end, $logfile);
    $seqRep.execute()
}
End{

}

