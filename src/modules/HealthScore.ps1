# ============================================================
# HealthScore.ps1 - Transparent 0-100 score
# ============================================================
function Get-HealthScore {
    param([Parameter(Mandatory=$true)]$Results)
    $score=100; $warnings=@(); $critical=@(); $breakdown=[ordered]@{}
    $weights=@{CPU=@{WARNING=12;CRITICAL=25};RAM=@{WARNING=12;CRITICAL=25};Storage=@{WARNING=10;CRITICAL=20};Network=@{WARNING=8;CRITICAL=20};Windows=@{WARNING=5;CRITICAL=10};Security=@{WARNING=15;CRITICAL=20};GPU=@{WARNING=4;CRITICAL=10};Battery=@{WARNING=8;CRITICAL=15};Thermal=@{WARNING=10;CRITICAL=20}}
    foreach ($name in $weights.Keys) { $r=$Results.$name; $deduction=0; if ($r) { if ($r.Status -eq 'WARNING') {$deduction=$weights[$name].WARNING}; if ($r.Status -eq 'CRITICAL') {$deduction=$weights[$name].CRITICAL}; if ($r.Status -eq 'WARNING') {$warnings += "$name: $($r.Summary)"}; if ($r.Status -eq 'CRITICAL') {$critical += "$name: $($r.Summary)"} }; $breakdown[$name]=[PSCustomObject]@{Status=if($r){$r.Status}else{'INFO'};Deduction=$deduction}; $score-=$deduction }
    if ($score -lt 0) {$score=0}; $status=if($score -ge 90){'Excellent'}elseif($score -ge 75){'Good'}elseif($score -ge 50){'Needs Attention'}else{'Critical'}
    $recommendations = if (Get-Command Get-HealthRecommendations -ErrorAction SilentlyContinue) { @(Get-HealthRecommendations -Results $Results) } else { @() }
    [PSCustomObject]@{Score=$score;Status=$status;CategoryResults=$breakdown;Warnings=$warnings;CriticalIssues=$critical;Recommendations=$recommendations;Explanation='Unavailable INFO categories receive no deduction. Deductions are applied only to WARNING or CRITICAL results.'}
}
