module ECRealTimeDatas

export latest, get_url, get_filename, download_steps

using Dates
using Downloads

function latest(; time=-1, step=0, model="ifs", stream="oper", type="fc", format="grib2", resol="0p25")
    enddate = floor(now(), Hour(12))
    if time == -1
        delta = Hour(-12)
    else
        delta = Day(-1)
        enddate += Hour(time) - Hour(enddate)
    end

    list = enddate:delta:enddate-Day(1)-Hour(6) |> collect
    list .|> println

    # @. list |> get_url |> (url->println("$url $(request(url).status)" ))
    for basetime in list
        url = get_url(basetime; step, model, stream, type, format, resol)
        filename = get_filename(basetime; step, stream, type, format)
        status = request(url).status

        status == 200 && return (;url, basetime, filename)
    end
end

#=
Currently, ECMWF open real-time data are available from these locations:

ECMWF, with ROOT set to https://data.ecmwf.int/forecasts
Microsoft's Azure, with ROOT set to "https://ai4edataeuwest.blob.core.windows.net/ecmwf"
Amazon's AWS, with ROOT set to "https://ecmwf-forecasts.s3.eu-central-1.amazonaws.com"

https://confluence.ecmwf.int/display/DAC/ECMWF+open+data%3A+real-time+forecasts+from+IFS+and+AIFS
=#

function get_url(basetime; step=0, model="ifs", stream="oper", type="fc", format="grib2", resol="0p25")

    ROOT = "https://ai4edataeuwest.blob.core.windows.net/ecmwf"

    yyyymmdd = Dates.format(basetime, dateformat"yyyymmdd")
    HH = Dates.format(basetime, dateformat"HH")

    filename = get_filename(basetime; step, stream, type, format)

    url = "$ROOT/$(yyyymmdd)/$(HH)z/$model/$resol/$stream/$filename"

    url
end

function get_filename(basetime; step=0, stream="oper", type="fc", format="grib2")

    yyyymmdd = Dates.format(basetime, dateformat"yyyymmdd")
    HH = Dates.format(basetime, dateformat"HH")

    filename = "$(yyyymmdd)$(HH)0000-$(step)h-$stream-$type.$format"

    filename
end

function get_status_code(url)

end

function download_steps(basetime = latest().basetime; steps = 0:24:72, path="", overwrite=false)
    result = Dict{Int, String}()

    mkpath(path)

    steplength = length(steps)
    i = 1
    for step in steps
        url = get_url(basetime; step)
        filename = get_filename(basetime; step)

        println("($i of $steplength) downloading $filename ...")
        
        fullname = "$path$filename"

        if !overwrite && isfile(fullname)
            println("    $filename already exist.")
        else
            Downloads.download(url, fullname)
            println("    $filename downloaded.")
        end

        result[step] = fullname
        i += 1
    end

    result
end

function test()
    [latest()
        latest(time=0)
        latest(time=12)
        latest(time=12, step=6)] .|> println
end

# test()

end