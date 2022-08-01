$path = Get-ChildItem -Path (Read-Host -Prompt 'AVS to be encoded')
$encoding_params = "--preset quality"
$enc_binary = "nvencc"  # https://github.com/rigaya/NVEnc | https://github.com/rigaya/QSVEnc | https://github.com/rigaya/VCEEnc


$proc = @{}
if (Test-Path $path)
{
    $threads_num = Read-Host -Prompt 'threads number'
    mkdir -Path $path.Directory -Name "temp" -Force
    for ($i=0; $i -lt $threads_num; $i++)
    {
        $avs_str = ('Import("..\{0}.avs").' -f $path.BaseName)
        $start_exp = ($i).ToString() + "*last.frameCount/{0}" -f $threads_num + "+1"
        $end_exp = ($i+1).ToString() + "*last.frameCount/{0}" -f $threads_num
        if ($i -eq 0){$start_exp = "0"}
        if ($i -eq $threads_num-1){$end_exp = "0"}
        $avs_str += "Trim(Int({0}),Int({1}))" -f $start_exp,$end_exp
        $segment_avs_name = Join-Path $path.Directory ("temp\{0}_{1}.avs" -f $path.BaseName, $i.ToString().PadLeft(2,'0'))
        $segment_video_name = Join-Path $path.Directory ("temp\{0}_{1}.264" -f $path.BaseName, $i.ToString().PadLeft(2,'0'))
        New-Item -Path $segment_avs_name -ItemType File -Force | Set-Content -Value $avs_str
        $enc_args = "-i {0} {1} -o {2}" -f $segment_avs_name,$encoding_params,$segment_video_name
        $proc[$i] = Start-Process -FilePath $enc_binary -ArgumentList $enc_args -PassThru
    }
}

$running = $true
Measure-Command
{
    while ($running){
        for ($i=0;$i -lt $proc.Count; $i++)
        {
            if ($proc[$i].ExitCode -ne 0)
            {
                break
            }
            else
            {
                $running = $false
            }
        }
    Sleep 1.0
}
cd (Join-Path $path.Directory "temp")
cmd /c copy /b *.264 ..\full.264
cmd /c del /F /Q  .
cmd /c cd ..
Write-Host "Done"}