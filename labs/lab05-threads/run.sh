#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

if [[ ${1:-} != --experiments ]]; then
    bash "$0" --experiments 2>&1 | tee lab05-results.txt
    exit
fi

export LC_ALL=C

for tool in gcc objdump timeout; do
    command -v "$tool" >/dev/null || {
        echo "Missing command: $tool"
        exit 1
    }
done

build=$(mktemp -d /tmp/eom-lab05.XXXXXX)
trap 'rm -rf -- "$build"' EXIT
trap 'echo "ERROR at line $LINENO"' ERR

mkdir -p artifacts
: > artifacts/build-commands.txt

section() {
    printf '\n========== %s ==========\n' "$1"
}

repeat() {
    local program=$1 count=$2
    section "$program"
    for ((i=1; i<=count; ++i)); do
        echo "Run $i"
        "$build/$program"
    done
}

section "Build and preserve Assembly / full disassembly"

sources=(
    first_thread multiple_threads shared_data thread_stacks
    race mutex_counter race_four mutex_four coarse_mutex
    shared_heap thread_result deadlock deadlock_fixed
    parallel_sum sequential_sum
)

for name in "${sources[@]}"; do
    echo "Compiling $name.c"

    gcc -std=c11 -Wall -Wextra -O0 -pthread \
        "$name.c" -o "$build/$name"

    gcc -std=c11 -Wall -Wextra -O0 -pthread \
        -S "$name.c" -o "artifacts/$name.s"

    objdump -d "$build/$name" > "artifacts/$name.objdump.txt"

    printf 'gcc -std=c11 -Wall -Wextra -O0 -pthread %s.c -o %s/%s\n' \
        "$name" "$build" "$name" >> artifacts/build-commands.txt

    printf 'gcc -std=c11 -Wall -Wextra -O0 -pthread -S %s.c -o artifacts/%s.s\n' \
        "$name" "$name" >> artifacts/build-commands.txt

    printf 'objdump -d %s/%s > artifacts/%s.objdump.txt\n' \
        "$build" "$name" "$name" >> artifacts/build-commands.txt
done

repeat first_thread 1
repeat multiple_threads 5
repeat shared_data 5
repeat thread_stacks 3
repeat race 5

section "Machine instructions for increment"
objdump -d --disassemble=increment "$build/race" \
    | tee artifacts/race-increment.txt

repeat mutex_counter 5
repeat race_four 5
repeat mutex_four 5
repeat coarse_mutex 5
repeat shared_heap 1
repeat thread_result 1

section "Deadlock: observation limited to 5 seconds"

if timeout --kill-after=1s 5s "$build/deadlock"; then
    echo "Exit=0: deadlock was not reproduced in this run"
else
    status=$?
    echo "Exit=$status"

    if [[ $status -eq 124 ]]; then
        echo "Timeout: inspect acquired/waiting mutex messages above"
    else
        echo "Unexpected test error"
        exit "$status"
    fi
fi

section "Fixed deadlock"
timeout --kill-after=1s 8s "$build/deadlock_fixed"

repeat parallel_sum 3
repeat sequential_sum 3

section "Timings in seconds: three runs each"
TIMEFORMAT='real=%3R user=%3U sys=%3S'

for name in race mutex_counter race_four mutex_four \
            coarse_mutex sequential_sum parallel_sum; do
    section "time $name"
    for i in 1 2 3; do
        echo "Run $i"
        time "$build/$name"
    done
done

section "ALL EXPERIMENTS FINISHED"
