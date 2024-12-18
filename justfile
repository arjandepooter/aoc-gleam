current_year := `date "+%Y"`
current_day := `date "+%-d"`

default:
    @just --list

init day=current_day year=current_year:
    #!/usr/bin/env sh
    day=`printf "%02d" {{day}}`
    filename="src/aoc_{{year}}/day$day.gleam"
    if [ ! -f $filename ]; then 
        mkdir -p "src/aoc_{{year}}"
        cp _template.gleam $filename 
    fi

download day=current_day year=current_year: (init day year)
    #!/usr/bin/env sh
    day=`printf "%02d" {{day}}`
    filename="inputs/{{year}}/day$day.txt"
    if [ ! -f $filename ]; then 
        mkdir -p "inputs/{{year}}"
        curl -s "https://adventofcode.com/{{year}}/day/{{day}}/input" -H "Cookie: session=$AOC_SESSION_TOKEN" > $filename
    fi

run day=current_day year=current_year: (download day year)
    #!/usr/bin/env sh
    day=`printf "%02d" {{day}}`
    cat inputs/{{year}}/day$day.txt | gleam run --no-print-progress -m aoc_{{year}}/day$day
