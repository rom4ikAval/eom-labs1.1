import os
import pty
import select
import shutil
import signal
import subprocess as sp
import tempfile
import time
from pathlib import Path

root = Path(__file__).resolve().parent
traces = root / 'traces'
traces.mkdir(exist_ok=True)
os.environ['LC_ALL'] = 'C'

def section(text):
    print('\n========== ' + text + ' ==========', flush=True)

for tool in ('gcc', 'strace', 'ls', 'wc', 'seq', 'head', 'grep', 'sleep', 'yes'):
    if not shutil.which(tool):
        raise SystemExit('Missing command: ' + tool)

with tempfile.TemporaryDirectory(prefix='eom-lab07-') as directory:
    work = Path(directory)

    def run(args, input=None):
        r = sp.run(
            [str(a) for a in args], cwd=work, input=input,
            capture_output=True, text=True, timeout=20
        )
        print(r.stdout, end='')
        print(r.stderr, end='')
        if r.returncode:
            raise RuntimeError(f'{args}: exit={r.returncode}')
        return r

    names = [
        'pipe_basic', 'pipe_processes', 'pipe_no_close', 'dup2_output',
        'redirect_exec', 'pipeline', 'signal_int',
        'signal_parent_child', 'mini_shell'
    ]

    section('Build')
    for name in names:
        print('Compiling ' + name + '.c')
        run([
            'gcc', '-std=c11', '-D_POSIX_C_SOURCE=200809L',
            '-Wall', '-Wextra', '-O0',
            root / (name + '.c'), '-o', work / name
        ])

    for name in ('pipe_basic', 'pipe_processes', 'pipe_no_close'):
        section(name)
        run([work / name])

    section('pipe_no_close --fixed')
    run([work / 'pipe_no_close', '--fixed'])

    section('pipe_processes strace -f')
    run([
        'strace', '-f', '-e',
        'trace=pipe,pipe2,clone,fork,vfork,read,write,close,wait4',
        '-o', traces / 'pipe-processes.strace',
        work / 'pipe_processes'
    ])
    print((traces / 'pipe-processes.strace').read_text())

    section('dup2_output')
    run([work / 'dup2_output'])
    print('redirected.txt:', repr((work / 'redirected.txt').read_text()))

    section('redirect_exec')
    run([work / 'redirect_exec'])
    print((work / 'ls-output.txt').read_text())

    section('pipeline: ls -l | wc -l')
    expected = len(sp.check_output(['ls', '-l'], cwd=work).splitlines())
    actual = int(run([work / 'pipeline']).stdout.strip())
    print(
        f'Expected lines={expected}; Actual={actual}; '
        f'Match={expected == actual}'
    )
    assert expected == actual

    section('SIGINT handler, then SIGKILL')
    p = sp.Popen(
        [work / 'signal_int'], cwd=work,
        stdout=sp.PIPE, bufsize=0
    )

    def line_until(marker):
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if not select.select([p.stdout], [], [], 0.2)[0]:
                continue
            line = p.stdout.readline().decode()
            if not line:
                raise RuntimeError('Unexpected EOF')
            print(line, end='')
            if marker in line:
                return
        raise RuntimeError('Signal test timed out')

    try:
        line_until('READY')
        p.send_signal(signal.SIGINT)
        line_until('SIGINT received')
        print('Alive after SIGINT:', p.poll() is None)
        assert p.poll() is None

        p.kill()
        code = p.wait(timeout=5)
        print('After SIGKILL returncode=', code)
        assert code == -signal.SIGKILL
    finally:
        if p.poll() is None:
            p.kill()
        p.wait()
        p.stdout.close()

    for args in ([], ['--handled']):
        section('signal_parent_child ' + ' '.join(args))
        run([work / 'signal_parent_child', *args])

    section('mini-shell: commands, cd, redirection, pipeline')
    (work / 'input.txt').write_text('hello one\nother\nhello two\n')

    commands = '\n'.join([
        'pwd',
        'ls',
        'ls -l',
        'echo Hello Systems',
        'cd /tmp',
        'pwd',
        'cd ' + str(work),
        'echo test > test.txt',
        'cat test.txt',
        'ls -l | wc -l',
        'cat input.txt | grep hello',
        'seq 100000 | wc -l',
        'yes | head -n 1',
        'exit',
        ''
    ])
    print('Commands:\n' + commands)
    result = run([work / 'mini_shell'], input=commands)

    (traces / 'mini-shell-session.txt').write_text(
        'Commands:\n' + commands +
        '\nSTDOUT:\n' + result.stdout +
        '\nSTDERR:\n' + result.stderr
    )
    assert (work / 'test.txt').read_text() == 'test\n'
    assert '100000' in result.stdout and 'hello two' in result.stdout
    print('Redirection content: test; large pipeline: 100000 lines')

    section('mini-shell: errors must not terminate shell')
    errors = '\n'.join([
        'command_that_does_not_exist',
        'cd /no-such-lab07-directory',
        'echo x > /no-such-lab07-directory/out',
        '| wc -l',
        'echo hi |',
        'echo hi >',
        'echo hi | cat | wc -l',
        'cd',
        'echo ' + 'x' * 1100,
        'echo still-running',
        'exit',
        ''
    ])
    result = run([work / 'mini_shell'], input=errors)
    assert 'still-running' in result.stdout
    (traces / 'mini-shell-errors.txt').write_text(
        result.stdout + result.stderr
    )

    section('mini-shell: real Ctrl+C character through pseudoterminal')
    pid, master = pty.fork()
    if pid == 0:
        os.chdir(work)
        os.execv(work / 'mini_shell', ['mini_shell'])

    transcript = bytearray()
    pending = bytearray()
    waited = False

    def until(marker):
        deadline = time.monotonic() + 8
        while marker not in pending:
            left = deadline - time.monotonic()
            if left <= 0 or not select.select(
                [master], [], [], max(left, 0)
            )[0]:
                raise RuntimeError('PTY timeout')

            data = os.read(master, 4096)
            if not data:
                raise RuntimeError('PTY closed unexpectedly')
            transcript.extend(data)
            pending.extend(data)

        end = pending.index(marker) + len(marker)
        del pending[:end]

    try:
        until(b'myshell> ')
        os.write(master, b'sleep 30\n')
        time.sleep(1)

        os.write(master, b'\x03')
        until(b'myshell> ')

        os.write(master, b'echo still-running\n')
        until(b'myshell> ')
        os.write(master, b'exit\n')

        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            done, status = os.waitpid(pid, os.WNOHANG)
            if done:
                waited = True
                assert os.waitstatus_to_exitcode(status) == 0
                break
            time.sleep(0.05)

        if not waited:
            raise RuntimeError('Shell did not exit')

        text = transcript.decode(errors='replace')
        print(text)
        (traces / 'ctrl-c-session.txt').write_text(text)

        assert 'Child signal=2' in text
        assert '\r\nstill-running\r\n' in text
        print(
            'PASS: sleep interrupted; shell survived '
            'and executed next command'
        )
    finally:
        if not waited:
            try:
                os.killpg(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            os.waitpid(pid, 0)
        os.close(master)

    section('mini-shell strace -f')
    run([
        'strace', '-f', '-e',
        'trace=process,pipe,pipe2,dup2,openat,close,read,write',
        '-o', traces / 'mini-shell.strace', work / 'mini_shell'
    ], input='echo hello > output.txt\nls | wc -l\nexit\n')

    assert (work / 'output.txt').read_text() == 'hello\n'
    text = (traces / 'mini-shell.strace').read_text()

    for line in text.splitlines():
        if any(x in line for x in (
            'clone(', 'fork(', 'vfork(', 'pipe(', 'pipe2(',
            'dup2(', 'execve(', 'wait4(', 'output.txt'
        )):
            print(line)

    print('Full trace saved: traces/mini-shell.strace')

section('ALL EXPERIMENTS FINISHED')
