# ECMWFOpenData.jl
A Julia package to download ECMWF open data

```julia
include("ECMWFOpenData.jl/ec-real-time-data.jl")

using .ECRealTimeDatas
```

## Get Latest
```julia
    [latest()
        latest(time=0)
        latest(time=12)
        latest(time=12, step=6)] .|> println
```

## Get Filename
```julia
basetime = latest().basetime
steps = 0:24:72

@. steps |> ( x->get_filename(basetime; x) ) |> println
```

## Download Files
```julia
# download latest
download_steps(; steps = 0:24:72, path="ec-data")

# download other basetime
using Dates
basetime=DateTime("2024-04-14 12", dateformat"yyyy-mm-dd HH")
download_steps(basetime; steps = 0:24:72, path="ec-data")
```
