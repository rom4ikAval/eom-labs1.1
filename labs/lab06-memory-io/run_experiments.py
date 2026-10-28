import os
import re
import select
import shutil
import subprocess as sp
import tempfile
import time
from pathlib import Path

root = Path(__file__).resolve().parent
art = root / 'artifacts'
art.mkdir(exist_ok=True)
os.environ['LC_ALL'] = 'C'

def section(title):
    print('\n========== ' + title + ' ==========', flush=True)

for tool in ('gcc', 'strace', 'objdump', 'getconf', 'cmp'):
    if not shutil.which(tool):
        raise SystemExit('Missing command: ' + tool)

with tempfile.TemporaryDirectory(prefix='eom-lab06-') as temp:
    work = Path(temp)

    def run(args, ok=True):
        result = sp.run(
            [str(a) for a in args], cwd=work,
            stdout=sp.PIPE, stderr=sp.PIPE, timeout=30
        )
        print(result.stdout.decode(errors='replace'), end='')
        print(result.stderr.decode(errors='replace'), end='')
        if ok and result.returncode:
            raise RuntimeError(f'{args}: exit={result.returncode}')
        return result

    section('Build and tools')
    for tool in ('gcc', 'strace'):
        result = sp.run(
            [tool, '--version'], capture_output=True,
            text=True, check=True
        )
        print(result.stdout.splitlines()[0])

    sources = [
        'memory_layout', 'memory_maps', 'page_size', 'heap_growth',
        'invalid_memory', 'standard_fds', 'fd_observer', 'open_file',
        'write_file', 'read_file', 'file_offset', 'file_offset_seek',
        'streams', 'buffering', 'buffering_flush', 'file_copy'
    ]
    flags = [
        '-std=c11', '-D_POSIX_C_SOURCE=200809L',
        '-Wall', '-Wextra', '-O0'
    ]
    commands = []

    for name in sources:
        print('Compiling ' + name + '.c')
        cmd = ['gcc', *flags, root / (name + '.c'), '-o', work / name]
        run(cmd)
        commands.append(' '.join(map(str, cmd)))

        run([
            'gcc', *flags, '-S', root / (name + '.c'),
            '-o', art / (name + '.s')
        ])
        dis = sp.run(
            ['objdump', '-d', work / name],
            capture_output=True, check=True
        )
        (art / (name + '.objdump.txt')).write_bytes(dis.stdout)

    (art / 'build-commands.txt').write_text('\n'.join(commands) + '\n')

    def ready(p, marker):
        lines = []
        deadline = time.monotonic() + 10
        while True:
            left = deadline - time.monotonic()
            if left <= 0 or not select.select(
                [p.stdout], [], [], max(left, 0)
            )[0]:
                raise RuntimeError('Timed out waiting for ' + marker)

            line = p.stdout.readline()
            if not line:
                raise RuntimeError('Process ended before ' + marker)

            line = line.decode()
            print(line, end='')
            lines.append(line)
            if marker in line:
                return ''.join(lines)

    def enter(p):
        p.stdin.write(b'\n')
        p.stdin.flush()

    def stop(p):
        if p.poll() is None:
            p.terminate()
        try:
            p.wait(timeout=3)
        except sp.TimeoutExpired:
            p.kill()
            p.wait()
        p.stdin.close()
        p.stdout.close()

    def start(name):
        return sp.Popen(
            [work / name], cwd=work,
            stdin=sp.PIPE, stdout=sp.PIPE, bufsize=0
        )

    section('memory_layout: three runs')
    layouts = []
    for i in range(3):
        print('Run', i + 1)
        layouts.append(run([work / 'memory_layout']).stdout.decode())
    (art / 'memory-layout.txt').write_text('\n'.join(layouts))

    section('page size and page/offset')
    run([work / 'page_size'])
    page = int(run(['getconf', 'PAGE_SIZE']).stdout)
    address = int(
        re.search(r'heap: (0x[0-9a-f]+)', layouts[0])[1], 16
    )
    print(f'Heap address={hex(address)} decimal={address}')
    print(
        f'Page size={page} page number={address // page} '
        f'offset={address % page}'
    )

    section('memory_maps and address matching')
    p = start('memory_maps')
    try:
        output = ready(p, 'READY')
        maps = Path(f'/proc/{p.pid}/maps').read_text()

        (art / 'memory-maps.txt').write_text(maps)
        (art / 'memory-maps-addresses.txt').write_text(output)
        print(maps)

        for label, value in re.findall(
            r'^(main|global|heap|stack): (0x[0-9a-f]+)', output, re.M
        ):
            a = int(value, 16)
            for line in maps.splitlines():
                lo, hi = (
                    int(x, 16)
                    for x in line.split()[0].split('-')
                )
                if lo <= a < hi:
                    print(f'MATCH {label} {value}: {line}')
                    break
            else:
                raise RuntimeError('No mapping for ' + label)

        enter(p)
        assert p.wait(timeout=5) == 0
    finally:
        stop(p)

    section('heap_growth: VmSize/VmRSS before and after touch')
    p = start('heap_growth')
    try:
        for phase, marker in [
            ('before', 'BEFORE_TOUCH'),
            ('after', 'AFTER_TOUCH')
        ]:
            ready(p, marker)
            status = Path(f'/proc/{p.pid}/status').read_text()
            maps = Path(f'/proc/{p.pid}/maps').read_text()

            (art / f'heap-{phase}-status.txt').write_text(status)
            (art / f'heap-{phase}-maps.txt').write_text(maps)

            print(phase.upper())
            for line in status.splitlines():
                if line.startswith(
                    ('VmSize:', 'VmRSS:', 'RssAnon:', 'VmData:')
                ):
                    print(line)
            enter(p)

        assert p.wait(timeout=5) == 0
    finally:
        stop(p)

    section('invalid_memory: intentional fault')
    r = run([work / 'invalid_memory'], ok=False)
    print(
        'Direct return code:', r.returncode,
        '(negative = signal in Python)'
    )

    r = run([
        'strace', '-o', art / 'invalid-memory.strace',
        work / 'invalid_memory'
    ], ok=False)
    print('strace return code:', r.returncode)
    print('\n'.join(
        (art / 'invalid-memory.strace').read_text().splitlines()[-10:]
    ))

    section('standard descriptors')
    run([work / 'standard_fds'])
    print(
        'Observer stdin/stdout are pipes used by this runner; '
        'stderr is inherited.'
    )

    for name in ('fd_observer', 'open_file'):
        section(name + ': /proc/PID/fd')
        p = start(name)
        try:
            ready(p, 'READY')
            lines = []
            for fd in sorted(
                Path(f'/proc/{p.pid}/fd').iterdir(),
                key=lambda x: int(x.name)
            ):
                lines.append(f'{fd.name} -> {os.readlink(fd)}')

            text = '\n'.join(lines) + '\n'
            print(text)
            (art / (name + '-fds.txt')).write_text(text)

            enter(p)
            assert p.wait(timeout=5) == 0
        finally:
            stop(p)

    section('write_file')
    run([work / 'write_file'])
    print('output.txt:', repr((work / 'output.txt').read_bytes()))

    (work / 'input.txt').write_bytes(
        b'Computer Systems\nOperating Systems\n'
    )
    section('read_file')
    run([work / 'read_file'])

    for name in ('file_offset', 'file_offset_seek'):
        section(name)
        run([work / name])

    def trace(name, args, filename, calls):
        run([
            'strace', '-e', 'trace=' + calls,
            '-o', art / filename, work / name, *args
        ])
        print((art / filename).read_text())

    section('read_file strace')
    trace(
        'read_file', [], 'read-file.strace',
        'openat,read,write,close'
    )

    section('streams without redirection')
    run([work / 'streams'])

    section('streams > normal.txt: stderr stays separate')
    with (work / 'normal.txt').open('wb') as out:
        r = sp.run(
            [work / 'streams'], cwd=work,
            stdout=out, stderr=sp.PIPE, check=True
        )
    print('normal.txt:', repr((work / 'normal.txt').read_bytes()))
    print('stderr:', repr(r.stderr))

    for name in ('buffering', 'buffering_flush'):
        section(name + ': writes observed with redirected stdout')
        trace(name, [], name + '.strace', 'write')

    section('file_copy: text, binary and empty file')
    source = work / 'source.txt'
    source.write_bytes(
        b'Operating Systems\nComputer Architecture\n'
    )
    (work / 'empty.txt').write_bytes(b'')

    for src, dst in [
        ('source.txt', 'destination.txt'),
        ('file_copy', 'binary-copy'),
        ('empty.txt', 'empty-copy')
    ]:
        run([work / 'file_copy', src, dst])
        run(['cmp', src, dst])
        print(
            f'cmp {src} {dst}: exit=0, '
            f'bytes={(work / src).stat().st_size}'
        )

    section('file_copy: error checks')
    os.link(source, work / 'same-inode.txt')
    cases = [
        [],
        ['missing.txt', 'unused.txt'],
        ['source.txt', 'missing-dir/out.txt'],
        ['.', 'read-error.txt'],
        ['source.txt', '/dev/full'],
        ['source.txt', 'source.txt'],
        ['source.txt', 'same-inode.txt']
    ]
    before = source.read_bytes()

    for args in cases:
        print('Arguments:', args)
        r = run([work / 'file_copy', *args], ok=False)
        print('exit=', r.returncode)
        if r.returncode == 0:
            raise RuntimeError('Expected failure')

    assert source.read_bytes() == before
    print('Same-file/hard-link check: source preserved')

    section('file_copy strace')
    trace(
        'file_copy', ['source.txt', 'destination.txt'],
        'file-copy.strace',
        'openat,read,write,close,fstat,newfstatat,ftruncate'
    )
    run(['cmp', 'source.txt', 'destination.txt'])
    print('Final cmp: exit=0')

section('ALL EXPERIMENTS FINISHED')
