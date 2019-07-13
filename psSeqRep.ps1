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
        $begin = 0
        $end = 0
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
            try{
                $sol = iex $eqn -errorAction silentlyContinue
                if($sol -eq $search){
                    return $eqn
                }else{
					return ''
				}
            }catch{}
            return ''
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
        }
        
        loop(){
            $eqn = ""
            for($search = $this.begin; $search -le $this.end; $search++){
                $found = $false
                $iterations = 0
                :search for($a = 0; $a -lt 5; $a++){
                    for($b = 0; $b -lt 5; $b++){
                        for($c = 0; $c -lt 5; $c++){
                            for($d = 0; $d -lt 5; $d++){
                                for($e = 0; $e -lt 5; $e++){
                                    for($f = 0; $f -lt 5; $f++){
                                        for($g = 0; $g -lt 5; $g++){
                                            for($h = 0; $h -lt 5; $h++){
												for($i = 0; $i -lt 5; $i++){
													write-host '.' -noNewLine
													$iterations++
													
													$opsIndex  = [System.Collections.Generic.List[System.Object]]( @($a, $b, $c, $d, $e, $f, $g, $h, $i) )
													for($rot = 0; $rot -lt 9; $rot++){
														$o1 = $opsIndex[0];
														$opsIndex.removeAt(0)
														$opsIndex.add($o1)

														$a, $b, $c, $d, $e, $f, $g, $h, $i = $opsIndex
														
														$eqn = $this.getEqn($a, $b, $c, $d, $e, $f, $g, $h, $i)
														# write-host $eqn
														if($this.testEqn($eqn, $search) -ne ''){
															$found = $true
															write-host ""
															write-host "$($eqn) --> $($search)"
															write-host "Found at index: $($iterations)"
															break search
														}
													}
													
													$opsIndex  = [System.Collections.Generic.List[System.Object]]( @($a, $b, $c, $d, $e, $f, $g, $h, $i) )
													for($rot = 0; $rot -lt 9; $rot++){
														$o1 = $opsIndex[0];
														$opsIndex.removeAt(0)
														$opsIndex.add($o1)

														$a, $b, $c, $d, $e, $f, $g, $h, $i = $opsIndex
														
														$eqn = $this.getEqn($i, $h, $g, $f, $e, $d, $c, $b, $a)
														# write-host $eqn
														if($this.testEqn($eqn, $search) -ne ''){
															$found = $true
															write-host ""
															write-host "$($eqn) --> $($search)"
															write-host "Found at index: $($iterations)"
															break search
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
																	
																	$eqn = $this.getEqn($a, $b, $c, $d, $e, $f, $g, $h, $i, $first, $last)
																	# write-host $eqn
																	if($this.testEqn($eqn, $search) -ne ''){
																		$found = $true
																		write-host ""
																		write-host "$($eqn) --> $($search)"
																		write-host "Found at index: $($iterations)"
																		break search
																	}
																}
																for($rot = 0; $rot -lt 9; $rot++){
																	$o1 = $opsIndex[0];
																	$opsIndex.removeAt(0)
																	$opsIndex.add($o1)

																	$a, $b, $c, $d, $e, $f, $g, $h, $i = $opsIndex
																	
																	$eqn = $this.getEqn($i, $h, $g, $f, $e, $d, $c, $b, $a, $first, $last)
																	# write-host $eqn
																	if($this.testEqn($eqn, $search) -ne ''){
																		$found = $true
																		write-host ""
																		write-host "$($eqn) --> $($search)"
																		write-host "Found at index: $($iterations)"
																		break search
																	}
																}
																
															}
														}
													}
													
													if($iterations % 25 -eq 0){
														write-host $eqn
													}
												}
                                            }
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
